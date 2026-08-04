#!/usr/bin/env node
import fs from "node:fs/promises";
import path from "node:path";
import process from "node:process";
import { configureFal, uploadLocal, generateImage, removeBackground, download } from "./fal.mjs";
import { conceptPrompt, locationPrompt, animationPrompt } from "./prompts.mjs";
import { inspectImage, acceptedStructurally } from "./quality.mjs";
import { makeContactSheet, splitGrid } from "./sheets.mjs";

const REPO = path.resolve(new URL("../../..", import.meta.url).pathname);
const MANIFEST_PATH = path.join(REPO, "content/visual/visual_iteration_manifest_v3.json");
const RESULTS_PATH = path.join(REPO, "content/visual/visual_iteration_results_v3.json");
const REVIEW_ROOT = path.join(REPO, "art/review/v3");
const PRODUCTION_ROOT = path.join(REPO, "art/production_v3");

function args() {
  const values = process.argv.slice(2);
  const command = values.shift() || "help";
  const options = {};
  for (let i = 0; i < values.length; i++) {
    if (!values[i].startsWith("--")) continue;
    const key = values[i].slice(2);
    options[key] = values[i + 1]?.startsWith("--") ? true : values[++i] ?? true;
  }
  return { command, options };
}
async function readJson(file) { return JSON.parse(await fs.readFile(file, "utf8")); }
async function writeJson(file, value) { await fs.mkdir(path.dirname(file), {recursive:true}); await fs.writeFile(file, JSON.stringify(value,null,2)+"\n"); }
function itemById(manifest, type, id) {
  const collection = type === "character" ? manifest.characters : manifest.locations;
  const item = collection.find(x => x.id === id);
  if (!item) throw new Error(`Unknown ${type}: ${id}`);
  return item;
}
function resolveRepo(p) { return path.join(REPO, p); }

let calls = 0;
function charge() {
  calls++;
  const max = Number(process.env.FLUX_VISUAL_MAX_CALLS || "8");
  if (calls > max) throw new Error(`Generation budget exceeded (${max} calls).`);
}

async function conceptCandidate(manifest, type, item, attempt) {
  const stylePath = resolveRepo(item.style_reference || manifest.reference_baseline.path);
  const styleUrl = await uploadLocal(stylePath);
  const prompt = type === "character" ? conceptPrompt(item) : locationPrompt(item);
  charge();
  const generated = await generateImage({ prompt, imageUrls:[styleUrl], aspectRatio:type === "location" ? "16:9" : "1:1" });
  let url = generated.url;
  if (type === "character") { charge(); url = (await removeBackground(url)).url; }
  const dir = path.join(REVIEW_ROOT, type+"s", item.id, `attempt_${String(attempt).padStart(2,"0")}`);
  const file = path.join(dir, "candidate.png");
  await download(url, file);
  const metrics = await inspectImage(file);
  await writeJson(path.join(dir, "metrics.json"), metrics);
  return { file, metrics, attempt };
}

async function runConcept(manifest, type, item, attempts) {
  const candidates = [];
  for (let attempt=1; attempt<=attempts; attempt++) {
    const candidate = await conceptCandidate(manifest, type, item, attempt);
    candidates.push(candidate);
    if (type === "location" || acceptedStructurally(candidate.metrics, manifest.quality_gate.minimum_structural_score)) break;
  }
  candidates.sort((a,b)=>b.metrics.structuralScore-a.metrics.structuralScore);
  const best = candidates[0];
  const reference = resolveRepo(item.style_reference || manifest.reference_baseline.path);
  const contact = path.join(REVIEW_ROOT, type+"s", item.id, "contact_sheet.png");
  await makeContactSheet([reference, ...candidates.map(c=>c.file)], contact);
  const destination = path.join(PRODUCTION_ROOT, type+"s", item.id, "concept_candidate.png");
  await fs.mkdir(path.dirname(destination), {recursive:true});
  await fs.copyFile(best.file, destination);
  return {
    id:item.id, type, status:"generated_candidate_needs_visual_review",
    selected: path.relative(REPO,destination), contact_sheet:path.relative(REPO,contact),
    metrics:best.metrics, attempts:candidates.length,
  };
}

async function runSlice(manifest, sliceId, attempts) {
  configureFal();
  const slice = manifest.slices.find(s=>s.id===sliceId);
  if (!slice) throw new Error(`Unknown slice: ${sliceId}`);
  const results = [];
  for (const token of slice.items) {
    const [type,id] = token.split(":");
    const item = itemById(manifest,type,id);
    results.push(await runConcept(manifest,type,item,attempts));
  }
  const existing = await readJson(RESULTS_PATH).catch(()=>({schema_version:3,items:{}}));
  for (const result of results) existing.items[`${result.type}:${result.id}`]=result;
  existing.last_run = new Date().toISOString();
  existing.generator = "tools/visual_ai/src/cli.mjs";
  await writeJson(RESULTS_PATH,existing);
  return results;
}

async function runAnimation(manifest, id, animation, direction, attempts) {
  configureFal();
  const item = itemById(manifest,"character",id);
  const accepted = path.join(PRODUCTION_ROOT,"characters",id,"concept_candidate.png");
  await fs.access(accepted);
  const referenceUrl = await uploadLocal(accepted);
  const contract = manifest.animations[animation];
  if (!contract) throw new Error(`Unknown animation: ${animation}`);
  const rows = 2;
  const columns = contract.frames <= 4 ? 2 : 3;
  const candidates=[];
  for(let attempt=1;attempt<=attempts;attempt++){
    charge();
    const result=await generateImage({
      prompt:animationPrompt(item,animation,direction,contract.frames),
      imageUrls:[referenceUrl], aspectRatio:"1:1"
    });
    charge();
    const clean=await removeBackground(result.url);
    const dir=path.join(REVIEW_ROOT,"characters",id,"animations",animation,direction,`attempt_${String(attempt).padStart(2,"0")}`);
    const sheet=path.join(dir,"sheet.png");
    await download(clean.url,sheet);
    const metrics=await inspectImage(sheet);
    await writeJson(path.join(dir,"metrics.json"),metrics);
    candidates.push({sheet,metrics,attempt});
    if(acceptedStructurally(metrics,0.72))break;
  }
  candidates.sort((a,b)=>b.metrics.structuralScore-a.metrics.structuralScore);
  const best=candidates[0];
  const output=path.join(PRODUCTION_ROOT,"characters",id,"animations",animation,direction);
  const frames=await splitGrid(best.sheet,output,columns,rows,96);
  await makeContactSheet([best.sheet,...frames.slice(0,contract.frames)],path.join(output,"review.png"),220);
  return {id,animation,direction,frames:frames.slice(0,contract.frames).map(x=>path.relative(REPO,x)),status:"generated_candidate_needs_visual_review"};
}

async function validate(manifest) {
  const errors=[];
  if(!manifest.reference_baseline?.path)errors.push("missing reference baseline");
  if(manifest.characters.length!==24)errors.push(`expected 24 characters, got ${manifest.characters.length}`);
  if(manifest.races.length!==21)errors.push(`expected 21 races, got ${manifest.races.length}`);
  if(Object.keys(manifest.animations).length!==25)errors.push("expected 25 animations");
  if(manifest.locations.length!==9)errors.push("expected nine Wellspring locations");
  for(const item of manifest.characters.filter(x=>x.gold_standard)){
    try{await fs.access(resolveRepo(item.style_reference));}catch{errors.push(`missing ${item.style_reference}`);}
  }
  if(errors.length)throw new Error(errors.join("\n"));
  console.log("visual iteration v3 manifest validation passed");
  console.log("24 champions, 21 races, 25 animations, nine Wellspring locations");
}

const {command,options}=args();
const manifest=await readJson(MANIFEST_PATH);
if(command==="run-slice"){
  const results=await runSlice(manifest,options.slice||"gold_standard_concepts",Number(options.attempts||2));
  console.log(JSON.stringify(results,null,2));
}else if(command==="animation"){
  const result=await runAnimation(manifest,options.id,options.animation,options.direction||"south",Number(options.attempts||2));
  console.log(JSON.stringify(result,null,2));
}else if(command==="validate"){
  await validate(manifest);
}else{
  console.log(`Usage:
  node src/cli.mjs validate
  node src/cli.mjs run-slice --slice gold_standard_concepts --attempts 2
  node src/cli.mjs animation --id oh_tipi --animation idle --direction south --attempts 2`);
}
