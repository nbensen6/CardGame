#!/usr/bin/env node
/**
 * Rewrite every card's authored `text` from its own fields.
 *
 * Nick, 2026-08-16: "None of them should have any extra description... No need
 * for plus signs. There should be no arrows in card descriptions."
 *
 * The card FACE is generated live by CardView.face_text() from the preview. This
 * text is the other half — what the inspector and the Card Lab show — so it
 * describes the card's SHAPE: printed values plus the scaling and timing clauses
 * a live number can't show. Same vocabulary, same order, no flavour, no "+", no
 * arrows, no "Time it!" (the clock badge says that now).
 *
 *   node tools/cardlab/rewrite-text.js          preview the changes
 *   node tools/cardlab/rewrite-text.js --write   apply them
 */
const fs = require("fs");
const path = require("path");

const FILE = path.join(__dirname, "..", "..", "game", "data", "cards.json");
const WRITE = process.argv.includes("--write");

const n = (c, f) => Number(c[f] || 0);

/** "twice" / "3 times" — never "x2", which reads as a cost. */
function times(hits) {
  if (hits <= 1) return "";
  return hits === 2 ? " twice" : ` ${hits} times`;
}

/** "Deal 2 damage" + ["3 per Rhythm"] → "Deal 2 damage and an additional 3 per Rhythm".
 *  Scaling belongs in the sentence it scales, not in a clause of its own. */
function withScaling(clause, extras) {
  return extras.length ? `${clause} and an additional ${extras.join(" and ")}` : clause;
}

function describe(c) {
  const out = [];

  // A card that scales off both hunters' Height by the same amount says so once.
  const mine = n(c, "damage_per_foothold"), theirs = n(c, "damage_per_ally_foothold");
  const dmgScale = [];
  if (n(c, "damage_per_rhythm") > 0) dmgScale.push(`${n(c, "damage_per_rhythm")} per Rhythm`);
  if (mine > 0 && mine === theirs) dmgScale.push(`${mine} per Height, yours and your ally's`);
  else {
    if (mine > 0) dmgScale.push(`${mine} per Height`);
    if (theirs > 0) dmgScale.push(`${theirs} per your ally's Height`);
  }
  if (n(c, "damage_per_exhausted") > 0) dmgScale.push(`${n(c, "damage_per_exhausted")} per card burned`);
  if (n(c, "damage_per_vulnerable") > 0) dmgScale.push(`${n(c, "damage_per_vulnerable")} per Expose`);
  if (n(c, "damage_per_wound") > 0) dmgScale.push(`${n(c, "damage_per_wound")} per Poison`);

  const dmg = n(c, "damage");
  if (dmg > 0) out.push(withScaling(`Deal ${dmg} damage${times(n(c, "hits") || 1)}`, dmgScale) + ".");

  const blkScale = [];
  if (n(c, "block_per_exhausted") > 0) blkScale.push(`${n(c, "block_per_exhausted")} per card burned`);
  if (n(c, "block_per_play") > 0) blkScale.push(`${n(c, "block_per_play")} per earlier play this fight`);

  // Both-hunters effects are one clause, not the same sentence twice.
  const blk = n(c, "block"), ablk = n(c, "ally_block");
  if (blk > 0 && blk === ablk) out.push(withScaling(`All players gain ${blk} Block`, blkScale) + ".");
  else {
    if (blk > 0) out.push(withScaling(`Gain ${blk} Block`, blkScale) + ".");
    if (ablk > 0) out.push(`Ally gains ${ablk} Block.`);
  }

  const gripScale = [];
  if (n(c, "grip_per_rhythm") > 0) gripScale.push(`${n(c, "grip_per_rhythm")} per Rhythm`);

  const grip = n(c, "grip"), agrip = n(c, "ally_grip");
  if (grip > 0 && grip === agrip) out.push(withScaling(`All players climb ${grip}`, gripScale) + ".");
  else {
    if (grip > 0) out.push(withScaling(`Climb ${grip}`, gripScale) + ".");
    if (agrip > 0) out.push(`Ally climbs ${agrip}.`);
  }

  if (n(c, "wound") > 0) out.push(`Poison ${n(c, "wound")}.`);
  if (n(c, "vulnerable") > 0) out.push(`Expose ${n(c, "vulnerable")}.`);
  if (n(c, "strength") > 0) out.push(`Strength ${n(c, "strength")}.`);
  if (n(c, "rhythm") > 0) out.push(`Rhythm ${n(c, "rhythm")}.`);
  if (n(c, "draw") > 0) out.push(`Draw ${n(c, "draw")}.`);
  if (n(c, "ally_energy") > 0) out.push(`Ally gains ${n(c, "ally_energy")} Energy.`);
  if (c.taunt) out.push("Taunt.");
  if (n(c, "pull_ally") > 0) out.push("Pull your ally up to you.");

  if (n(c, "sac_ally_grip") > 0) out.push(`Burn a card: ally climbs ${n(c, "sac_ally_grip")}.`);
  else if (c.exhaust_pick) {
    out.push(c.cheapen_pick
      ? `Burn a card to cheapen another by ${n(c, "cheapen_amount") || 1}.`
      : "Burn a card.");
  }
  if (c.create) out.push("Build a tool into your hand.");
  if (c.prepare) out.push("Primed for next turn.");
  // Costing 1 less is the whole reason to meld (combat._meld_cards), so it stays
  // even though it reads like flavour next to the other one-liners.
  if (c.meld) out.push("Fuse two cards into one that costs 1 less.");

  // Nothing about timing. Not the bonus, not the window count — the clock badge
  // on the card carries all of it (Nick, 2026-08-16: "Don't include anything
  // about timing"). A timed card's description is what a non-timed card with the
  // same fields would say.
  return out.join(" ");
}

const src = fs.readFileSync(FILE, "utf8");
const data = JSON.parse(src);

// Line-by-line, so the file keeps its one-card-per-line shape. A JSON.stringify
// round-trip would reformat all 142 lines and bury the real change.
const lines = src.split(/\r?\n/);
let changed = 0;
const report = [];

for (const [id, card] of Object.entries(data.cards)) {
  const next = describe(card);
  if (!next) {
    report.push([id, card.text || "", "(NO FIELDS - left alone)"]);
    continue;
  }
  if (next === card.text) continue;
  const i = lines.findIndex((l) => l.trimStart().startsWith(`"${id}":`));
  if (i < 0) throw new Error(`no line found for card ${id}`);
  const before = lines[i];
  lines[i] = before.replace(/"text":\s*"(?:[^"\\]|\\.)*"/, () =>
    `"text": ${JSON.stringify(next)}`);
  if (lines[i] === before) throw new Error(`no text field on line for ${id}`);
  report.push([id, card.text || "", next]);
  changed++;
}

for (const [id, was, now] of report) {
  console.log(`${id}\n  was  ${was}\n  now  ${now}`);
}
console.log(`\n${changed} of ${Object.keys(data.cards).length} cards rewritten.`);

if (WRITE) {
  const out = lines.join("\n");
  JSON.parse(out); // never write a file that no longer parses
  fs.writeFileSync(FILE, out, "utf8");
  console.log(`written → ${FILE}`);
} else {
  console.log("(dry run — pass --write to apply)");
}
