# Character animation skeleton and modding contract

This layer is presentation-only. It does not change hitboxes, statistics, movement,
abilities, networking, stable runtime IDs, or champion availability.

## Purpose

`src/character-animation-skeletons.mjs` defines one reusable 32×32 virtual-pixel
character rig that can be resolved for:

- all five body sizes: Tiny, Small, Medium, Large, and Huge;
- all twenty ancestry visual templates;
- eight directional rows;
- eleven basic animation states;
- roster characters and external mods through the same registry API.

`src/overhaul-character-animation-manifests.mjs` registers the full README visual
roster: twenty-three named champions plus the explicitly unapproved Angel
placeholder. Most entries remain `skeleton-only`; this is asset and animation
coverage, not gameplay promotion.

## Sprite-sheet convention

Each character owns one image per state:

```text
assets/characters/<character-id>/<state>.png
```

Every state image uses:

- 32×32 virtual-pixel cells;
- one row per direction in this order: south, southeast, east, northeast, north,
  northwest, west, southwest;
- one column per animation frame;
- nearest-neighbour scaling;
- the feet/shadow centre at virtual pixel `(16, 28)`;
- transparent background;
- no padding that changes the cell dimensions.

The default states are:

```text
idle move sprint jump fall slide dodge commit defend hit defeated
```

Frame counts and timings are declared in the manifest. Mods may override timing
without changing simulation timing.

## Creating a character manifest

```js
import {
  createAnimationManifest,
  createCharacterAnimationRegistry,
} from "../src/character-animation-skeletons.mjs";

const registry = createCharacterAnimationRegistry();

registry.register({
  id: "example-mason",
  name: "Example Mason",
  ancestryId: "dwarf",
  size: 2,
  focusProp: "stone chisel",
  palette: {
    body: "warm-brown",
    mantle: "masonry-gray",
    focus: "ember-gold",
  },
});
```

A duplicate ID is rejected unless the caller explicitly uses
`{ replace: true }`. This prevents one mod from silently replacing another.

## Supported skeleton overrides

A character may adjust presentation anchors without copying the ancestry rig:

```js
const manifest = createAnimationManifest({
  id: "example-winged",
  name: "Example Winged",
  ancestryId: "wyrmborn",
  size: 3,
  skeletonOverrides: {
    proportions: {
      widthScale: 1.06,
      lean: 0.2,
    },
    boneOffsets: {
      rightHand: { x: 1, y: -1 },
    },
    extraAttachmentFeatures: ["plain-halo"],
    extraAttachments: [
      {
        id: "focus-rune",
        anchors: [{ x: 21, y: 15 }],
      },
    ],
  },
});
```

Use overrides only for visual posture, equipment placement, and silhouette.
Never encode range, collision, damage, cooldown, speed, or state authority in the
animation manifest.

## Ancestry aliases

The visual registry uses the final presentation names. Existing design-only
runtime aliases resolve without duplicating skeletons:

| Runtime/data alias | Visual ancestry |
| --- | --- |
| `scaleheir`, `wyrm` | `wyrmborn` |
| `stonewrought` | `stoneborn` |
| `rootwarden`, `ent` | `treefolk` |

## Validation

Run:

```bash
node --test tests/character-animation-skeletons.test.mjs
npm test
```

The focused test verifies all 100 ancestry/size combinations, deterministic pose
resolution, mod registration/replacement, the full twenty-four-slot roster,
eight directions, and every basic animation state.

## Promotion boundary

A skeleton manifest means the character can receive sprite assets without a new
renderer branch. It does not make the character selectable. Gameplay promotion
still requires the repository's mechanic, authority, bot, accessibility,
packaging, and visual acceptance gates.
