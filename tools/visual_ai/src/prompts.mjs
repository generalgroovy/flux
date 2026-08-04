const BASE_STYLE = `
Original high-detail chibi fantasy pixel art. The supplied FLUX roster reference is the minimum
quality baseline: expressive face, large readable head, dark clustered pixel outlines, deliberate
pixel clusters, strong silhouette, four-to-six shade ramps per major material, large signature
equipment, integrated elemental motifs, controlled saturated palette, transparent background,
no text, no labels, no border, no watermark, no grid except when explicitly requested.
Do not copy exact pixels or composition. Preserve the canonical brief exactly.
`;

const NEGATIVE = `
Avoid: generic mannequin, flat two-tone shapes, smooth vector edges, painterly blur, 3D render,
photorealism, pillow shading, tiny unreadable face, generic recolor, weak silhouette, cropped
weapons, cropped horns, cropped wings, duplicated limbs, inconsistent hands, extra text.
`;

export function conceptPrompt(item) {
  return `${BASE_STYLE}
Create one full-body character design for ${item.name}.
Canonical brief: ${item.brief}
Race: ${item.race}. Size class: ${item.size}. Elements: ${item.elements.join(", ")}.
Pose: expressive asymmetric battle-ready three-quarter pose, full body and all equipment visible.
The face must communicate the character's temperament. Race anatomy must remain recognizable in
grayscale and silhouette. Elemental effects should frame the character without obscuring anatomy.
Use a simple transparent background and leave at least 10% safe margin around every attachment.
${NEGATIVE}`;
}

export function locationPrompt(item) {
  return `${BASE_STYLE}
Create a top-down 3/4 pixel-art environment concept and modular visual kit for ${item.name}.
Function: ${item.function}. Dominant landmark: ${item.landmark}.
This belongs to The Wellspring, a charming cosmic hub centered on an eight-current waterfall of
Flux energy. Show a readable central landmark, calm movement lanes, richly detailed boundaries,
modular architecture, props, vegetation, foreground cutaway pieces and distinct elemental motifs.
No characters, labels or UI. Do not produce one flat painting: visibly organize reusable terrain,
architecture, prop and landmark modules around a playable composition.
${NEGATIVE}`;
}

export function animationPrompt(item, animation, direction, frames) {
  const grid = frames <= 4 ? "2 columns by 2 rows" : "3 columns by 2 rows";
  return `${BASE_STYLE}
Using the accepted character design as strict identity reference, create a ${frames}-frame
${animation} animation for ${item.name}, facing ${direction}, in top-down 3/4 gameplay perspective.
Arrange frames in a clean ${grid} sprite-sheet grid on a flat chroma-green background. No divider
lines, text, labels or borders. Keep the character at identical scale and ground anchor in every
cell. All equipment, hair, horns, fins, wings, tails and clothing must remain consistent.
Each frame must be a meaningful key pose with anticipation, action, impact/recovery and secondary
motion appropriate to ${animation}. Leave generous transparent-safe margins.
${NEGATIVE}`;
}

export function scorePrompt(item) {
  return `Judge whether this candidate meets the FLUX reference baseline for ${item.name}.
Evaluate silhouette, race readability, expression, personality, equipment, materials, elemental
identity, pixel clustering and charm. Return strict JSON with 0-5 scores and concise failures.`;
}
