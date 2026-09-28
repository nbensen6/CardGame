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
        items.append({"a": a, "b": b, "mark": mark, "title": title,
                      "body": block, "id": bid.group(1) if bid else "",
                      "ask": ask.group(1).strip() if ask else ""})
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
        lines[it["a"]] = lines[it["a"]].rstrip() + " ^" + slug  # on the title line
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
    # The list is a link and a question, nothing else (Nick, 2026-09-28). The
    # Test-this-now link and the frames live on the ticket the link opens.
    return "\n".join([f"- [ ] {head}", f"  {ask}", "  - Nick: "])


def write_page(lines, items):
    now = [it for it in items if it["mark"] == "?" and section_of(lines, it["a"]).startswith("## Now")]
    decide = [it for it in items if it["mark"] == " " and section_of(lines, it["a"]).startswith("## Waiting on Nick")]
    frames = sorted(FRAMES.glob("*-after.png"), key=lambda p: p.stat().st_mtime, reverse=True)[:8]
    out = ["---", "tags:", "  - home", "---", "", "# Needs Nick", "",
           f"_{STAMP}. Tick a box to mark it done. Type after **Nick:** to send it back: "
           f"your words go on the item and the builder takes it first. Then run **Send my answers** "
           f"(command palette) or just run the builder._", ""]
    if decide:
        out += ["## Decide", ""] + [bullet(it) for it in decide] + [""]
    if now:
        out += ["## Look, then tick or send back", ""] + [bullet(it) for it in now] + [""]
    if not decide and not now:
        out += ["Nothing. The builder is running or waiting for a new line in [[BUILDER-QUEUE]].", ""]
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
    changed = apply_answers(lines, items, answers)
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
