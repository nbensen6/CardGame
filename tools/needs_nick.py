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

ITEM = re.compile(r"^- \[([ ?x])\] \*\*(.+?)\*\*", re.S)


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
        title = " ".join(m.group(2).split())
        bid = re.search(r" \^([\w-]+)\s*$", block)
        items.append({"a": a, "b": b, "mark": m.group(1), "title": title,
                      "body": block, "id": bid.group(1) if bid else ""})
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


def apply_answers(lines, items, answers):
    """Tick or reopen queue items from the page. Returns True if anything changed."""
    changed = False
    to_top = []
    for it in items:
        ticked, note = answers.get(it["id"], [False, ""])
        if ticked and it["mark"] == "?":
            lines[it["a"]] = lines[it["a"]].replace("- [?]", "- [x]", 1)
            changed = True
        if note and note not in it["body"]:
            lines[it["a"]] = re.sub(r"^- \[[ ?]\]", "- [ ]", lines[it["a"]], count=1)
            last = it["b"] - 1
            tail = re.search(r" \^[\w-]+\s*$", lines[last])
            bid = tail.group(0) if tail else ""
            if tail:
                lines[last] = lines[last][: tail.start()]
            lines.insert(last + 1, f"      **Nick, {STAMP}:** {note}{bid}")
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

def bullet(it):
    paths = re.findall(r"(?:agents/frames|art/references)/[\w./-]+?\.(?:png|webp)", it["body"])
    links = " · ".join(f"[[{p}|{Path(p).stem}]]" for p in dict.fromkeys(paths))
    head = f"[[BUILDER-QUEUE#^{it['id']}|{it['title']}]]"
    return f"- [ ] {head}" + (f" — {links}" if links else "") + "\n  - Nick: "


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
    git("add", str(QUEUE), str(OUT))
    if git("diff", "--cached", "--quiet").returncode != 0:
        git("commit", "-q", "-m", "needs-nick: sync Nick's answers and the page")
        git("pull", "--rebase", "-q", "--autostash", "origin", "main")
        git("push", "-q", "origin", "main")
        print("pushed")


if __name__ == "__main__":
    main()
