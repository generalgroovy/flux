import fs from "node:fs/promises";
import path from "node:path";
import { fal } from "@fal-ai/client";

export function configureFal() {
  const key = process.env.FAL_KEY?.trim();
  if (!key) throw new Error("FAL_KEY is required; generation is fail-closed.");
  fal.config({ credentials: key });
}

export async function uploadLocal(filePath) {
  const bytes = await fs.readFile(filePath);
  const file = new File([bytes], path.basename(filePath), { type: "image/png" });
  return fal.storage.upload(file);
}

export async function generateImage({ prompt, imageUrls = [], aspectRatio = "1:1" }) {
  const model = process.env.FLUX_VISUAL_MODEL || "openai/gpt-image-2";
  const endpoint = imageUrls.length ? `${model}/edit` : model;
  const input = {
    prompt,
    image_size: aspectRatio === "16:9" ? "landscape_16_9" : "square_hd",
    quality: process.env.FLUX_VISUAL_QUALITY || "high",
    num_images: 1,
    output_format: "png",
  };
  if (imageUrls.length) input.image_urls = imageUrls;
  const result = await fal.subscribe(endpoint, {
    input,
    logs: true,
    onQueueUpdate(update) {
      if (update.status === "IN_PROGRESS") {
        for (const log of update.logs || []) console.log(log.message);
      }
    },
  });
  const image = result.data?.images?.[0];
  if (!image?.url) throw new Error(`No image returned by ${endpoint}`);
  return image;
}

export async function removeBackground(imageUrl) {
  const result = await fal.subscribe("fal-ai/bria/background/remove", {
    input: { image_url: imageUrl },
  });
  const image = result.data?.image;
  if (!image?.url) throw new Error("Background removal returned no image");
  return image;
}

export async function download(url, destination) {
  const response = await fetch(url);
  if (!response.ok) throw new Error(`Download failed ${response.status}: ${url}`);
  const data = Buffer.from(await response.arrayBuffer());
  await fs.mkdir(path.dirname(destination), { recursive: true });
  await fs.writeFile(destination, data);
  return destination;
}
