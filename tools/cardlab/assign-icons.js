#!/usr/bin/env node
/**
 * Stamp an `icon` onto every card in game/data/cards.json that doesn't declare one.
 *
 *   node tools/cardlab/assign-icons.js                # dry run, prints the spread
 *   node tools/cardlab/assign-icons.js --write        # fill in cards with no icon
 *   node tools/cardlab/assign-icons.js --write --all  # RE-assign every card
 *
 * `--all` exists because the icons already in the data were themselves authored
 * against the old 14-icon vocabulary — they are the collision, not a hand-tuning to
 * preserve. Use it once when the vocabulary widens; omit it afterwards so deliberate
 * per-card choices survive.
 *
 * Why explicit data rather than the host's heuristic: GameHost._card_icon already
 * guesses an icon from a card's fields, but it only knew 14 of them, so 136
 * draftable cards collapsed onto 14 faces — 27 wearing the same "climb". Writing
 * the choice into the data both widens the vocabulary and lets any single card be
 * overridden by hand without touching code.
 *
 * Line-by-line edit, so the one-card-per-line formatting survives. Never overwrites
 * an icon that is already set, so hand-tuning is permanent and re-running is safe.
 */
const fs = require("fs");
const path = require("path");

const FILE = path.resolve(__dirname, "..", "..", "game", "data", "cards.json");
const WRITE = process.argv.includes("--write");
const ALL = process.argv.includes("--all");

/**
 * Most identity-defining wins. The order IS the design: a card that builds a gadget
 * reads as a gadget card even though it also deals damage, because that's what the
 * player is choosing it for.
 */
function iconFor(c) {
  const n = (k) => Number(c[k] || 0);
  const has = (k) => Boolean(c[k]);

  // 1. Cards defined by a special mechanic. These read as themselves whatever else
  //    they do — you pick Meld because it melds, not because it costs 1.
  if (has("meld")) return "cog";
  if (has("create")) return "gadget";
  if (has("prepare")) return "ascend";
  if (has("exhaust_pick")) return "burn";
  if (n("pull_ally") || n("sac_ally_grip")) return "lift";
  if (has("taunt")) return "taunt";
  if (n("damage_per_exhausted") || n("block_per_exhausted")) return "burn";

  // 2. Then SHAPE — what the card actually does — before any scaling flavour.
  //    Ordering scaling first made 22 cards "rhythm" and 19 "skull", so a Frog
  //    hand was one repeated tile. A class should read from the MIX, not from
  //    every card wearing the class badge.
  const attacks = n("damage") || n("damage_per_wound") || n("damage_per_vulnerable")
    || n("damage_per_rhythm") || n("damage_per_foothold") || n("damage_per_ally_foothold");
  if (attacks) {
    if (n("hits") > 1) return "volley";
    if (n("damage") >= 8 || n("timed_damage") >= 10) return "bomb";
    if (n("wound")) return "fire";
    if (n("damage_per_wound")) return "skull";
    if (n("damage_per_vulnerable")) return "target";
    if (n("vulnerable")) return "bow";
    if (n("damage_per_foothold") || n("damage_per_ally_foothold")) return "peak";
    if (n("damage_per_rhythm")) return "rhythm";
    return "sword";
  }

  const climbs = n("grip") || n("ally_grip") || n("timed_grip") || n("grip_per_rhythm");
  if (climbs) {
    // Both of you moving together is the roped feel; hoisting only your partner
    // is the same act as a grapple, so it shares the "lift" face.
    if (n("ally_grip") && n("grip")) return "rope";
    if (n("ally_grip")) return "lift";
    if (n("grip_per_rhythm")) return "rhythm";
    if (n("grip") + n("timed_grip") >= 3) return "ascend";
    return "climb";
  }

  const guards = n("block") || n("ally_block") || n("timed_block")
    || n("timed_ally_block") || n("block_per_play");
  if (guards) {
    if (n("block_per_play")) return "wall";
    if (n("timed_block") || n("timed_ally_block")) return "guard";
    if (n("ally_block") && !n("block")) return "support";
    return "shield";
  }

  // 3. Pure status / utility — nothing else to show, so the effect IS the icon.
  if (n("wound")) return "skull";
  if (n("vulnerable")) return "expose";
  if (n("strength")) return "flask";
  if (n("rhythm")) return "rhythm";
  if (n("ally_energy")) return "rally";
  if (n("draw")) return "stack";
  if (has("timed")) return "timer";
  return "sword";
}

const raw = fs.readFileSync(FILE, "utf8");
const cards = JSON.parse(raw).cards;
const spread = {};
let stamped = 0;
let kept = 0;

const out = raw.split(/\r?\n/).map((line) => {
  const m = line.match(/^(\s*)"([a-z0-9_]+)":\s*\{/);
  if (!m) return line;
  const card = cards[m[2]];
  if (!card) return line;
  if (card.icon && !ALL) {
    kept++;
    spread[card.icon] = (spread[card.icon] || 0) + 1;
    return line;
  }
  const icon = iconFor(card);
  spread[icon] = (spread[icon] || 0) + 1;
  stamped++;
  if (card.icon) {
    // Replace the existing value in place, keeping the field where it sits.
    return line.replace(/"icon":\s*"[a-z0-9_]*"/, `"icon": "${icon}"`);
  }
  const anchor = line.indexOf('",', line.indexOf('"name"'));
  if (anchor === -1) return line;
  return line.slice(0, anchor + 2) + ` "icon": "${icon}",` + line.slice(anchor + 2);
});

const result = out.join("\n");
JSON.parse(result); // refuse to write broken JSON

if (WRITE) {
  fs.writeFileSync(FILE, result, "utf8");
  console.log(`wrote ${FILE}`);
} else {
  console.log("DRY RUN — pass --write to apply\n");
}
console.log(`stamped ${stamped}, kept ${kept} already set\n`);
const rows = Object.entries(spread).sort((a, b) => b[1] - a[1]);
console.log(`${rows.length} distinct icons`);
for (const [k, v] of rows) console.log(`  ${String(v).padStart(3)}  ${k}`);
