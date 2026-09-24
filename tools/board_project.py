"""Drive the GitHub Projects board from the request notes.

The board (https://github.com/users/nbensen6/projects/1) is the scannable
view Nick asked for: four columns, one card per ticket, with the agent,
priority and ETA as fields he can group or filter by.

Projects v2 is GraphQL-only, and GraphQL is blocked inside the cloud agents'
sandboxes -- so, like every other outward-facing job here, this runs on Nick's
PC as part of the half-hourly sync. The agents keep writing markdown.

    python tools/board_project.py            # bring the board in line
    python tools/board_project.py --dry-run  # say what it would change
    python tools/board_project.py --selftest # the mapping rules, no network

Mapping, and the reason for each:
    to: nick            -> Waiting on Nick   (the only column he has to act on)
    status: taken       -> In Progress       (an agent has claimed it)
    status: open        -> Todo
    status: done/wontfix-> Done
"""

import json
import os
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from board_sync import answered  # one definition of "has he replied", shared

OWNER = "nbensen6"
NUMBER = "1"
GH = "gh"
REQUESTS = os.path.join("design", "agents", "requests")
DONE = ("done", "wontfix")


def run(args, quiet=False):
    p = subprocess.run([GH] + args, capture_output=True, text=True,
                       encoding="utf-8", errors="replace")
    if p.returncode != 0:
        if not quiet:
            print("  gh failed: %s" % (p.stderr or "").strip().split("\n")[0])
        return None
    try:
        return json.loads(p.stdout or "null")
    except ValueError:
        return p.stdout


def lane(fm):
    """Which column a ticket belongs in."""
    status = fm.get("status", "open").strip().lower()
    if status in DONE:
        return "Done"
    if fm.get("to", "").strip() == "nick":
        return "Waiting on Nick"
    return "In Progress" if status == "taken" else "Todo"


def agent_of(fm):
    """Whose card it is: whoever holds it, else whoever it is addressed to."""
    who = fm.get("taken_by", "").strip() or fm.get("to", "").strip()
    return who if who in ("director", "artist", "playtester", "fixer", "nick") else ""


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


def fields():
    data = run(["project", "field-list", NUMBER, "--owner", OWNER,
                "--format", "json", "--limit", "50"])
    out = {}
    for f in (data or {}).get("fields", []):
        out[f["name"]] = {
            "id": f["id"],
            "options": {o["name"]: o["id"] for o in f.get("options", []) or []},
        }
    return out


def items():
    data = run(["project", "item-list", NUMBER, "--owner", OWNER,
                "--format", "json", "--limit", "200"])
    by_issue = {}
    for it in (data or {}).get("items", []):
        num = (it.get("content") or {}).get("number")
        if num is not None:
            by_issue[str(num)] = it["id"]
    return by_issue


def set_field(project_id, item_id, field, value, dry):
    """Set one field on one card; a single-select needs its option id."""
    if not field or value in (None, ""):
        return
    args = ["project", "item-edit", "--id", item_id,
            "--project-id", project_id, "--field-id", field["id"]]
    if field["options"]:
        opt = field["options"].get(value)
        if not opt:
            return
        args += ["--single-select-option-id", opt]
    else:
        args += ["--text", value]
    if dry:
        print("    would set %s" % value)
        return
    run(args, quiet=True)


def main():
    args = sys.argv[1:]
    if "--selftest" in args:
        assert lane({"status": "open", "to": "fixer"}) == "Todo"
        assert lane({"status": "taken", "to": "fixer"}) == "In Progress"
        assert lane({"status": "open", "to": "nick"}) == "Waiting on Nick"
        # done wins over to: nick -- a finished ticket is not waiting on anyone
        assert lane({"status": "done", "to": "nick"}) == "Done"
        assert lane({"status": "wontfix", "to": "artist"}) == "Done"
        # a taken ticket handed back to Nick is his, not the agent's
        assert lane({"status": "taken", "to": "nick"}) == "Waiting on Nick"
        assert agent_of({"taken_by": "artist", "to": "nick"}) == "artist"
        assert agent_of({"to": "fixer"}) == "fixer"
        assert agent_of({"to": "someone else"}) == ""
        print("BOARD PROJECT SELFTEST OK")
        return 0

    dry = "--dry-run" in args
    os.chdir(os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
    proj = run(["project", "view", NUMBER, "--owner", OWNER, "--format", "json"])
    if not proj:
        print("board project skipped: no project (or gh lacks the 'project' scope)")
        return 0
    project_id = proj["id"]
    flds = fields()
    have = items()

    for name in sorted(os.listdir(REQUESTS)):
        if not name.endswith(".md") or name.startswith("_"):
            continue
        with open(os.path.join(REQUESTS, name), encoding="utf-8") as f:
            text = f.read()
        fm = front(text)
        fm["_answered"] = answered(text)
        num = fm.get("issue", "").strip()
        if not num:
            continue  # not mirrored yet; board_sync opens the issue first
        item_id = have.get(num)
        if not item_id:
            if lane(fm) == "Done":
                continue  # do not import history, only live work
            if dry:
                print("  would add #%s" % num)
                continue
            url = "https://github.com/%s/CardGame/issues/%s" % (OWNER, num)
            added = run(["project", "item-add", NUMBER, "--owner", OWNER,
                         "--url", url, "--format", "json"])
            if not added:
                continue
            item_id = added["id"]
            print("  #%s added" % num)
        if dry:
            print("  would set #%s to %s" % (num, lane(fm)))
            continue
        set_field(project_id, item_id, flds.get("Status"), lane(fm), dry)
        set_field(project_id, item_id, flds.get("Agent"), agent_of(fm), dry)
        set_field(project_id, item_id, flds.get("Priority"),
                  fm.get("priority", "normal").strip() or "normal", dry)
        set_field(project_id, item_id, flds.get("ETA"),
                  fm.get("eta", "").strip() or "not estimated", dry)
    print("board project up to date")
    return 0


if __name__ == "__main__":
    sys.exit(main())
