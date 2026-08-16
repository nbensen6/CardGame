#!/usr/bin/env node
/**
 * Deepen every beast's climb.
 *
 * Nick, 2026-08-16: "there should be more steps to climb. It seems like I climb
 * one and I can reach the top... there needs to be more dynamic when climbing."
 *
 * He is right: weak points sat at Height 1-3 while climb cards give 1-3 (and the
 * Frog's passive adds another), so a single Leap ended the climb before it
 * started. The climb is the game's signature and it was one card long.
 *
 * The constraint that shapes these numbers is the GRIP TIMER: 5 real seconds to
 * get from one safe hold to the next, wherever they are. So total height can grow
 * freely as long as LEDGE SPACING stays at 2-3 -- each leg is one 5-second push,
 * with a breather on arrival. Depth comes from the number of legs, not from
 * making any single leg impossible.
 *
 *   node tools/cardlab/retune-climb.js          preview
 *   node tools/cardlab/retune-climb.js --write   apply
 */
const fs = require("fs");
const path = require("path");

const FILE = path.join(__dirname, "..", "..", "game", "data", "bosses.json");
const WRITE = process.argv.includes("--write");

// id: [weak_point_height, ledges]
const CLIMB = {
  // quick fights — two or three legs, so a climb is a plan and not a step
  crag_pup: [4, [2]],
  bounder: [4, [2]],
  bramble_hog: [5, [2]],
  root_lurker: [5, [2]],
  sky_snapper: [5, [3]],
  riftling: [6, [2, 4]],
  // elites
  mire_snapper: [6, [3]],
  shifting_idol: [6, [2, 4]],
  frost_sentinel: [7, [2, 5]],
  grove_bear: [7, [3, 5]],
  // Titans — the same leg length, just more of them
  stone_warden: [6, [2, 4]],
  gale_serpent: [9, [3, 6]],
  drowned_colossus: [11, [3, 6, 9]],
  sunken_warden: [13, [3, 6, 9, 11]],
};

const src = fs.readFileSync(FILE, "utf8");
const data = JSON.parse(src);
const lines = src.split(/\r?\n/);

/** Rewrite one key on the line that carries it, within a beast's block. */
function setField(startLine, key, value) {
  for (let i = startLine; i < lines.length; i++) {
    if (/^\s{4}"/.test(lines[i]) && i > startLine) break; // next beast
    // Greedy value, then ask whether the line ended in a comma. A lazy match with
    // an optional trailing `,?` lets the value swallow the comma and the group
    // match empty, which silently deletes the separator and breaks the file.
    const m = lines[i].match(new RegExp(`^(\\s*"${key}":\\s*)(.*)$`));
    if (!m) continue;
    // Some beasts carry `ledges` as a pretty-printed multi-line array. Replacing
    // only the key's line there leaves its old contents orphaned below.
    let last = i;
    if (m[2].trimEnd() === "[" || (m[2].includes("[") && !m[2].includes("]"))) {
      while (last < lines.length && !lines[last].trimStart().startsWith("]")) last++;
      if (last >= lines.length) throw new Error(`unterminated array for ${key}`);
    }
    const hadComma = lines[last].trimEnd().endsWith(",");
    lines.splice(i, last - i + 1, m[1] + JSON.stringify(value) + (hadComma ? "," : ""));
    return true;
  }
  return false;
}

let changed = 0;
for (const [id, [wp, ledges]] of Object.entries(CLIMB)) {
  const b = data.bosses[id];
  if (!b) throw new Error(`no beast ${id}`);
  const start = lines.findIndex((l) => l.trimStart().startsWith(`"${id}":`));
  if (start < 0) throw new Error(`no line for ${id}`);
  const legs = [];
  let prev = 0;
  for (const l of [...ledges, wp]) {
    legs.push(l - prev);
    prev = l;
  }
  console.log(
    `${id.padEnd(18)} height ${String(b.weak_point_height).padStart(2)} -> ${String(wp).padStart(2)}` +
      `   ledges ${JSON.stringify(b.ledges || [])} -> ${JSON.stringify(ledges)}` +
      `   legs ${legs.join("+")}`
  );
  if (Math.max(...legs) > 3) throw new Error(`${id}: a ${Math.max(...legs)}-height leg is longer than one grip window`);
  setField(start, "weak_point_height", wp);
  setField(start, "ledges", ledges);
  changed++;
}

console.log(`\n${changed} beasts retuned.`);
if (WRITE) {
  const out = lines.join("\n");
  JSON.parse(out);
  fs.writeFileSync(FILE, out, "utf8");
  console.log(`written -> ${FILE}`);
} else {
  console.log("(dry run -- pass --write to apply)");
}
