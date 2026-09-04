# Sanctum-to-Wellspring migration note

Status: **historical naming adapter**.

“Sanctum” was the earlier name for FLUX's starting world and survives in some
stable file paths, class names and content IDs. The current player-facing name
and canonical map contract is **the Wellspring**:

- [`WELLSPRING-HUB.md`](WELLSPRING-HUB.md) owns geography, purpose and station
  design;
- [`WELLSPRING-V1-ACCEPTANCE.md`](WELLSPRING-V1-ACCEPTANCE.md) owns the living
  starting-world acceptance gate;
- [`PLAYER-EXPERIENCE-OVERHAUL.md`](PLAYER-EXPERIENCE-OVERHAUL.md) owns
  onboarding, usability, plug-and-play and player journeys.

Do not author new player-facing “Sanctum” vocabulary. Rename technical IDs only
through an atomic migration covering content hashes, saves, tests, network
compatibility, scripts and packaged assets; until then they are adapters, not a
second place or product concept.
