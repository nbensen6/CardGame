#!/usr/bin/env node
/**
 * One-shot: stamp a `rarity` onto every card in game/data/cards.json that
 * doesn't already have one.
 *
 *   node tools/cardlab/assign-rarity.js          # dry run, prints the split
 *   node tools/cardlab/assign-rarity.js --write  # actually edit cards.json
 *
 * It edits LINE BY LINE rather than reparsing and re-serialising, so the file's
 * one-card-per-line formatting survives untouched and the diff stays readable.
 *
 * Idempotent: a card that already declares a rarity is never overwritten, so
 * hand-tuning a card is permanent and re-running this is safe.
 */
const fs = require("fs");
const path = require("path");

const FILE = path.resolve(__dirname, "..", "..", "game", "data", "cards.json");
const WRITE = process.argv.includes("--write");

const SCALERS = [
  "damage_per_vulnerable", "damage_per_foothold", "damage_per_wound",
  "damage_per_rhythm", "damage_per_ally_foothold", "grip_per_rhythm",
  "damage_per_exhausted", "block_per_exhausted", "block_per_play",
];

/** Power heuristic. Deliberately blunt — it's a starting point to hand-tune. */
function rarityFor(c) {
  const cost = c.cost || 0;
  const scalers = SCALERS.filter((f) => c[f]).length;

  // Rare: the run-defining payoffs — expensive, multi-scaling, or a huge swing.
  // Deliberately NOT plain high damage: Cleave and Harpoon hit hard but they're
  // workhorses, not build-defining, and burying them in the rare slot would make
  // ordinary draft picks feel starved.
  if (cost >= 3) return "rare";
  if (scalers >= 2) return "rare";
  if ((c.timed_damage || 0) >= 10) return "rare";
  if (c.meld || c.prepare) return "rare";

  // Uncommon: a real build piece — costs real energy, scales, or builds a tool.
  if (cost === 2) return "uncommon";
  if (scalers === 1) return "uncommon";
  if (c.create) return "uncommon";
  if ((c.timed_damage || 0) >= 5) return "uncommon";
  if ((c.timed_grip || 0) >= 3) return "uncommon";
  if ((c.timed_block || 0) >= 6 || (c.timed_ally_block || 0) >= 6) return "uncommon";
  if ((c.ally_block || 0) >= 6 || (c.ally_grip || 0) >= 3) return "uncommon";

  return "common";
}

const raw = fs.readFileSync(FILE, "utf8");
const cards = JSON.parse(raw).cards;
const lines = raw.split(/\r?\n/);
const counts = { common: 0, uncommon: 0, rare: 0, skipped: 0 };
const byRarity = { common: [], uncommon: [], rare: [] };

const out = lines.map((line) => {
  // Match a card entry: leading indent, "id": { ... }
  const m = line.match(/^(\s*)"([a-z0-9_]+)":\s*\{/);
  if (!m) return line;
  const id = m[2];
  const card = cards[id];
  if (!card) return line;

  if (card.rarity) {
    counts.skipped++;
    return line;
  }
  const rarity = rarityFor(card);
  counts[rarity]++;
  byRarity[rarity].push(card.name || id);

  // Insert right after the "name" pair so it reads near the top of the entry.
  const nameEnd = line.indexOf('",', line.indexOf('"name"'));
  if (line.includes('"name"') && nameEnd !== -1) {
    return line.slice(0, nameEnd + 2) + ` "rarity": "${rarity}",` + line.slice(nameEnd + 2);
  }
  // No name field (shouldn't happen) — fall back to just after the opening brace.
  const brace = line.indexOf("{");
  return line.slice(0, brace + 1) + `"rarity": "${rarity}", ` + line.slice(brace + 1);
});

const result = out.join("\n");
JSON.parse(result); // fail loudly rather than write broken JSON

if (WRITE) {
  fs.writeFileSync(FILE, result, "utf8");
  console.log(`wrote ${FILE}`);
} else {
  console.log("DRY RUN — pass --write to apply\n");
}
const total = counts.common + counts.uncommon + counts.rare;
for (const r of ["common", "uncommon", "rare"]) {
  const pct = total ? Math.round((counts[r] / total) * 100) : 0;
  console.log(`${r.padEnd(9)} ${String(counts[r]).padStart(3)}  (${pct}%)`);
}
console.log(`already set ${counts.skipped}`);
console.log(`\nrares: ${byRarity.rare.join(", ")}`);
