r"""design/Needs Nick.md: the one page Nick reads and answers on.

Two directions, one script:

  queue -> page   every `[?]` item under `## Now` in BUILDER-QUEUE.md becomes a
                  bullet linking the item and its frames, with a `Nick:` line
                  under it. Open items under `## Waiting on Nick` become
                  "Decide" bullets the same way.
  page  -> queue  a bullet Nick ticked `[x]` ticks the queue item. Anything he
                  typed after `Nick:` is copied into the queue item as
                  **Nick, <time>:**, the item is reopened `[ ]` and moved to the
                  top of `## Now`, so the next builder run takes it first.

Then the queue and the page are committed and pushed, so the builder's
worktree sees his answers. Run by tools/builder/run.cmd before and after every
run, by the Obsidian command "Send my answers", or by hand:

    python tools\needs_nick.py
"""
import re
import subprocess
from datetime import datetime
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
QUEUE = ROOT / "design" / "plan" / "BUILDER-QUEUE.md"
OUT = ROOT / "design" / "Needs Nick.md"
FRAMES = ROOT / "design" / "agents" / "frames" / "builder"
STAMP = datetime.now().strftime("%Y-%m-%d %H:%M") + " ET"  # the PC clock is Eastern; git agrees

# `- [ ] **..**` open, `- [ ] 👀 **..**` built and waiting for Nick, `- [x]` done.
# (`[?]` was the waiting mark until 2026-09-28; Obsidian draws it as ticked.)
ITEM = re.compile(r"^- \[([ x])\] (👀 )?\*\*(.+?)\*\*", re.S)


# --- the queue as blocks ---------------------------------------------------

def split_items(lines):
    """Yield (start, end_exclusive) for every `- [ ] **...` item; the body is
    every following line indented six spaces."""
    i = 0
    while i < len(lines):
        if lines[i].startswith("- ["):
            j = i
            while j + 1 < len(lines) and lines[j + 1].startswith("      "):
                j += 1
            yield i, j + 1
            i = j + 1
        else:
            i += 1


def parse(text):
    lines = text.split("\n")
    items = []
    for a, b in split_items(lines):
        block = "\n".join(lines[a:b])
        m = ITEM.match(block)
        if not m:
            continue
        title = " ".join(m.group(3).split())
        mark = "?" if m.group(2) else m.group(1)
        bid = re.search(r" \^([\w-]+)\s*$", block, re.M)
        ask = re.search(r"^\s{6}Ask: (.+)$", block, re.M)
        test = re.search(r"^\s{6}Test: (.+?)(?: \^[\w-]+)?\s*$", block, re.M)
        items.append({"a": a, "b": b, "mark": mark, "title": title,
                      "body": block, "id": bid.group(1) if bid else "",
                      "ask": ask.group(1).strip() if ask else "",
                      "test": test.group(1).strip() if test else ""})
    return lines, items


def section_of(lines, idx):
    for k in range(idx, -1, -1):
        if lines[k].startswith("## "):
            return lines[k]
    return ""


def ensure_ids(lines, items):
    for it in items:
        if it["id"]:
            continue
        slug = re.sub(r"[^a-z0-9]+", "-", it["title"].lower()).strip("-")[:40]
        # Obsidian resolves a block id only at the END of the block: last line.
        lines[it["b"] - 1] = lines[it["b"] - 1].rstrip() + " ^" + slug
        it["id"] = slug


# --- what Nick wrote on the page -------------------------------------------

def read_answers():
    """{block id: [ticked, note]} from the current Needs Nick.md, if any."""
    if not OUT.exists():
        return {}
    answers, cur = {}, None
    for line in OUT.read_text(encoding="utf-8").split("\n"):
        m = re.match(r"^- \[([ x])\] \[\[BUILDER-QUEUE#\^([\w-]+)\|", line)
        if m:
            cur = m.group(2)
            answers[cur] = [m.group(1) == "x", ""]
            continue
        n = re.match(r"^\s+- Nick:\s*(.*)$", line)
        if n and cur:
            answers[cur][1] = n.group(1).strip()
    return answers


REFS = ROOT / "design" / "art" / "references"


def attach_images(note):
    """A pasted image on the Nick: line arrives as ![[name.png]] (Obsidian saves
    the file to art/references, or the vault root on an older setting). Move
    it under art/references, stage it so it is pushed with the answer, and
    rewrite the embed with the full path and a width so the ticket shows it."""
    def fix(m):
        name = m.group(1).split("|")[0].strip()
        src = None
        for cand in [REFS / Path(name).name, ROOT / "design" / name, ROOT / "design" / Path(name).name]:
            if cand.exists():
                src = cand
                break
        if src is None:
            return m.group(0)
        dst = REFS / src.name
        if src != dst:
            dst.parent.mkdir(parents=True, exist_ok=True)
            src.replace(dst)
        git("add", str(dst))
        return f"![[art/references/{dst.name}|420]]"
    return re.sub(r"!\[\[([^\]]+)\]\]", fix, note)


WHERE = {"rest": "state=3d", "climb": "state=3dclimb slot=1", "sigil": "state=3dclimb",
         "grip": "state=3dgrip", "menu": "state=menu", "goblin": "state=goblin"}


def read_requests():
    """Filled-in request slots on the page: [{what, where, priority, picture}]."""
    if not OUT.exists():
        return []
    text = OUT.read_text(encoding="utf-8")
    out = []
    for m in re.finditer(r"^- What: *(.*)\n  Where: *(.*)\n  Priority: *(.*)\n  Picture: *(.*)$", text, re.M):
        what = m.group(1).strip()
        if not what:
            continue
        out.append({"what": what, "where": m.group(2).strip().lower(),
                    "priority": m.group(3).strip().lower(), "picture": m.group(4).strip()})
    return out


def apply_requests(lines, reqs):
    """Each filled slot becomes a queue item under ## Now: top for 'top',
    otherwise last. Returns True if anything was added."""
    if not reqs:
        return False
    now_at = next(k for k, l in enumerate(lines) if l.startswith("## Now"))
    end = next((k for k in range(now_at + 1, len(lines)) if lines[k].startswith("## ")), len(lines))
    for r in reqs:
        first = re.split(r"(?<=[.!?])\s", r["what"], 1)[0].strip().rstrip(".!?")
        title = (first[:1].upper() + first[1:])[:70].rstrip() + "."
        slug = re.sub(r"[^a-z0-9]+", "-", title.lower()).strip("-")[:40]
        # Where is one of the known shots, or harness args (they contain '=').
        # Anything else is Nick describing the place in words: keep his words
        # on the note and test from the resting shot.
        where = r["where"]
        key = where.split()[0] if where else "rest"
        if key in WHERE:
            test, where_note = WHERE[key], ""
        elif "=" in where:
            test, where_note = where, ""
        else:
            test, where_note = "state=3d", f" (where: {where})"
        note = attach_images(r["what"] + where_note + (" " + r["picture"] if r["picture"] else ""))
        block = [f"- [ ] **{title}**",
                 f"      **Nick, {STAMP}:** {note}",
                 f"      {test_link(test)} · [[BUILDER-QUEUE-NOTES#{title}|details]]",
                 f"      Test: {test} ^{slug}"]
        if r["priority"].startswith("top"):
            first_item = next((k for k in range(now_at + 1, end) if lines[k].startswith("- [")), end)
            lines[first_item:first_item] = block
        else:
            # before the blank line that closes the section
            k = end
            while k > now_at and not lines[k - 1].strip():
                k -= 1
            lines[k:k] = block
        end += len(block)
    return True


REQUEST_FORM = ["## Ask the builder for something", "",
                "Fill a slot in and it becomes a line in the queue within 15 minutes; the slot clears itself. "
                "Where: rest, climb, sigil, grip, menu or goblin (which shot proves it). Priority: top or later.", ""]
BLANK_SLOT = ["- What: ", "  Where: rest", "  Priority: top", "  Picture: "]


def apply_answers(lines, items, answers):
    """Tick or reopen queue items from the page. Returns True if anything changed."""
    changed = False
    to_top = []
    for it in items:
        ticked, note = answers.get(it["id"], [False, ""])
        # "goblin looks okay at this time" is a yes, not a send-back.
        if note and re.match(r"^(ok|okay|yes|yep|good|fine|done|approved|looks (good|okay|fine|right)|.* looks (good|okay|fine|right)( at this time| for now)?\.?)$", note.strip(), re.I):
            ticked, note = True, ""
        if ticked and it["mark"] == "?":
            lines[it["a"]] = lines[it["a"]].replace("- [ ] 👀", "- [x]", 1)
            changed = True
        if note and note not in it["body"]:
            note = attach_images(note)
            lines[it["a"]] = re.sub(r"^- \[[ x]\] (👀 )?", "- [ ] ", lines[it["a"]], count=1)
            last = it["b"] - 1
            # His words go right under the title, above Look/Ask/Details, so
            # they are the first thing the builder and he see.
            lines.insert(it["a"] + 1, f"      **Nick, {STAMP}:** {note}")
            last += 1
            for other in items:
                if other["a"] > it["a"]:
                    other["a"] += 1
                    other["b"] += 1
            it["b"] += 1
            to_top.append(it)
            changed = True
    # A sent-back item jumps to the top of Now, so the next run takes it first.
    if to_top:
        now_at = next(k for k, l in enumerate(lines) if l.startswith("## Now"))
        blocks = []
        for it in sorted(to_top, key=lambda x: x["a"], reverse=True):
            blocks.insert(0, lines[it["a"]:it["b"]])
            del lines[it["a"]:it["b"]]
        first = now_at + 1
        while first < len(lines) and not lines[first].startswith("- ["):
            first += 1
        insert = [l for blk in blocks for l in blk]
        lines[first:first] = insert
    return changed


# --- the page ---------------------------------------------------------------

TEST = "▶ [Test this now](obsidian://shell-commands/?vault=design&execute=fight-uri-beast&_beast=cinder_jackal)"


def bullet(it):
    paths = list(dict.fromkeys(re.findall(r"(?:agents/frames|art/references)/[\w./-]+?\.(?:png|webp)", it["body"])))
    head = f"[[BUILDER-QUEUE#^{it['id']}|{it['title']}]]"
    ask = it.get("ask") or "Tick if it is right. Say what is wrong if not."
    # The list is a link, the Test-this-now link beside it, and a question
    # (Nick, 2026-09-28). The frames live on the ticket the link opens.
    # An item's `Test:` line names the exact harness scenario the builder
    # graded; the link opens the game in that scenario (test_scenario.cmd).
    return "\n".join([f"- [ ] {head} · {test_link(it.get('test', ''))}", f"  {ask}", "  - Nick: "])


def test_link(scenario):
    if not scenario:
        return TEST
    from urllib.parse import quote
    return f"▶ [Test this now](obsidian://shell-commands/?vault=design&execute=test-scenario&_scenario={quote(scenario, safe='')})"


def write_page(lines, items):
    now = [it for it in items if it["mark"] == "?" and section_of(lines, it["a"]).startswith("## Now")]
    decide = [it for it in items if it["mark"] == " " and section_of(lines, it["a"]).startswith("## Waiting on Nick")]
    frames = sorted(FRAMES.glob("*-after.png"), key=lambda p: p.stat().st_mtime, reverse=True)[:8]
    out = ["---", "tags:", "  - home", "---", "", "# Needs Nick", "",
           f"_{STAMP}. Tick a box to mark it done. Type after **Nick:** to send it back; "
           f"paste a picture on the same line if it helps. It uploads by itself within 15 minutes "
           f"and the builder takes it next._", ""]
    if decide:
        out += ["## Decide", ""] + [bullet(it) for it in decide] + [""]
    if now:
        out += ["## Look, then tick or send back", ""] + [bullet(it) for it in now] + [""]
    if not decide and not now:
        out += ["Nothing. The builder is running or waiting for a new line in [[BUILDER-QUEUE]].", ""]
    out += REQUEST_FORM
    for _ in range(3):
        out += BLANK_SLOT
    out.append("")
    if frames:
        out += ["## Latest frames", ""] + [f"- [[agents/frames/builder/{p.name}|{p.stem.removesuffix('-after')}]]" for p in frames] + [""]
    OUT.write_text("\n".join(out), encoding="utf-8")
    return len(decide), len(now)


def git(*args):
    return subprocess.run(["git", "-C", str(ROOT), *args], capture_output=True, text=True)


def main():
    text = QUEUE.read_text(encoding="utf-8")
    lines, items = parse(text)
    ensure_ids(lines, items)
    answers = read_answers()
    reqs = read_requests()
    changed = apply_answers(lines, items, answers)
    changed = apply_requests(lines, reqs) or changed
    new_text = "\n".join(lines)
    if new_text != text:
        QUEUE.write_text(new_text, encoding="utf-8")
    lines, items = parse(new_text)
    d, n = write_page(lines, items)
    print(f"Needs Nick.md: {d} to decide, {n} to look at" + (", answers applied" if changed else ""))
    # Only the queue is shared. The page is generated per machine and is
    # gitignored: committing it from two machines made the 15-minute sync
    # conflict on it twice on 2026-09-28.
    git("add", str(QUEUE))
    if git("diff", "--cached", "--quiet").returncode != 0:
        git("commit", "-q", "-m", "needs-nick: Nick's answers into the queue")
        git("pull", "--rebase", "-q", "--autostash", "origin", "main")
        git("push", "-q", "origin", "main")
        print("pushed")


if __name__ == "__main__":
    main()
