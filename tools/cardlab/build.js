#!/usr/bin/env node
/**
 * Card Lab — a design dashboard for the titan-slayer deckbuilder.
 *
 * Reads game/data/*.json and emits a single self-contained HTML file.
 * No dependencies, no server, no install. Run it, open the file.
 *
 *   node tools/cardlab/build.js
 *   → tools/cardlab/cardlab.html
 *
 * Built for CREATIVITY first (what design space is empty?) and balance second
 * (where do the numbers clump?). Nothing here changes game data — it only reads.
 */

const fs = require("fs");
const path = require("path");

const ROOT = path.resolve(__dirname, "..", "..");
const DATA = path.join(ROOT, "game", "data");
const OUT = path.join(__dirname, "cardlab.html");

const readJson = (f) => JSON.parse(fs.readFileSync(path.join(DATA, f), "utf8"));

const cardsFile = readJson("cards.json");
const charsFile = readJson("characters.json");
const relicsFile = safe(() => readJson("relics.json"), { relics: {} });
const bossesFile = safe(() => readJson("bosses.json"), {});
const eventsFile = safe(() => readJson("events.json"), { events: {} });
const potionsFile = safe(() => readJson("potions.json"), { potions: {}, pool: [] });
const enchantsFile = safe(() => readJson("enchants.json"), { enchants: {} });

const RELICS = relicsFile.relics || {};
const RELIC_POOL = new Set(relicsFile.pool || []);
const EVENTS = eventsFile.events || {};
const POTIONS = potionsFile.potions || {};
const ENCHANTS = enchantsFile.enchants || {};
const POTION_POOL = new Set(potionsFile.pool || []);

function safe(fn, fallback) {
  try { return fn(); } catch { return fallback; }
}

const CARDS = cardsFile.cards;
const CHARS = charsFile.characters;
const CHAR_ORDER = charsFile.order || Object.keys(CHARS);
const GLOBAL_POOL = cardsFile.reward_pool || [];
const GLOBAL_STARTER = cardsFile.starter_deck || [];

/* ---------- field taxonomy -------------------------------------------------
   Grouped so the coverage grid reads as design space rather than a schema dump.
   Anything not listed still shows up under "other" — the tool must never hide a
   field just because this list is stale. */
const GROUPS = [
  ["Damage",   ["damage", "hits", "strength", "timed_damage"]],
  ["Defense",  ["block", "block_per_play", "taunt", "ally_block",
                "timed_block", "timed_ally_block"]],
  ["Climb",    ["grip", "timed_grip", "ally_grip", "pull_ally", "sac_ally_grip"]],
  ["Ally",     ["ally_block", "ally_energy", "ally_grip", "pull_ally",
                "sac_ally_grip", "damage_per_ally_foothold", "timed_ally_block"]],
  ["Status",   ["vulnerable", "wound", "rhythm"]],
  ["Scaling",  ["damage_per_vulnerable", "damage_per_foothold", "damage_per_wound",
                "damage_per_rhythm", "damage_per_ally_foothold", "grip_per_rhythm",
                "block_per_play"]],
  ["Tempo",    ["draw", "cost"]],
  ["Gadget",   ["create", "prepare", "meld", "exhaust_pick", "cheapen_pick",
                "cheapen_amount"]],
  ["Timing",   ["timed", "timed_hits", "timed_damage", "timed_grip",
                "timed_block", "timed_ally_block"]],
];
const META_FIELDS = new Set(["name", "type", "text", "icon", "target", "cost", "rarity"]);
const RARITY_WEIGHT = { common: 55, uncommon: 35, rare: 10 }; // mirrors Run.RARITY_WEIGHT

/* ---------- build the card model ----------------------------------------- */
const allFields = new Set();
for (const c of Object.values(CARDS)) Object.keys(c).forEach((k) => allFields.add(k));

const ownersOf = {};   // cardId -> { classId: {starter:n, pool:bool} }
for (const [cid, ch] of Object.entries(CHARS)) {
  for (const id of ch.starter_deck || []) {
    ownersOf[id] ??= {};
    ownersOf[id][cid] ??= { starter: 0, pool: false };
    ownersOf[id][cid].starter++;
  }
  for (const id of ch.reward_pool || []) {
    ownersOf[id] ??= {};
    ownersOf[id][cid] ??= { starter: 0, pool: false };
    ownersOf[id][cid].pool = true;
  }
}

// Cards a card can build into your hand are reachable even if never drafted.
const createdBy = {};
for (const [id, c] of Object.entries(CARDS)) {
  const made = c.create || c.prepare;
  if (made) (createdBy[made] ??= []).push(id);
}

// Status/curse cards (backlog #27) are never drafted — an event INFLICTS one
// via curse_card, so that's their reachability path, same shape createdBy
// gives a `create`/`prepare` target.
const cursedBy = {};
for (const [eid, ev] of Object.entries(EVENTS)) {
  for (const choice of ev.choices || []) {
    const id = choice.effects && choice.effects.curse_card;
    if (id) (cursedBy[id] ??= []).push(eid);
  }
}

const model = Object.entries(CARDS).map(([id, c]) => {
  const owners = ownersOf[id] || {};
  const classList = Object.keys(owners);
  const inGlobalPool = GLOBAL_POOL.includes(id);
  const inGlobalStarter = GLOBAL_STARTER.includes(id);
  const built = createdBy[id] || [];
  const cursed = cursedBy[id] || [];

  // Signature = lives in exactly one class and isn't handed out neutrally.
  const signature = classList.length === 1 && !inGlobalPool;
  const shared = classList.length >= 3 || inGlobalPool;

  const used = Object.keys(c).filter(
    (k) => !META_FIELDS.has(k) && c[k] !== 0 && c[k] !== false && c[k] !== ""
  );

  return {
    id,
    name: c.name || id,
    rarity: c.rarity || "common",
    type: c.type || "—",
    cost: c.cost ?? 0,
    text: c.text || "",
    target: c.target || "—",
    icon: c.icon || null,
    timed: !!c.timed,
    fields: c,
    used,
    classes: classList,
    owners,
    inGlobalPool,
    inGlobalStarter,
    builtBy: built,
    cursedBy: cursed,
    signature,
    shared,
    reachable:
      classList.length > 0 || inGlobalPool || inGlobalStarter
      || built.length > 0 || cursed.length > 0,
  };
});

const byId = Object.fromEntries(model.map((m) => [m.id, m]));

/* ---------- analyses ------------------------------------------------------ */

// --- ART -------------------------------------------------------------------
// Which cards have art of their own, and how many share the icon they fall back
// to. 187 cards currently share 33 icons; eighteen of them wear the same "lift"
// glyph. Sorting the work by that number is the whole point of the Art tab —
// painting the card that eighteen others look identical to buys eighteen times
// what painting a unique one does.
const ART_DIR = path.join(ROOT, "game", "assets", "cardart");
const haveArt = new Set(
  (fs.existsSync(ART_DIR) ? fs.readdirSync(ART_DIR) : [])
    .filter((f) => f.toLowerCase().endsWith(".png"))
    .map((f) => f.slice(0, -4))
);
const iconUse = {};
for (const [id, c] of Object.entries(CARDS)) {
  const k = c.icon || "(none)";
  iconUse[k] = (iconUse[k] || 0) + 1;
}
const artRows = Object.entries(CARDS).map(([id, c]) => ({
  id,
  name: c.name || id,
  type: c.type || "",
  rarity: c.rarity || "common",
  icon: c.icon || "",
  art: haveArt.has(id),
  shared: iconUse[c.icon || "(none)"] || 1,
})).sort((a, b) =>
  (a.art === b.art ? 0 : a.art ? 1 : -1) ||     // undone first
  b.shared - a.shared ||                         // then the most-shared icon
  a.name.localeCompare(b.name));

// Cost curve, overall and per class (weighted by copies in the starter deck).
function costCurve(ids) {
  const out = {};
  for (const id of ids) {
    const c = byId[id];
    if (!c) continue;
    out[c.cost] = (out[c.cost] || 0) + 1;
  }
  return out;
}

// A card that BUILDS a timed card (Build Grapple → Grappling Hook) puts a timing
// bar in your hand just as surely as a timed card does. Counting only `timed`
// undercounts the Goblin, whose identity is building his tools before using them.
function reachesTiming(card, seen) {
  seen ??= new Set();
  if (!card || seen.has(card.id)) return false;
  if (card.timed) return true;
  seen.add(card.id);
  const made = card.fields.create || card.fields.prepare;
  return made ? reachesTiming(byId[made], seen) : false;
}

const classStats = CHAR_ORDER.map((cid) => {
  const ch = CHARS[cid];
  const starter = ch.starter_deck || [];
  const pool = ch.reward_pool || [];
  const starterCards = starter.map((i) => byId[i]).filter(Boolean);
  const poolCards = pool.map((i) => byId[i]).filter(Boolean);

  const timedInStarter = starterCards.filter((c) => reachesTiming(c)).length;
  const directTimed = starterCards.filter((c) => c.timed).length;
  const sigInPool = poolCards.filter((c) => c.signature).length;
  const sharedInPool = poolCards.filter((c) => c.shared).length;

  const totalEnergy = starterCards.reduce((s, c) => s + c.cost, 0);

  // How the pool is split by rarity, and — more useful — how often each rarity
  // is actually OFFERED once the reward weights are applied. A pool that is 15%
  // rare still only shows a rare in a few percent of slots.
  const rarityMix = { common: 0, uncommon: 0, rare: 0 };
  for (const id of pool) {
    const c = byId[id];
    if (c) rarityMix[c.rarity] = (rarityMix[c.rarity] || 0) + 1;
  }
  // Distinct icons this class's pool shows. Identity should read from the MIX.
  const icons = {};
  for (const id of new Set([...starter, ...pool])) {
    const c = byId[id];
    if (c && c.icon) icons[c.icon] = (icons[c.icon] || 0) + 1;
  }
  const iconTop = Object.entries(icons).sort((a, b) => b[1] - a[1]);

  let weighted = 0;
  for (const r of Object.keys(rarityMix)) weighted += rarityMix[r] * (RARITY_WEIGHT[r] ?? 55);
  const offerRate = {};
  for (const r of Object.keys(rarityMix)) {
    offerRate[r] = weighted
      ? Math.round(((rarityMix[r] * (RARITY_WEIGHT[r] ?? 55)) / weighted) * 100)
      : 0;
  }

  return {
    id: cid,
    name: ch.name,
    desc: ch.desc || "",
    passive: ch.passive || { type: "none", value: 0 },
    starter,
    pool,
    starterSize: starter.length,
    poolSize: pool.length,
    timedInStarter,
    directTimed,
    builtTimed: timedInStarter - directTimed,
    timedPct: starter.length ? Math.round((timedInStarter / starter.length) * 100) : 0,
    sigInPool,
    sharedInPool,
    identityPct: pool.length ? Math.round((sigInPool / pool.length) * 100) : 0,
    avgCost: starter.length ? (totalEnergy / starter.length).toFixed(2) : "0",
    rarityMix,
    offerRate,
    iconCount: iconTop.length,
    iconTop: iconTop.slice(0, 4),
    curve: costCurve(starter),
  };
});

// Coverage grid: field-group × class. Counts distinct cards in that class's
// pool+starter that touch any field in the group. Zeros are the design prompts.
const coverage = GROUPS.map(([group, fields]) => {
  const row = { group, fields, cells: {} };
  for (const cs of classStats) {
    const ids = new Set([...cs.starter, ...cs.pool]);
    let n = 0;
    for (const id of ids) {
      const c = byId[id];
      if (c && fields.some((f) => c.used.includes(f))) n++;
    }
    row.cells[cs.id] = n;
  }
  row.total = model.filter((c) => fields.some((f) => c.used.includes(f))).length;
  return row;
});

// Field usage across the whole catalog — the "untapped levers" view.
const fieldUsage = [...allFields]
  .filter((f) => !META_FIELDS.has(f))
  .map((f) => {
    const cards = model.filter((c) => c.used.includes(f));
    return { field: f, count: cards.length, cards: cards.map((c) => c.id) };
  })
  .sort((a, b) => a.count - b.count);

// Fields the design doc says exist but nothing uses yet.
const KNOWN_UNUSED = [
  "exhaust", "cost_scaling", "draw_on_hit", "energy_refund", "self_damage",
  "conditional_at_weakpoint", "block_scaling_damage", "status_on_self",
];

/* ---------- health checks ------------------------------------------------- */
const checks = [];

const orphans = model.filter((c) => !c.reachable);
if (orphans.length) {
  checks.push({
    level: "warn",
    title: `${orphans.length} unreachable card${orphans.length > 1 ? "s" : ""}`,
    detail:
      "Defined in cards.json but in no starter deck, no reward pool, and not built by another card. Dead content unless wired in.",
    items: orphans.map((c) => `${c.name} (${c.id})`),
  });
}

// A relic is only ever offered from `pool` (Content.relic_pool()) — an entry in
// `relics` missing from `pool` is defined but can never be picked up in a run.
const relicOrphans = Object.entries(RELICS).filter(([id]) => !RELIC_POOL.has(id));
if (relicOrphans.length) {
  checks.push({
    level: "warn",
    title: `${relicOrphans.length} unreachable relic${relicOrphans.length > 1 ? "s" : ""}`,
    detail:
      "Defined in relics.json but missing from its offer pool. Dead content unless added to `pool`.",
    items: relicOrphans.map(([id, r]) => `${r.name || id} (${id})`),
  });
}

// Relics, potions and enchantments are all {name, effect, value, text}: a named
// effect the engine reads generically rather than a special case per id. Being
// the same shape is exactly why they belong on one screen — it makes "which
// effects does the engine actually understand" answerable at a glance.
const ITEMS = [
  ...Object.entries(RELICS).map(([id, r]) => ({
    kind: "relic", id, name: r.name || id, effect: r.effect || "",
    value: r.value, text: r.text || "", offered: RELIC_POOL.has(id),
  })),
  ...Object.entries(POTIONS).map(([id, r]) => ({
    kind: "potion", id, name: r.name || id, effect: r.effect || "",
    value: r.value, text: r.text || "", offered: POTION_POOL.has(id),
  })),
  ...Object.entries(ENCHANTS).map(([id, r]) => ({
    // Enchantments have no offer pool: they are attached to a card by whatever
    // grants them, so "offered" is not a question you can ask of the data.
    kind: "enchant", id, name: r.name || id, effect: r.effect || "",
    value: r.value, text: r.text || "", offered: null,
  })),
];

// Same rule as relics: Content offers potions from `pool`, so a potion missing
// from it is defined and unreachable.
const potionOrphans = Object.entries(POTIONS).filter(([id]) => !POTION_POOL.has(id));
if (potionOrphans.length) {
  checks.push({
    level: "warn",
    title: `${potionOrphans.length} unreachable potion${potionOrphans.length > 1 ? "s" : ""}`,
    detail:
      "Defined in potions.json but missing from its `pool`. Dead content unless added.",
    items: potionOrphans.map(([id, r]) => `${r.name || id} (${id})`),
  });
}

// An effect nothing reads is dead weight, and the two files disagree about how
// many readers they have: potions are all consumed by Combat.use_potion, while
// enchants.json says only `sure` has a /core consumer today and `wide` is
// waiting on the card-face work item 3 still owns. Surface that rather than let
// it sit in a comment nobody opens.
const enchantEffects = Object.values(ENCHANTS).map((e) => e.effect);
if (enchantEffects.length) {
  checks.push({
    level: "info",
    title: `${enchantEffects.length} enchantment effect${enchantEffects.length > 1 ? "s" : ""}, ${Object.keys(ENCHANTS).length} enchantment${Object.keys(ENCHANTS).length > 1 ? "s" : ""}`,
    detail:
      "Enchantments are attached to a single card, so they have no offer pool and cannot be structurally unreachable. Check each effect has a consumer in /core before counting it as shipped.",
    items: Object.entries(ENCHANTS).map(([id, e]) => `${e.name || id} — ${e.effect} ${e.value}`),
  });
}

// Events have no separate offer-pool the way cards/relics do — Content.list_events()
// draws directly from every key in events.json, so no event can be structurally
// unreachable under the current architecture. Counted below for visibility (and so
// this stays true rather than assumed if events ever gain a gated pool later), but
// there is nothing here for a health check to warn about today.
const eventOrphans = [];

// Cost clumping — the single most useful balance signal at this stage.
const curveAll = {};
for (const c of model) curveAll[c.cost] = (curveAll[c.cost] || 0) + 1;
const topCost = Object.entries(curveAll).sort((a, b) => b[1] - a[1])[0];
if (topCost && topCost[1] / model.length > 0.5) {
  checks.push({
    level: "warn",
    title: `${Math.round((topCost[1] / model.length) * 100)}% of cards cost ${topCost[0]}`,
    detail:
      "With 3 energy a turn, a flat cost curve means every turn plays the same number of cards and 'what do I cut?' never becomes a real decision. Spread the curve to create tension.",
    items: [
      Object.entries(curveAll)
        .sort((a, b) => a[0] - b[0])
        .map(([k, v]) => `cost ${k}: ${v}`)
        .join("  ·  "),
    ],
  });
}

// Same mechanic, two names in player-facing text.
const woundCards = model.filter((c) => c.used.includes("wound"));
const saysWound = woundCards.filter((c) => /wound/i.test(c.text));
const saysPoison = woundCards.filter((c) => /poison/i.test(c.text));
if (saysWound.length && saysPoison.length) {
  checks.push({
    level: "warn",
    title: "One mechanic, two names on the card face",
    detail:
      "The `wound` field is called 'Wound' on some cards and 'Poison' on others. Players will read these as different mechanics — and the Vine-Weaver's whole kit scales off it.",
    items: [
      `Says "Wound": ${saysWound.map((c) => c.name).join(", ")}`,
      `Says "Poison": ${saysPoison.map((c) => c.name).join(", ")}`,
    ],
  });
}

// Neutral dilution — how much of each class's identity pool is generic filler.
const diluted = classStats.filter((c) => c.identityPct < 50);
if (diluted.length) {
  checks.push({
    level: "info",
    title: "Class reward pools are mostly shared cards",
    detail:
      "Each class drafts from its own pool, but a large share of every pool is the same neutral set. The lower this number, the more two runs of different classes feel alike.",
    items: classStats.map(
      (c) => `${c.name}: ${c.identityPct}% signature (${c.sigInPool}/${c.poolSize})`
    ),
  });
}

// Class cards leaking into the global pool undercuts the archetype design.
const leaked = model.filter((c) => c.inGlobalPool && c.classes.length > 0 && c.classes.length < 3);
if (leaked.length) {
  checks.push({
    level: "info",
    title: `${leaked.length} class cards also sit in the global reward pool`,
    detail:
      "characters.json gives each class its own pool so you build toward an archetype. These cards are also in cards.json's global pool — if both are live, class identity blurs. If the global pool is legacy, it may be dead data.",
    items: leaked.map((c) => `${c.name} → ${c.classes.join(", ")}`),
  });
}

// Since 2026-08-16 the combat card face does NOT print this text — CardView
// writes its own sentence from the live preview. This text is what you read in
// the inspector, in the Card Lab, and on a card you are being OFFERED (reward,
// shop, campfire have no combat state to preview against), and that reward card
// is the tightest of those: a 148x224 face at ~40 characters a line.
//
// Cards that read well sit around 30-50; past ~55 the body crowds the art and
// past ~70 it risks clipping on the reward screen. This is the check that stops
// mechanics work from quietly producing cards nobody can read.
const TEXT_COMFORTABLE = 55;
const TEXT_MAX = 70;
const longText = model
  .filter((c) => c.text.length > TEXT_COMFORTABLE)
  .sort((a, b) => b.text.length - a.text.length);
if (longText.length) {
  const over = longText.filter((c) => c.text.length > TEXT_MAX);
  checks.push({
    level: over.length ? "warn" : "info",
    title: `${longText.length} cards have text longer than ${TEXT_COMFORTABLE} characters`,
    detail:
      `A reward card is 148x224 at roughly 40 characters a line, so ~55 already wraps ` +
      `to three lines. Length now comes almost entirely from scaling clauses ` +
      `("and an additional 3 per Rhythm"), so a card over the line is usually one that ` +
      `scales twice — worth asking whether it needs both. ` +
      `${over.length} of these exceed ${TEXT_MAX} and should be rewritten shorter. ` +
      `Regenerate all of them with tools/cardlab/rewrite-text.js.`,
    items: longText.slice(0, 20).map((c) => `${c.text.length}  ${c.name} — "${c.text}"`),
  });
}

// Icon collisions. A hand is scanned, not read — if a third of it wears the same
// face, the icons are decoration rather than information. Watch the per-class
// numbers more than the catalog ones: identity should come from a class's icon MIX,
// not from every card of that class carrying one badge.
const noIcon = model.filter((c) => !c.icon && c.reachable);
const iconSpread = {};
for (const c of model) if (c.icon && c.reachable) iconSpread[c.icon] = (iconSpread[c.icon] || 0) + 1;
const iconRows = Object.entries(iconSpread).sort((a, b) => b[1] - a[1]);
const draftable = model.filter((c) => c.reachable).length;
if (iconRows.length) {
  const worst = iconRows[0];
  const share = Math.round((worst[1] / draftable) * 100);
  checks.push({
    level: noIcon.length || share > 20 ? "warn" : "info",
    title: `${iconRows.length} icons across ${draftable} draftable cards ` +
      `(most common: ${worst[0]}, ${share}%)`,
    detail:
      "Before the 2026-08-15 audit this was 14 icons, with 27 cards sharing one face. " +
      (noIcon.length
        ? `${noIcon.length} cards still declare no icon and fall back to a guess. `
        : "Every draftable card declares an icon. ") +
      "Per-class spread is on the Overview; a class wants a distinctive mix, not one badge.",
    items: [
      iconRows.map(([k, v]) => `${k} ${v}`).join("  ·  "),
      ...(noIcon.length ? ["no icon: " + noIcon.map((c) => c.name).join(", ")] : []),
    ],
  });
}

// Design-doc drift.
const docDrift = [];
for (const cs of classStats) {
  if (cs.passive?.type && cs.passive.type !== "none") {
    docDrift.push(`${cs.name}: passive = ${cs.passive.type} (${cs.passive.value})`);
  }
}
checks.push({
  level: "info",
  title: "Live passives (verify against design/cards-and-classes.md)",
  detail:
    "The design doc lists Vine-Weaver's passive as 'none'; the data says otherwise. Docs drift — this panel is the source of truth.",
  items: docDrift,
});

/* ---------- gap finder — the creativity engine ---------------------------- */
// Every (class × field-group) cell with zero coverage is an unbuilt card.
const gaps = [];
for (const row of coverage) {
  for (const cs of classStats) {
    if (row.cells[cs.id] === 0) {
      gaps.push({ group: row.group, cls: cs.name, clsId: cs.id, fields: row.fields });
    }
  }
}

// Combination gaps: pairs of groups that no single card yet combines.
const comboGaps = [];
for (let i = 0; i < GROUPS.length; i++) {
  for (let j = i + 1; j < GROUPS.length; j++) {
    const [ga, fa] = GROUPS[i];
    const [gb, fb] = GROUPS[j];
    const both = model.filter(
      (c) => fa.some((f) => c.used.includes(f)) && fb.some((f) => c.used.includes(f))
    );
    if (both.length === 0) comboGaps.push({ a: ga, b: gb });
    else if (both.length === 1) comboGaps.push({ a: ga, b: gb, only: both[0].name });
  }
}

/* ---------- emit ---------------------------------------------------------- */
const payload = {
  generated: new Date().toISOString(),
  cards: model.map((c) => ({
    id: c.id, name: c.name, type: c.type, rarity: c.rarity, cost: c.cost, text: c.text,
    target: c.target, timed: c.timed, used: c.used, classes: c.classes,
    signature: c.signature, shared: c.shared, reachable: c.reachable,
    builtBy: c.builtBy, inGlobalPool: c.inGlobalPool,
    fields: c.fields,
    hasArt: haveArt.has(c.id),
    iconShared: iconUse[c.icon || "(none)"] || 1,
    icon: c.icon || "",
  })),
  classes: classStats,
  coverage,
  fieldUsage,
  knownUnused: KNOWN_UNUSED,
  checks,
  gaps,
  comboGaps,
  curveAll,
  items: ITEMS,
  counts: {
    cards: model.length,
    timed: model.filter((c) => c.timed).length,
    classes: classStats.length,
    relics: Object.keys(RELICS).length,
    potions: Object.keys(POTIONS).length,
    enchants: Object.keys(ENCHANTS).length,
    events: Object.keys(EVENTS).length,
    bosses: Object.keys(bossesFile.bosses || bossesFile || {}).length,
    unreachable: {
      cards: orphans.length, relics: relicOrphans.length,
      events: eventOrphans.length, potions: potionOrphans.length,
    },
  },
};

fs.writeFileSync(OUT, renderHtml(payload), "utf8");
console.log(`Card Lab → ${OUT}`);
console.log(
  `  ${payload.counts.cards} cards · ${payload.counts.timed} timed · ` +
  `${payload.counts.relics} relics · ${payload.counts.potions} potions · ` +
  `${payload.counts.enchants} enchants · ` +
  `${payload.counts.classes} classes · ${checks.length} findings · ${gaps.length} open cells`
);
console.log(
  `  unreachable: ${payload.counts.unreachable.cards} cards · ` +
  `${payload.counts.unreachable.relics} relics · ${payload.counts.unreachable.events} events`
);

function renderHtml(data) {
  return `<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Card Lab — titan-slayer</title>
<style>
:root{
  --bg:#12100e; --panel:#1b1815; --panel2:#241f1a; --line:#332b24;
  --ink:#efe7dc; --dim:#a2937f; --faint:#6d6155;
  --gold:#d8a24a; --moss:#7fa86a; --rust:#c96442; --sky:#6f9fc4;
  --mono:ui-monospace,"Cascadia Mono",Consolas,monospace;
  --sans:system-ui,-apple-system,"Segoe UI",sans-serif;
}
*{box-sizing:border-box}
body{margin:0;background:var(--bg);color:var(--ink);font-family:var(--sans);font-size:15px;line-height:1.55}
.wrap{max-width:1240px;margin:0 auto;padding:28px 22px 90px}
header{display:flex;flex-wrap:wrap;align-items:baseline;gap:14px;border-bottom:2px solid var(--gold);padding-bottom:14px;margin-bottom:8px}
h1{font-size:1.5rem;margin:0;letter-spacing:-.02em}
.sub{font-family:var(--mono);font-size:11px;color:var(--dim);letter-spacing:.1em;text-transform:uppercase}
.stamp{margin-left:auto;font-family:var(--mono);font-size:11px;color:var(--faint)}
/* A card's art, opened from its tile in the Hunters deck. */
label.drop{display:block;margin-top:4px;padding:9px 11px;border:1px dashed var(--line);
  border-radius:5px;cursor:pointer;font-size:12.5px;color:var(--dim)}
label.drop:hover{border-color:var(--gold,#c8a44a);color:var(--ink)}
label.drop input{display:none}
.upstat{font-size:12px;color:var(--gold,#c8a44a);min-height:15px}
.dcard[data-id]{cursor:pointer}
.dcard[data-id]:hover{border-color:var(--gold,#c8a44a)}
.dcard[data-id]:focus-visible{outline:2px solid var(--sky,#6cf);outline-offset:2px}
.dcard.hasart b::after{content:" *";color:var(--gold,#c8a44a);font-size:11px}
.artmodal{position:fixed;inset:0;background:rgba(6,7,9,.86);display:none;
  align-items:center;justify-content:center;z-index:40;padding:24px}
.artmodal.on{display:flex}
.artmodal .box{background:var(--panel,#191b20);border:1px solid var(--line);
  border-radius:8px;max-width:min(620px,94vw);width:100%;overflow:hidden;
  max-height:92vh;display:flex;flex-direction:column}
/* Capped, so the filename underneath is never below the fold. A modal you
   have to scroll to read the one line you opened it for is a modal that
   failed. */
.artmodal img{width:100%;aspect-ratio:4/3;max-height:56vh;object-fit:contain;background:#0d0e11;display:block}
.artmodal img.has{object-fit:cover}
.artmodal .cap{padding:14px 18px 18px;display:flex;flex-direction:column;gap:7px}
.artmodal h3{margin:0;font-size:17px}
.artmodal code{font-size:12px;color:var(--gold,#c8a44a);word-break:break-all}
.artmodal .why{font-size:12.5px;color:var(--dim);line-height:1.5}
.artmodal button.x{position:absolute;top:16px;right:20px;background:none;border:0;
  color:#fff;font-size:26px;cursor:pointer;line-height:1}
nav{display:flex;gap:2px;flex-wrap:wrap;margin:18px 0 22px;border-bottom:1px solid var(--line)}
nav button{background:none;border:0;border-bottom:2px solid transparent;color:var(--dim);
  font-family:var(--mono);font-size:11px;letter-spacing:.12em;text-transform:uppercase;
  padding:9px 14px;cursor:pointer}
nav button:hover{color:var(--ink)}
nav button.on{color:var(--gold);border-bottom-color:var(--gold)}
nav button:focus-visible{outline:2px solid var(--sky);outline-offset:-2px}
section{display:none} section.on{display:block}
h2{font-size:1.05rem;margin:26px 0 10px;letter-spacing:-.01em}
h2:first-child{margin-top:0}
p.note{color:var(--dim);max-width:74ch;margin:0 0 14px}
.grid{display:grid;gap:12px}
.stats{grid-template-columns:repeat(auto-fit,minmax(120px,1fr))}
.stat{background:var(--panel);border:1px solid var(--line);border-radius:3px;padding:12px 14px}
.stat b{display:block;font-size:1.5rem;font-family:var(--mono);color:var(--gold);line-height:1.1}
.stat span{font-family:var(--mono);font-size:10px;letter-spacing:.1em;text-transform:uppercase;color:var(--dim)}
.scroll{overflow-x:auto;border:1px solid var(--line);border-radius:3px;background:var(--panel)}
table{border-collapse:collapse;width:100%;font-size:13px}
th,td{text-align:left;padding:7px 11px;border-bottom:1px solid var(--line);vertical-align:top}
thead th{position:sticky;top:0;background:var(--panel2);font-family:var(--mono);font-size:10px;
  letter-spacing:.1em;text-transform:uppercase;color:var(--dim);cursor:pointer;white-space:nowrap;z-index:1}
thead th:hover{color:var(--ink)}
tbody tr:hover{background:var(--panel2)}
td.num,th.num{font-family:var(--mono);font-variant-numeric:tabular-nums;text-align:right}
.tag{display:inline-block;font-family:var(--mono);font-size:9.5px;letter-spacing:.06em;
  padding:2px 6px;border-radius:2px;background:var(--panel2);color:var(--dim);border:1px solid var(--line);margin:1px 2px 1px 0}
.tag.t{background:#2e2412;color:var(--gold);border-color:#4a3a1c}
.tag.sig{background:#1d2a18;color:var(--moss);border-color:#2f4426}
.tag.sh{background:#1a2530;color:var(--sky);border-color:#27384a}
.tag.r-c{background:#20201d;color:var(--dim);border-color:#33322c}
.tag.r-u{background:#16242c;color:var(--sky);border-color:#223945}
.tag.r-r{background:#2e2412;color:var(--gold);border-color:#4a3a1c}
.bar{display:flex;align-items:center;gap:8px}
.bar i{display:block;height:9px;background:var(--gold);border-radius:1px;min-width:2px}
.bar.m i{background:var(--moss)} .bar.s i{background:var(--sky)}
.controls{display:flex;flex-wrap:wrap;gap:8px;margin-bottom:12px;align-items:center}
input[type=search],select{background:var(--panel);border:1px solid var(--line);color:var(--ink);
  border-radius:3px;padding:7px 10px;font-family:var(--sans);font-size:13px}
input[type=search]{min-width:220px}
input:focus-visible,select:focus-visible{outline:2px solid var(--sky);outline-offset:1px}
.chk{border-left:3px solid var(--line);background:var(--panel);padding:12px 15px;margin-bottom:10px;border-radius:0 3px 3px 0}
.chk.warn{border-left-color:var(--rust)} .chk.info{border-left-color:var(--sky)}
.chk h3{margin:0 0 4px;font-size:.97rem}
.chk p{margin:0 0 8px;color:var(--dim);font-size:13px;max-width:80ch}
.chk li{font-family:var(--mono);font-size:11.5px;color:var(--dim);margin-bottom:3px}
.chk ul{margin:0;padding-left:18px}
.cov td.z{background:#241416;color:var(--rust);font-weight:700}
.cov td.n{font-family:var(--mono);text-align:center}
.gapgrid{grid-template-columns:repeat(auto-fill,minmax(250px,1fr))}
.gap{background:var(--panel);border:1px solid var(--line);border-left:3px solid var(--rust);
  border-radius:0 3px 3px 0;padding:11px 13px}
.gap b{display:block;font-size:.95rem;margin-bottom:3px}
.gap span{font-family:var(--mono);font-size:10.5px;color:var(--faint)}
.cardtext{color:var(--dim);font-size:12.5px;max-width:38ch}
/* Anything that navigates says so before you click it. */
.go{cursor:pointer}
tr.go:hover{background:var(--panel2)}
tr.go:hover .arrow{opacity:1}
.arrow{font-family:var(--mono);font-size:11px;color:var(--gold);opacity:0;transition:opacity .12s}
.stat.go:hover{border-color:var(--gold)}
.stat.go:hover span{color:var(--gold)}
.go:focus-visible{outline:2px solid var(--sky);outline-offset:-2px}
/* Hunters tab — decks read as decks, not as table rows. */
.hpick{display:flex;flex-wrap:wrap;gap:6px;margin-bottom:18px}
.hpick button{background:var(--panel);border:1px solid var(--line);color:var(--dim);border-radius:3px;
  padding:9px 15px;cursor:pointer;font-family:var(--sans);font-size:14px}
.hpick button:hover{color:var(--ink)}
.hpick button.on{border-color:var(--gold);color:var(--gold);background:var(--panel2)}
.hpick button:focus-visible{outline:2px solid var(--sky);outline-offset:1px}
.ident{background:var(--panel);border:1px solid var(--line);border-radius:3px;padding:14px 16px;margin-bottom:18px}
.ident h2{margin:0 0 4px}
.ident p{margin:0 0 10px;color:var(--dim);max-width:74ch}
.deck{display:grid;gap:9px;grid-template-columns:repeat(auto-fill,minmax(230px,1fr))}
.dcard{background:var(--panel);border:1px solid var(--line);border-left:3px solid var(--faint);
  border-radius:0 3px 3px 0;padding:9px 11px}
.dcard.r-uncommon{border-left-color:var(--sky)}
.dcard.r-rare{border-left-color:var(--gold)}
.dcard .cost{float:right;font-family:var(--mono);font-size:12px;color:var(--gold);
  border:1px solid var(--line);background:var(--panel2);border-radius:50%;
  width:23px;height:23px;line-height:21px;text-align:center;margin-left:8px}
.dcard b{font-size:.93rem}
.dcard .mult{font-family:var(--mono);font-size:12px;color:var(--gold);margin-left:5px}
.dcard .body{color:var(--dim);font-size:12.5px;margin:5px 0 6px}
.dcard .foot{line-height:1.9}
.dcard.dim{opacity:.28}
h3.grp{font-family:var(--mono);font-size:11px;letter-spacing:.12em;text-transform:uppercase;
  color:var(--dim);margin:20px 0 9px;font-weight:400}
details summary{cursor:pointer;font-family:var(--mono);font-size:11px;color:var(--dim);
  letter-spacing:.08em;text-transform:uppercase;padding:6px 0}
details summary:hover{color:var(--ink)}
footer{margin-top:44px;padding-top:16px;border-top:1px solid var(--line);
  font-family:var(--mono);font-size:11px;color:var(--faint)}
/* Phone. The lab is genuinely useful away from the desk — serve.js binds 0.0.0.0
   so it opens over wifi — so tap targets have to be thumb-sized, not mouse-sized.
   Tables already scroll inside .scroll, so nothing here fights horizontal overflow. */
@media (max-width:640px){
  body{font-size:16px}
  .wrap{padding:16px 12px 60px}
  .cardtext{max-width:none}
  .masthead{padding-top:34px}
  nav{position:sticky;top:0;z-index:5;background:var(--bg);margin:14px -12px 18px;padding:0 12px}
  nav button{padding:15px 14px;font-size:12px}      /* ~46px tall: thumb, not cursor */
  input[type=search],select{padding:12px;font-size:16px}  /* 16px stops iOS zooming on focus */
  input[type=search]{min-width:0;flex:1 1 100%}
  .controls{gap:10px}
  .stats{grid-template-columns:repeat(2,1fr)}
  th,td{padding:10px 12px}
  .gapgrid{grid-template-columns:1fr}
}
</style>
</head>
<body>
<div class="wrap">
<header>
  <h1>Card Lab</h1>
  <span class="sub">titan-slayer · design dashboard</span>
  <span class="stamp" id="stamp"></span>
</header>

<nav>
  <button class="on" data-t="overview">Overview</button>
  <button data-t="hunters">Hunters</button>
  <button data-t="cards">Cards</button>
  <button data-t="items">Items</button>
  <button data-t="coverage">Coverage</button>
  <button data-t="gaps">Gaps</button>
  <button data-t="levers">Levers</button>
  <button data-t="health">Health</button>
</nav>

<section class="on" id="overview"></section>
<section id="hunters"></section>
<section id="cards"></section>
<section id="items"></section>
<section id="coverage"></section>
<section id="gaps"></section>
<section id="levers"></section>
<section id="health"></section>

<div class="artmodal" id="artmodal"><button class="x" id="artx" aria-label="Close">&times;</button><div class="box" id="artbox"></div></div>
<footer>Generated from game/data/*.json — read-only. Re-run <code>node tools/cardlab/build.js</code> after editing card data.</footer>
</div>

<script id="payload" type="application/json">${JSON.stringify(data).replace(/</g, "\\u003c")}</script>
<script>
const D = JSON.parse(document.getElementById("payload").textContent);
const $ = (s,r=document)=>r.querySelector(s);
const esc = s => String(s).replace(/[&<>"]/g, c => ({"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;"}[c]));
document.getElementById("stamp").textContent = "generated " + new Date(D.generated).toLocaleString();

/* nav. goTab is the one way tabs change, so anything anywhere on the page can
   send you somewhere else — a class row jumps to that hunter, a stat tile jumps
   to the list it counts. */
function goTab(id){
  document.querySelectorAll("nav button").forEach(x=>x.classList.toggle("on",x.dataset.t===id));
  document.querySelectorAll("section").forEach(s=>s.classList.toggle("on",s.id===id));
  window.scrollTo({top:0});
}
document.querySelectorAll("nav button").forEach(b=>b.onclick=()=>goTab(b.dataset.t));

/* ---- overview ---- */
(function(){
  const c = D.counts;
  const maxCurve = Math.max(...Object.values(D.curveAll));
  const curve = Object.entries(D.curveAll).sort((a,b)=>a[0]-b[0]).map(([k,v])=>
    \`<tr><td class="num">\${k}</td><td class="num">\${v}</td>
     <td><div class="bar"><i style="width:\${(v/maxCurve*300).toFixed(0)}px"></i></div></td></tr>\`).join("");

  const cls = D.classes.map(k=>{
    const cv = Object.entries(k.curve).sort((a,b)=>a[0]-b[0])
      .map(([cost,n])=>\`\${cost}:\${n}\`).join(" · ");
    return \`<tr class="go" data-hunter="\${k.id}" tabindex="0" role="button">
      <td><b>\${esc(k.name)}</b> <span class="arrow">-&gt;</span><div class="cardtext">\${esc(k.desc)}</div></td>
      <td><span class="tag">\${esc(k.passive.type)} \${k.passive.value||""}</span></td>
      <td class="num">\${k.starterSize}</td>
      <td class="num">\${k.avgCost}</td>
      <td><div class="bar"><i style="width:\${k.timedPct*1.2}px"></i><span class="sub">\${k.timedPct}%\${k.builtTimed?" ("+k.directTimed+"+"+k.builtTimed+" built)":""}</span></div></td>
      <td><div class="bar m"><i style="width:\${k.identityPct*1.2}px"></i><span class="sub">\${k.identityPct}%</span></div></td>
      <td class="cardtext"><span class="tag r-c">\${k.rarityMix.common} C</span><span class="tag r-u">\${k.rarityMix.uncommon} U</span><span class="tag r-r">\${k.rarityMix.rare} R</span>
        <div class="sub">offered \${k.offerRate.common}/\${k.offerRate.uncommon}/\${k.offerRate.rare}%</div></td>
      <td class="cardtext"><b>\${k.iconCount}</b> icons
        <div class="sub">\${k.iconTop.map(t=>esc(t[0])+" "+t[1]).join(" · ")}</div></td>
      <td class="cardtext">\${cv}</td></tr>\`;
  }).join("");

  $("#overview").innerHTML = \`
   <div class="grid stats">
     <div class="stat go" data-cards="{}"><b>\${c.cards}</b><span>cards</span></div>
     <div class="stat go" data-cards='{"kind":"timed"}'><b>\${c.timed}</b><span>timed</span></div>
     <div class="stat go" data-tab="hunters"><b>\${c.classes}</b><span>classes</span></div>
     <div class="stat go" data-items="relic"><b>\${c.relics}</b><span>relics</span></div>
     <div class="stat go" data-items="potion"><b>\${c.potions}</b><span>potions</span></div>
     <div class="stat go" data-items="enchant"><b>\${c.enchants}</b><span>enchants</span></div>
     <div class="stat go" data-tab="gaps"><b>\${D.gaps.length}</b><span>empty cells</span></div>
     <div class="stat go" data-tab="health"><b>\${D.checks.length}</b><span>findings</span></div>
   </div>
   <h2>Classes</h2>
   <p class="note">Click a class to open its full deck. Timed % is how much of the starter deck runs a
     timing bar — your "double timing" density. Identity % is how much of the class's reward pool is
     unique to it rather than shared filler.</p>
   <div class="scroll"><table><thead><tr>
     <th>Class</th><th>Passive</th><th class="num">Deck</th><th class="num">Avg cost</th>
     <th>Timed</th><th>Identity</th><th>Rarity mix</th><th>Icons</th><th>Cost spread</th></tr></thead><tbody>\${cls}</tbody></table></div>
   <h2>Cost curve — whole catalog</h2>
   <p class="note">You have 3 energy a turn. If one cost dominates, every turn plays the same
     number of cards and deckbuilding loses its central tension.</p>
   <div class="scroll"><table><thead><tr><th class="num">Cost</th><th class="num">Cards</th><th></th></tr></thead>
     <tbody>\${curve}</tbody></table></div>\`;

  // Wired after innerHTML, not as inline onclick, so the markup above stays
  // readable and every jump goes through goTab.
  $("#overview").querySelectorAll("[data-hunter]").forEach(tr=>{
    const go = () => showHunter(tr.dataset.hunter);
    tr.onclick = go;
    tr.onkeydown = e => { if(e.key==="Enter"||e.key===" "){ e.preventDefault(); go(); } };
  });
  $("#overview").querySelectorAll(".stat.go").forEach(el=>{
    el.tabIndex = 0; el.setAttribute("role","button");
    const go = () => el.dataset.tab ? goTab(el.dataset.tab)
      : el.dataset.items ? showItems(el.dataset.items)
      : showCards(JSON.parse(el.dataset.cards));
    el.onclick = go;
    el.onkeydown = e => { if(e.key==="Enter"||e.key===" "){ e.preventDefault(); go(); } };
  });
})();

/* ---- hunters ----
   One hunter at a time: who they are, the deck they actually start every run
   with (duplicates shown as x2, because two copies of Tongue Snap is a real
   fact about the opening hand), and the pool they draft from. */
(function(){
  const s = $("#hunters");
  const byId = Object.fromEntries(D.cards.map(c=>[c.id,c]));
  const RANK = {common:0, uncommon:1, rare:2};

  s.innerHTML = \`
    <div class="hpick">\${D.classes.map((c,i)=>
      \`<button data-c="\${c.id}"\${i?"":' class="on"'}>\${esc(c.name)}</button>\`).join("")}</div>
    <div id="hbody"></div>\`;

  function tile(card, mult){
    if(!card) return "";
    const kw = [];
    if(card.timed) kw.push('<span class="tag t">timed</span>');
    if(card.signature) kw.push('<span class="tag sig">signature</span>');
    if(card.shared) kw.push('<span class="tag sh">shared</span>');
    if(card.icon) kw.push(\`<span class="tag">\${esc(card.icon)}</span>\`);
    return \`<div class="dcard r-\${card.rarity}\${card.hasArt?" hasart":""}" tabindex="0"
      role="button" title="Open the art for \${esc(card.name)}"
      data-id="\${esc(card.id)}" data-hay="\${esc((card.name+" "+card.text+" "+card.id+" "+card.used.join(" ")).toLowerCase())}">
      <span class="cost">\${card.cost}</span>
      <b>\${esc(card.name)}</b>\${mult>1?\`<span class="mult">x\${mult}</span>\`:""}
      <div class="body">\${esc(card.text)}</div>
      <div class="foot"><span class="tag r-\${card.rarity[0]}">\${esc(card.rarity)}</span>\${kw.join("")}</div>
    </div>\`;
  }

  // Click a card to see its art. Nick: "i click leap and it opens the art of
  // leap". Delegated on document because the deck is re-rendered every time you
  // switch hunter, so listeners bound to the tiles would die with them.
  const modal = $("#artmodal"), box = $("#artbox");
  function openArt(id){
    const c = byId[id];
    if(!c) return;
    // Cache-bust ALWAYS, not only right after an upload. Reopening the modal
    // asks for the same URL the browser already has, so without this you
    // replace a card's art, close, reopen, and are shown the old picture -
    // which looks exactly like the upload having failed.
    const src = c.hasArt
      ? "/art/" + encodeURIComponent(id) + ".png?t=" + (c.artStamp || 0)
      : "/icon/" + encodeURIComponent(c.icon) + ".png";
    const why = c.hasArt
      ? "This card has art of its own. Replace the file and refresh to see the new one."
      : "No art yet - this is the shared <b>" + esc(c.icon) + "</b> icon, which "
        + c.iconShared + " card" + (c.iconShared === 1 ? " uses" : "s use")
        + ". Export <b>1000 x 760 PNG</b> (25:19) and drop it in at the path above; "
        + "the game prefers it over the icon automatically.";
    box.innerHTML = \`<img class="\${c.hasArt?"has":""}" src="\${src}" alt="\${esc(c.name)}">
      <div class="cap">
        <h3>\${esc(c.name)}</h3>
        <code>game/assets/cardart/\${esc(id)}.png</code>
        <label class="drop">
          <input type="file" accept="image/png" data-card="\${esc(id)}">
          <span>Choose a PNG to use as this card's art</span>
        </label>
        <div class="upstat" id="upstat"></div>
        <div class="why">\${why}</div>
      </div>\`;
    modal.classList.add("on");
  }
  // Upload straight from the modal. The Lab already knows which card you have
  // open, so it names the file — which is the whole point of doing it here
  // rather than in a folder, where getting one of 187 ids wrong is silent.
  box.addEventListener("change", e => {
    const inp = e.target.closest("input[type=file]");
    if(!inp || !inp.files || !inp.files[0]) return;
    const id = inp.dataset.card, f = inp.files[0];
    const stat = $("#upstat");
    stat.textContent = "uploading " + f.name + "...";
    fetch("/upload/" + encodeURIComponent(id), { method:"POST", body:f })
      .then(r => r.ok ? r.text() : r.text().then(t => { throw new Error(t); }))
      .then(msg => {
        stat.textContent = (msg && msg !== "ok") ? msg
          : "saved as cardart/" + id + ".png";
        // Mark it on the CARD, not just on this modal. D.cards was baked when
        // the page was built, so hasArt is still false for a card that had none
        // a moment ago - and reopening the modal would go back to showing the
        // shared icon. Stamping it here fixes the reopen, the gold marker on
        // the deck tile, and the next open, all at once.
        const rec = byId[id];
        if (rec) { rec.hasArt = true; rec.artStamp = Date.now(); }
        document.querySelectorAll('.dcard[data-id="' + id + '"]')
          .forEach(t => t.classList.add("hasart"));
        const img = box.querySelector("img");
        img.src = "/art/" + encodeURIComponent(id) + ".png?t=" + Date.now();
        img.className = "has";
      })
      .catch(err => { stat.textContent = "failed: " + err.message; });
  });

  function closeArt(){ modal.classList.remove("on"); box.innerHTML = ""; }
  document.addEventListener("click", e=>{
    const t = e.target.closest(".dcard[data-id]");
    if(t) return openArt(t.dataset.id);
    if(e.target.id === "artx" || e.target === modal) closeArt();
  });
  document.addEventListener("keydown", e=>{
    if(e.key === "Escape") return closeArt();
    const t = document.activeElement;
    if((e.key === "Enter" || e.key === " ") && t && t.matches(".dcard[data-id]")){
      e.preventDefault(); openArt(t.dataset.id);
    }
  });

  function render(cid){
    const k = D.classes.find(c=>c.id===cid);

    // Starter deck: collapse duplicates but keep run order stable.
    const seen = new Map();
    for(const id of k.starter) seen.set(id, (seen.get(id)||0)+1);
    const starter = [...seen].map(([id,n])=>tile(byId[id], n)).join("");

    // Pool grouped by rarity — that is the order you meet them in, weighted.
    const groups = ["common","uncommon","rare"].map(r=>{
      const list = k.pool.map(id=>byId[id]).filter(c=>c&&c.rarity===r)
        .sort((a,b)=>a.cost-b.cost || a.name.localeCompare(b.name));
      if(!list.length) return "";
      return \`<h3 class="grp">\${r} - \${list.length} cards, \${k.offerRate[r]}% of reward slots</h3>
        <div class="deck">\${list.map(c=>tile(c,1)).join("")}</div>\`;
    }).join("");

    $("#hbody").innerHTML = \`
      <div class="ident">
        <h2>\${esc(k.name)}</h2>
        <p>\${esc(k.desc)}</p>
        <span class="tag">passive: \${esc(k.passive.type)} \${k.passive.value||""}</span>
        \${k.iconTop.map(t=>\`<span class="tag">\${esc(t[0])} x\${t[1]}</span>\`).join("")}
      </div>
      <div class="grid stats">
        <div class="stat"><b>\${k.starterSize}</b><span>starter deck</span></div>
        <div class="stat"><b>\${k.poolSize}</b><span>draftable</span></div>
        <div class="stat"><b>\${k.avgCost}</b><span>avg cost</span></div>
        <div class="stat"><b>\${k.timedPct}%</b><span>starter timed</span></div>
        <div class="stat"><b>\${k.identityPct}%</b><span>pool is signature</span></div>
        <div class="stat"><b>\${k.iconCount}</b><span>icons</span></div>
      </div>
      <div class="controls" style="margin-top:18px">
        <input type="search" id="hq" placeholder="Filter this hunter's cards...">
        <span class="sub">\${k.directTimed} timed in hand\${k.builtTimed?" + "+k.builtTimed+" built":""}</span>
      </div>
      <h3 class="grp">Starter deck - every run opens with these</h3>
      <div class="deck">\${starter}</div>
      \${groups}\`;

    // Dim rather than remove, so a filter never changes the shape of the deck.
    $("#hq").oninput = e => {
      const q = e.target.value.toLowerCase().trim();
      $("#hbody").querySelectorAll(".dcard").forEach(d=>
        d.classList.toggle("dim", !!q && !d.dataset.hay.includes(q)));
    };
  }

  function pick(cid){
    s.querySelectorAll(".hpick button").forEach(x=>x.classList.toggle("on",x.dataset.c===cid));
    render(cid);
  }
  s.querySelectorAll(".hpick button").forEach(b=>b.onclick=()=>pick(b.dataset.c));
  pick(D.classes[0].id);

  window.showHunter = cid => { pick(cid); goTab("hunters"); };
})();

/* ---- cards ---- */
(function(){
  const s = $("#cards");
  const classOpts = D.classes.map(c=>\`<option value="\${c.id}">\${esc(c.name)}</option>\`).join("");
  s.innerHTML = \`
    <div class="controls">
      <input type="search" id="q" placeholder="Search name, text, or field…">
      <select id="fc"><option value="">All classes</option>\${classOpts}<option value="__none">Unowned</option></select>
      <select id="fk"><option value="">All kinds</option><option value="timed">Timed only</option>
        <option value="sig">Signature only</option><option value="shared">Shared only</option></select>
      <select id="fr"><option value="">All rarities</option><option value="common">Common</option>
        <option value="uncommon">Uncommon</option><option value="rare">Rare</option></select>
      <span class="sub" id="count"></span>
    </div>
    <div class="scroll"><table id="tbl"><thead><tr>
      <th data-k="name">Card</th><th data-k="cost" class="num">Cost</th><th data-k="type">Type</th>
      <th>Effect fields</th><th>Text</th><th>Classes</th></tr></thead><tbody></tbody></table></div>\`;

  let sortK="name", sortDir=1;
  function rows(){
    const q = $("#q").value.toLowerCase().trim();
    const fc = $("#fc").value, fk = $("#fk").value;
    let list = D.cards.filter(c=>{
      if(q && !(c.name+" "+c.text+" "+c.used.join(" ")+" "+c.id).toLowerCase().includes(q)) return false;
      if(fc==="__none" && c.classes.length) return false;
      if(fc && fc!=="__none" && !c.classes.includes(fc)) return false;
      if(fk==="timed" && !c.timed) return false;
      if(fk==="sig" && !c.signature) return false;
      if(fk==="shared" && !c.shared) return false;
      if($("#fr").value && c.rarity!==$("#fr").value) return false;
      return true;
    });
    list.sort((a,b)=>{
      const x=a[sortK], y=b[sortK];
      return (typeof x==="number" ? x-y : String(x).localeCompare(String(y)))*sortDir;
    });
    $("#count").textContent = list.length + " of " + D.cards.length;
    $("#tbl tbody").innerHTML = list.map(c=>\`<tr>
      <td><b>\${esc(c.name)}</b> <span class="tag r-\${c.rarity[0]}">\${esc(c.rarity)}</span>\${c.timed?' <span class="tag t">timed</span>':""}
        \${!c.reachable?' <span class="tag" style="color:var(--rust)">unreachable</span>':""}
        <div class="sub">\${esc(c.id)}</div></td>
      <td class="num">\${c.cost}</td>
      <td>\${esc(c.type)}</td>
      <td>\${c.used.map(f=>\`<span class="tag">\${esc(f)}\${typeof c.fields[f]==="number"?" "+c.fields[f]:""}</span>\`).join("")}</td>
      <td class="cardtext">\${esc(c.text)}</td>
      <td>\${c.classes.map(x=>\`<span class="tag \${c.signature?"sig":"sh"}">\${esc((D.classes.find(k=>k.id===x)||{}).name||x)}</span>\`).join("")}
        \${c.builtBy.length?\`<span class="tag">built by \${esc(c.builtBy.join(", "))}</span>\`:""}</td></tr>\`).join("");
  }
  s.querySelectorAll("thead th[data-k]").forEach(th=>th.onclick=()=>{
    const k=th.dataset.k; sortDir = (k===sortK) ? -sortDir : 1; sortK=k; rows();
  });
  ["q","fc","fk","fr"].forEach(id=>$("#"+id).oninput=rows);
  rows();

  // Arriving from a stat tile should land on the filtered list, not on the
  // whole catalog with the filter left for you to set.
  window.showCards = (f={}) => {
    $("#q").value = f.q || ""; $("#fc").value = f.cls || "";
    $("#fk").value = f.kind || ""; $("#fr").value = f.rarity || "";
    rows(); goTab("cards");
  };
})();

/* ---- items: relics, potions, enchantments ---- */
(function(){
  const s = $("#items");
  s.innerHTML = \`
    <p class="note">Relics, potions and enchantments are the same shape — a named
      <b>effect</b> the engine reads generically, plus a value — which is exactly why they
      belong on one screen. This is every non-card effect in the game, in one list.</p>
    <div class="controls">
      <input type="search" id="iq" placeholder="Search name, text, or effect…">
      <select id="ik"><option value="">All kinds</option><option value="relic">Relics</option>
        <option value="potion">Potions</option><option value="enchant">Enchantments</option></select>
      <span class="sub" id="icount"></span>
    </div>
    <div class="scroll"><table id="itbl"><thead><tr>
      <th data-k="name">Item</th><th data-k="kind">Kind</th><th data-k="effect">Effect</th>
      <th class="num">Value</th><th>Text</th><th>Offered</th></tr></thead><tbody></tbody></table></div>\`;

  let sk="kind", sd=1;
  function irows(){
    const q = $("#iq").value.toLowerCase().trim(), k = $("#ik").value;
    const list = D.items.filter(i=>{
      if(k && i.kind!==k) return false;
      if(q && !((i.name+" "+i.text+" "+i.effect+" "+i.id).toLowerCase().includes(q))) return false;
      return true;
    });
    list.sort((a,b)=>{
      const x=a[sk], y=b[sk];
      return (typeof x==="number" ? x-y : String(x).localeCompare(String(y)))*sd;
    });
    $("#icount").textContent = list.length + " of " + D.items.length;
    $("#itbl tbody").innerHTML = list.map(i=>\`<tr>
      <td><b>\${esc(i.name)}</b><div class="sub">\${esc(i.id)}</div></td>
      <td><span class="tag">\${esc(i.kind)}</span></td>
      <td>\${i.effect ? \`<span class="tag">\${esc(i.effect)}</span>\` : '<span class="sub">—</span>'}</td>
      <td class="num">\${i.value===undefined||i.value===null ? "" : i.value}</td>
      <td class="cardtext">\${esc(i.text)}</td>
      <td>\${i.offered===null ? '<span class="sub">n/a</span>'
            : (i.offered ? '<span class="tag">in pool</span>'
                         : '<span class="tag" style="color:var(--rust)">unreachable</span>')}</td></tr>\`).join("");
  }
  s.querySelectorAll("thead th[data-k]").forEach(th=>th.onclick=()=>{
    const k=th.dataset.k; sd=(k===sk)?-sd:1; sk=k; irows();
  });
  ["iq","ik"].forEach(id=>$("#"+id).oninput=irows);
  irows();

  // Same contract as showCards: a stat tile lands you on the filtered list.
  window.showItems = kind => { $("#ik").value = kind || ""; irows(); goTab("items"); };
})();

/* ---- coverage ---- */
(function(){
  const head = D.classes.map(c=>\`<th class="num">\${esc(c.name)}</th>\`).join("");
  const body = D.coverage.map(r=>{
    const cells = D.classes.map(c=>{
      const v = r.cells[c.id];
      return \`<td class="n \${v===0?"z":""}">\${v}</td>\`;
    }).join("");
    return \`<tr><td><b>\${esc(r.group)}</b><div class="sub">\${r.fields.map(esc).join(" · ")}</div></td>
      \${cells}<td class="n">\${r.total}</td></tr>\`;
  }).join("");
  $("#coverage").innerHTML = \`
    <h2>Mechanic coverage by class</h2>
    <p class="note">Each cell counts distinct cards in that class's starter deck plus reward pool
      that touch the group. <b style="color:var(--rust)">Red zeros are unbuilt design space</b> —
      a mechanic that class has no access to. Some zeros are deliberate identity; the point is
      that you decide which.</p>
    <div class="scroll cov"><table><thead><tr><th>Group</th>\${head}<th class="num">Catalog</th></tr></thead>
      <tbody>\${body}</tbody></table></div>\`;
})();

/* ---- gaps ---- */
(function(){
  const cells = D.gaps.map(g=>\`<div class="gap"><b>\${esc(g.cls)} × \${esc(g.group)}</b>
    <span>no card touches: \${g.fields.map(esc).join(" · ")}</span></div>\`).join("") ||
    \`<p class="note">Every class touches every mechanic group. Nice — look at the combination gaps below instead.</p>\`;
  const combos = D.comboGaps.map(c=>\`<div class="gap"><b>\${esc(c.a)} + \${esc(c.b)}</b>
    <span>\${c.only?("only one card does both: "+esc(c.only)):"no card combines these"}</span></div>\`).join("");
  $("#gaps").innerHTML = \`
    <h2>Unbuilt cards</h2>
    <p class="note">Each tile is a card that could exist and doesn't. Treat them as prompts, not
      obligations — a zero can be the right call for a class's identity. But an accidental zero is
      a card you forgot to write.</p>
    <div class="grid gapgrid">\${cells}</div>
    <h2>Uncombined mechanics</h2>
    <p class="note">Pairs of mechanic groups that no single card yet brings together. These are where
      surprising cards live — the ones that make a deck feel invented rather than assembled.</p>
    <div class="grid gapgrid">\${combos}</div>\`;
})();

/* ---- levers ---- */
(function(){
  const max = Math.max(...D.fieldUsage.map(f=>f.count));
  const rows = D.fieldUsage.map(f=>\`<tr>
    <td><b>\${esc(f.field)}</b></td><td class="num">\${f.count}</td>
    <td><div class="bar \${f.count<=2?"":"m"}"><i style="width:\${(f.count/max*260).toFixed(0)}px"></i></div></td>
    <td class="cardtext">\${f.cards.slice(0,6).map(esc).join(", ")}\${f.cards.length>6?" +"+(f.cards.length-6):""}</td>
  </tr>\`).join("");
  const unused = D.knownUnused.map(f=>\`<span class="tag">\${esc(f)}</span>\`).join(" ");
  $("#levers").innerHTML = \`
    <h2>Field usage — least used first</h2>
    <p class="note">Every field is a design lever. The ones at the top are built but barely used —
      usually the cheapest place to find a new card, because the code already exists.</p>
    <div class="scroll"><table><thead><tr><th>Field</th><th class="num">Cards</th><th></th><th>Used by</th></tr></thead>
      <tbody>\${rows}</tbody></table></div>
    <h2>Levers that don't exist yet</h2>
    <p class="note">Listed in design/cards-and-classes.md as "ask Claude to add the field".
      Each one is a new axis of card design, not just a new card.</p>
    <p>\${unused}</p>\`;
})();

/* ---- health ---- */
(function(){
  $("#health").innerHTML = \`<h2>Findings</h2>\` + D.checks.map(c=>\`
    <div class="chk \${c.level}"><h3>\${esc(c.title)}</h3><p>\${esc(c.detail)}</p>
    <ul>\${c.items.map(i=>\`<li>\${esc(i)}</li>\`).join("")}</ul></div>\`).join("");
})();
</script>
</body>
</html>`;
}
