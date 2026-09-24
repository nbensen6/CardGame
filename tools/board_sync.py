"""Mirror the agents' request board to GitHub Issues, both ways.

Why this exists
---------------
Nick wanted the request board moved to GitHub Issues: real assignees, state,
and notifications on his phone. The cloud agents cannot do it -- a probe on
2026-09-24 found they can READ issues through `gh api` but every write is
refused by the sandbox's own policy ("[External System Writes]"), and the
`gh issue ...` subcommands do not work there at all because GraphQL is
blocked. So the agents keep writing markdown, which they can do, and THIS PC
does the mirroring, because it has no such restriction.

The markdown note stays the source of truth. The issue is a mirror Nick can
talk to from anywhere; anything he says there is copied back into the note,
which is where the agents will read it.

    python tools/board_sync.py            # both directions
    python tools/board_sync.py --dry-run  # say what it would do, touch nothing
    python tools/board_sync.py --selftest # the parsing rules, no network

Called by tools/board_pull.cmd after the pull, so it happens hourly on its
own. Safe to run by hand any time; it is idempotent.
"""

import json
import os
import re
import subprocess
import sys
from urllib.parse import quote

REPO = "nbensen6/CardGame"
REQUESTS = os.path.join("design", "agents", "requests")
GH = "gh"

# Labels the board needs, and the colour each gets on GitHub.
LABELS = {
    "agent:artist": "5319e7",
    "agent:playtester": "0e8a16",
    "agent:fixer": "d93f0b",
    "for:nick": "fbca04",
    "priority:high": "b60205",
    "blocked-on-nick": "e99695",
}

DONE = ("done", "wontfix")


# --------------------------------------------------------------------------
# frontmatter
# --------------------------------------------------------------------------

def split_note(text):
    """(frontmatter dict, raw frontmatter block, body) for a note.

    Deliberately NOT a YAML parser: these notes are written by three different
    agents and by hand, and a strict parser that rejects an odd line would
    stop the whole sync over a stray colon. Anything it cannot read it leaves
    alone -- the block is rewritten line by line, never re-serialised.
    """
    if not text.startswith("---"):
        return {}, "", text
    end = text.find("\n---", 3)
    if end == -1:
        return {}, "", text
    block = text[3:end].strip("\n")
    body = text[end + 4:].lstrip("\n")
    fm = {}
    for line in block.split("\n"):
        if line.startswith("#") or not line.strip():
            continue
        if ":" in line and not line.startswith(" ") and not line.startswith("-"):
            k, v = line.split(":", 1)
            fm[k.strip()] = v.strip()
    return fm, block, body


def set_field(text, key, value):
    """Set one frontmatter field, keeping every other line byte-for-byte."""
    nl = "\r\n" if "\r\n" in text else "\n"
    fm, block, body = split_note(text)
    line = "%s: %s" % (key, value)
    lines = block.split("\n")
    for i, existing in enumerate(lines):
        if existing.split(":", 1)[0].strip() == key and not existing.startswith(" "):
            lines[i] = line
            break
    else:
        lines.append(line)
    return "---" + nl + nl.join(lines) + nl + "---" + nl + nl + body


def title_of(body, fallback):
    m = re.search(r"^#\s+(.+)$", body, re.M)
    return m.group(1).strip() if m else fallback


def labels_for(fm):
    out = []
    to = fm.get("to", "")
    if to == "nick":
        out.append("for:nick")
    elif to in ("artist", "playtester", "fixer"):
        out.append("agent:" + to)
    if fm.get("priority") == "high":
        out.append("priority:high")
    if fm.get("waiting", "false").lower() == "true":
        out.append("blocked-on-nick")
    return out


# --------------------------------------------------------------------------
# github
# --------------------------------------------------------------------------

def gh(*args, **kw):
    """Run `gh api ...` and return parsed JSON, or None on a handled failure."""
    cmd = [GH, "api"] + list(args)
    p = subprocess.run(cmd, capture_output=True, text=True)
    if p.returncode != 0:
        err = (p.stderr or "").strip()
        if kw.get("quiet"):
            return None
        print("  gh failed: %s" % err.split("\n")[0])
        return None
    try:
        return json.loads(p.stdout or "null")
    except ValueError:
        return None


def gh_ready():
    p = subprocess.run([GH, "auth", "status"], capture_output=True, text=True)
    return p.returncode == 0


def ensure_labels(dry):
    for name, colour in LABELS.items():
        if gh("repos/%s/labels/%s" % (REPO, name), quiet=True):
            continue
        if dry:
            print("  would create label %s" % name)
            continue
        gh("-X", "POST", "repos/%s/labels" % REPO,
           "-f", "name=" + name, "-f", "color=" + colour,
           "-f", "description=Titan-Slayers agent board", quiet=True)


def issue_body(path, body, fm):
    """The issue text: the note, a way back to it, and a way into the game.

    Obsidian embeds (![[frames/...]]) do not render on GitHub. Rather than
    rewrite them into raw URLs and get it subtly wrong, say plainly that the
    frames are in the repo -- the note is the source of truth and this is a
    mirror.
    """
    rel = path.replace(os.sep, "/")
    in_vault = rel.replace("design/", "", 1)
    if in_vault.endswith(".md"):
        in_vault = in_vault[:-3]
    head = "**[Open this note in Obsidian](obsidian://open?vault=design&file=%s)**" % quote(in_vault)
    head += " · [read it on GitHub](https://github.com/%s/blob/main/%s)\n\n" % (REPO, rel)
    head += "_Mirror of `%s`. The note is the source of truth; " % rel
    head += "comment here and the sync copies it back into the note for the agents._\n\n"
    if "![[" in body:
        head += "_(Frames referenced below are in the repo, not rendered here.)_\n\n"
    return head + fight_link(body, fm)


def fight_link(body, fm):
    """Make the note's "Fight this now" link work when clicked from GitHub.

    In the note it runs `play.cmd {{yaml_value:beast}}` -- the beast comes from
    the ACTIVE note in Obsidian, which is right there and useless from a
    browser, where no note is active. The mirrored copy names the beast in the
    URI instead (`&_beast=...`, the plugin's custom-variable parameter), so
    clicking it from an issue on this PC opens the right fight.
    """
    beast = fm.get("beast", "").strip()
    if not beast:
        return body
    return body.replace(
        "obsidian://shell-commands/?vault=design&execute=fight-request-beast",
        "obsidian://shell-commands/?vault=design&execute=fight-uri-beast&_beast=" + quote(beast))


# --------------------------------------------------------------------------
# the two directions
# --------------------------------------------------------------------------

def push(dry):
    """Notes -> issues. Creates, updates, and closes."""
    changed = []
    for name in sorted(os.listdir(REQUESTS)):
        if not name.endswith(".md") or name.startswith("_"):
            continue
        path = os.path.join(REQUESTS, name)
        with open(path, encoding="utf-8", newline="") as f:
            text = f.read()
        fm, _, body = split_note(text)
        status = fm.get("status", "open").lower()
        num = fm.get("issue", "").strip()
        title = title_of(body, name[:-3])

        if not num:
            if status in DONE:
                continue  # never mirror something already finished
            if dry:
                print("  would open an issue for %s" % name)
                continue
            made = gh("-X", "POST", "repos/%s/issues" % REPO,
                      "-f", "title=" + title,
                      "-f", "body=" + issue_body(path, body, fm),
                      *sum((["-f", "labels[]=" + l] for l in labels_for(fm)), []))
            if not made:
                continue
            num = str(made["number"])
            with open(path, "w", encoding="utf-8", newline="") as f:
                f.write(set_field(text, "issue", num))
            print("  #%s opened for %s" % (num, name))
            changed.append(path)
            continue

        want_state = "closed" if status in DONE else "open"
        if dry:
            print("  would update #%s (%s) from %s" % (num, want_state, name))
            continue
        gh("-X", "PATCH", "repos/%s/issues/%s" % (REPO, num),
           "-f", "title=" + title,
           "-f", "body=" + issue_body(path, body, fm),
           "-f", "state=" + want_state, quiet=True)
    return changed


def pull(dry):
    """Issue comments -> notes. Nick talks on his phone; the agents read markdown."""
    changed = []
    for name in sorted(os.listdir(REQUESTS)):
        if not name.endswith(".md") or name.startswith("_"):
            continue
        path = os.path.join(REQUESTS, name)
        with open(path, encoding="utf-8", newline="") as f:
            text = f.read()
        fm, _, _ = split_note(text)
        num = fm.get("issue", "").strip()
        if not num:
            continue
        seen = int(fm.get("synced_comment", "0") or 0)
        comments = gh("repos/%s/issues/%s/comments?per_page=100" % (REPO, num)) or []
        fresh = [c for c in comments if int(c["id"]) > seen]
        if not fresh:
            continue
        if dry:
            print("  would copy %d comment(s) from #%s into %s" % (len(fresh), num, name))
            continue
        nl = "\r\n" if "\r\n" in text else "\n"
        add = ""
        for c in fresh:
            who = c["user"]["login"]
            when = c["created_at"][:16].replace("T", " ")
            add += nl + nl + "**From GitHub #%s (%s, %s UTC):**" % (num, who, when)
            add += nl + nl + c["body"].replace("\r\n", "\n").replace("\n", nl)
        marker = "## Nick's answer"
        if marker in text:
            # Put it under the heading the agents already watch, at the end of
            # that section rather than the top -- newest last reads as a thread.
            nxt = text.find(nl + "## ", text.find(marker) + len(marker))
            cut = len(text) if nxt == -1 else nxt
            text = text[:cut].rstrip() + add + nl + text[cut:]
        else:
            text = text.rstrip() + nl + nl + marker + add + nl
        text = set_field(text, "synced_comment", str(max(int(c["id"]) for c in fresh)))
        with open(path, "w", encoding="utf-8", newline="") as f:
            f.write(text)
        print("  #%s -> %s (%d comment(s))" % (num, name, len(fresh)))
        changed.append(path)
    return changed


# --------------------------------------------------------------------------

def selftest():
    t = "---\ntags:\n  - request\nto: fixer\nstatus: open\n---\n\n# A title\n\nbody\n"
    fm, _, body = split_note(t)
    assert fm["to"] == "fixer", fm
    assert fm["status"] == "open", fm
    assert body.startswith("# A title"), body
    assert title_of(body, "x") == "A title"

    # a list value (tags) must not be mistaken for a field, and an indented
    # line must not overwrite one
    assert "- request" not in fm.values()

    out = set_field(t, "issue", "42")
    assert "issue: 42" in out and "to: fixer" in out and "# A title" in out
    # setting the same field twice must not duplicate it
    assert set_field(out, "issue", "43").count("issue:") == 1

    assert labels_for({"to": "nick", "priority": "high"}) == ["for:nick", "priority:high"]
    assert labels_for({"to": "fixer"}) == ["agent:fixer"]
    assert "blocked-on-nick" in labels_for({"to": "nick", "waiting": "true"})

    # CRLF notes are the norm here; the rewrite must not mix endings
    crlf = t.replace("\n", "\r\n")
    assert "\n" not in set_field(crlf, "issue", "7").replace("\r\n", "")

    # a note with no frontmatter is left alone rather than corrupted
    assert split_note("# just a title")[2] == "# just a title"

    # the mirrored fight link must name its beast, or it is dead from a browser
    link = "obsidian://shell-commands/?vault=design&execute=fight-request-beast"
    out = fight_link("see [Fight](%s) here" % link, {"beast": "cinder_jackal"})
    assert "execute=fight-uri-beast&_beast=cinder_jackal" in out, out
    assert "fight-request-beast" not in out
    # a note with no beast is left exactly as written, not half-rewritten
    assert fight_link("x %s y" % link, {}) == "x %s y" % link

    b = issue_body(os.path.join("design", "agents", "requests", "a.md"), "# T", {})
    assert "obsidian://open?vault=design&file=agents/requests/a" in b, b
    assert "/blob/main/design/agents/requests/a.md" in b
    print("BOARD SYNC SELFTEST OK")


def main():
    args = sys.argv[1:]
    if "--selftest" in args:
        selftest()
        return 0
    dry = "--dry-run" in args
    os.chdir(os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
    if not os.path.isdir(REQUESTS):
        print("no request folder; nothing to sync")
        return 0
    if not gh_ready():
        print("board sync skipped: gh is not logged in (run: gh auth login)")
        return 0
    print("board sync%s" % (" (dry run)" if dry else ""))
    ensure_labels(dry)
    changed = push(dry) + pull(dry)
    if not changed:
        print("  nothing changed")
    return 0


if __name__ == "__main__":
    sys.exit(main())
