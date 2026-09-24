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

AGENTS = ("artist", "playtester", "fixer")
STATUS = os.path.join("design", "agents", "status")
REQUESTS = os.path.join("design", "agents", "requests")
OUT = os.path.join("design", "agents", "Task board.md")
STALE = 2400  # seconds; matches lease.sh, after which a lease is not a run


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
    out = ["---", "tags:", "  - agents", "---", "", "# Task board", ""]
    out.append("_Generated from the agents' own status notes and the open "
               "requests. Do not edit -- the next sync overwrites it._")
    out.append("")

    for agent in AGENTS:
        block = this_run(read(os.path.join(STATUS, agent + ".md")))
        live = running(read(os.path.join(STATUS, agent + ".lease")))
        out.append("## %s %s" % (agent, "— RUNNING NOW" if live else ""))
        out.append("")
        out.append("**Last run:** %s" % run_heading_time(block))
        out.append("")
        out.append("- **Did:** %s" % (bullet(block, "Did") or "—"))
        out.append("- **Next:** %s" % (bullet(block, "Next") or "—"))
        need = bullet(block, "Need from you")
        if need and need.lower().strip(" .") not in ("nothing", "none"):
            out.append("- **Needs Nick:** %s" % need)
        rows = owned.get(agent, [])
        out.append("")
        if rows:
            out.append("| ticket | priority | eta | state | |")
            out.append("|---|---|---|---|---|")
            for r in rows:
                out.append("| #%s | %s | %s | %s | %s |" % (
                    r["num"] or "-", r["priority"], r["eta"] or "not estimated",
                    r["status"], r["title"]))
        else:
            out.append("_No open ticket._")
        out.append("")

    mine = owned.get("nick", [])
    out.append("## waiting on Nick")
    out.append("")
    if mine:
        for r in mine:
            out.append("- **#%s** %s" % (r["num"] or "-", r["title"]))
    else:
        out.append("_Nothing._")
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
