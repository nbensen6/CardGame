"""Build the task board: what each agent finished, is on, and will do next.

Nick asked for one place that answers "what have they been working on / what
are they working on / what will they work on". Every piece of that already
exists -- each agent's status note opens with a `## This run` block (Did /
Worked? / Next), each request carries its owner and state, and the lease file
says whether an agent is running right now. Nothing here is new information;
it is the same facts stopped being spread across six files.

Written to design/agents/Task board.md (Obsidian) and mirrored by board_sync
into one long-lived GitHub issue, so it is on his phone too.

    python tools/board_status.py            # write the note
    python tools/board_status.py --selftest # the parsing, no files
"""

import io
import os
import re
import sys
import time

AGENTS = ("director", "artist", "playtester", "fixer")
STATUS = os.path.join("design", "agents", "status")
REQUESTS = os.path.join("design", "agents", "requests")
OUT = os.path.join("design", "agents", "Task board.md")
STALE = 2400  # seconds; matches lease.sh, after which a lease is not a run


def short(text, limit=110):
    """Cut a bullet to something scannable, on a word boundary.

    The agents write paragraphs into their `Did:` line -- one was 470
    characters. A board you have to READ is not a board, so it is trimmed here
    rather than trusted: the full text is a click away in the status note, and
    the brief now asks for one line, but the board must stay legible even when
    an agent ignores that.
    """
    text = " ".join((text or "").split())
    if len(text) <= limit:
        return text
    cut = text[:limit].rsplit(" ", 1)[0]
    return cut + " …"


def bullet(text, label):
    """The one line after `**Did:**` (or Next, or Need from you), unwrapped.

    The notes wrap at ~75 columns, so the value runs over several lines and
    stops at the next bullet -- taking only the first line would truncate
    almost every entry mid-sentence.
    """
    m = re.search(r"\*\*%s:?\*\*\s*(.+?)(?=\n\s*-\s+\*\*|\n\s*\n|\Z)" % label, text, re.S)
    if not m:
        return ""
    return " ".join(m.group(1).split())


def this_run(text):
    """The `## This run` block of a status note, heading line included."""
    m = re.search(r"^## This run(.*?)(?=^## )", text, re.S | re.M)
    return m.group(0) if m else ""


def run_heading_time(block):
    m = re.search(r"^## This run\s*[-—]\s*(.+)$", block, re.M)
    return m.group(1).strip() if m else "unknown"


def running(lease_text):
    """True when the lease names a holder whose claim has not gone stale."""
    parts = (lease_text or "").split()
    if not parts:
        return False
    try:
        return (time.time() - int(parts[0])) < STALE
    except ValueError:
        return False


def read(path):
    try:
        with io.open(path, encoding="utf-8") as f:
            return f.read()
    except (IOError, OSError):
        return ""


def front(text):
    out = {}
    if not text.startswith("---"):
        return out
    end = text.find("\n---", 3)
    for line in text[3:end if end > 0 else 0].split("\n"):
        if ":" in line and not line.startswith((" ", "-", "#")):
            k, v = line.split(":", 1)
            out[k.strip()] = v.strip()
    return out


def tickets():
    """Open requests, grouped by who owns them."""
    by_owner = {}
    if not os.path.isdir(REQUESTS):
        return by_owner
    for name in sorted(os.listdir(REQUESTS)):
        if not name.endswith(".md") or name.startswith("_"):
            continue
        text = read(os.path.join(REQUESTS, name))
        fm = front(text)
        if fm.get("status", "open").lower() in ("done", "wontfix"):
            continue
        owner = fm.get("taken_by", "").strip() or fm.get("to", "?").strip()
        title = ""
        m = re.search(r"^#\s+(.+)$", text, re.M)
        if m:
            title = m.group(1).strip()
        by_owner.setdefault(owner, []).append({
            "num": fm.get("issue", "").strip(),
            "title": title,
            "priority": fm.get("priority", "normal").strip(),
            "eta": fm.get("eta", "").strip(),
            "status": fm.get("status", "open").strip(),
        })
    return by_owner


def render():
    owned = tickets()
    # Keep the issue number the sync wrote in here. This note is regenerated
    # from scratch every run, so anything not carried over is lost -- and a
    # lost issue number makes the next sync open a SECOND task board issue
    # instead of updating the one that exists (it opened #10 beside #9 before
    # this line existed).
    keep = front(read(OUT)).get("issue", "").strip()
    out = ["---", "tags:", "  - agents"]
    if keep:
        out.append("issue: " + keep)
    out += ["---", "", "# Task board", ""]
    out.append("_Generated from the agents' own status notes and the open "
               "requests. Do not edit -- the next sync overwrites it._")
    out.append("")

    out.append("| agent | | doing now | next | tickets |")
    out.append("|---|---|---|---|---|")
    for agent in AGENTS:
        block = this_run(read(os.path.join(STATUS, agent + ".md")))
        live = running(read(os.path.join(STATUS, agent + ".lease")))
        rows = owned.get(agent, [])
        refs = " ".join("#" + (r["num"] or "?") for r in rows) or "—"
        out.append("| **%s** | %s | %s | %s | %s |" % (
            agent,
            "🟢 running" if live else "idle",
            short(bullet(block, "Did"), 90) or "—",
            short(bullet(block, "Next"), 90) or "—",
            refs))
    out.append("")

    out.append("## Tickets")
    out.append("")
    out.append("| # | owner | priority | eta | state | |")
    out.append("|---|---|---|---|---|---|")
    any_row = False
    for owner in list(AGENTS) + ["nick"]:
        for r in owned.get(owner, []):
            any_row = True
            out.append("| #%s | %s | %s | %s | %s | %s |" % (
                r["num"] or "-", owner, r["priority"],
                r["eta"] or "—", r["status"], short(r["title"], 60)))
    if not any_row:
        out.append("| — | | | | | _nothing open_ |")
    out.append("")

    mine = owned.get("nick", [])
    out.append("## Waiting on you")
    out.append("")
    if mine:
        for r in mine:
            out.append("- **#%s** %s" % (r["num"] or "-", short(r["title"], 80)))
    else:
        out.append("_Nothing._")
    out.append("")

    out.append("## Last run, in their own words")
    out.append("")
    for agent in AGENTS:
        block = this_run(read(os.path.join(STATUS, agent + ".md")))
        out.append("**%s** — %s" % (agent, run_heading_time(block)))
        out.append("")
        out.append("- Did: %s" % (short(bullet(block, "Did"), 220) or "—"))
        out.append("- Next: %s" % (short(bullet(block, "Next"), 220) or "—"))
        need = bullet(block, "Need from you")
        if need and need.lower().strip(" .") not in ("nothing", "none"):
            out.append("- **Needs you:** %s" % short(need, 220))
        out.append("")
    return "\n".join(out) + "\n"


def selftest():
    block = """## This run - 2026-09-24 14:08 ET

- **Did:** fixed a thing, and
  it wrapped onto a second line.
- **Worked?** Yes.
- **Next:** the next thing.
- **Need from you:** nothing.

## Now
"""
    assert bullet(block, "Did") == "fixed a thing, and it wrapped onto a second line.", bullet(block, "Did")
    assert bullet(block, "Next") == "the next thing."
    assert bullet(block, "Missing") == ""
    assert run_heading_time(block) == "2026-09-24 14:08 ET"
    # an em-dashed heading, which is what the brief's own example uses
    assert run_heading_time("## This run — 2026-09-24 09:00 ET\n") == "2026-09-24 09:00 ET"
    assert this_run("no such section") == ""

    assert running("%d 2026-09-24T14:19 run" % time.time())
    assert not running("")
    assert not running("%d old run" % (time.time() - STALE - 1))
    assert not running("garbage in the lease")

    # a paragraph in a Did: line must not be allowed to wreck the board
    long_text = "word " * 60
    assert len(short(long_text, 90)) <= 92, len(short(long_text, 90))
    assert short(long_text, 90).endswith("…")
    assert short("short enough", 90) == "short enough"
    assert short("", 90) == ""
    print("BOARD STATUS SELFTEST OK")


def main():
    if "--selftest" in sys.argv[1:]:
        selftest()
        return 0
    os.chdir(os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
    text = render()
    with io.open(OUT, "w", encoding="utf-8", newline="\n") as f:
        f.write(text)
    print("wrote %s" % OUT)
    return 0


if __name__ == "__main__":
    sys.exit(main())
