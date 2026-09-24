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
OWNER = "nbensen6"
REQUESTS = os.path.join("design", "agents", "requests")
# The local redirector (tools/board_link.py). GitHub allows http links and
# strips obsidian:// ones, so every button on an issue goes through here.
LINK_HELPER = "http://127.0.0.1:8787"
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


def stamp_ticket(text, num):
    """Put a visible `**#N**` under the note's title.

    The issue number is the ticket number -- there is no point inventing a
    second one -- but it lived only in the frontmatter, where nobody reading
    the note would ever quote it. This puts it where an agent writing "see #8"
    can actually see it. Left alone if it is already there, so the sync can run
    as often as it likes.
    """
    nl = "\r\n" if "\r\n" in text else "\n"
    if re.search(r"^\*\*#\d+\*\*", text, re.M):
        return text
    m = re.search(r"^#\s+.+$", text, re.M)
    if not m:
        return text
    return text[:m.end()] + nl + nl + "**#%s**" % num + text[m.end():]


def status_line(fm):
    """The one line Nick reads before deciding whether to open the issue.

    Everything in it already lives in the frontmatter except `eta:`, which the
    agent taking the request fills in -- a request with no estimate reads "not
    estimated" rather than silently implying "soon".
    """
    owner = fm.get("taken_by", "").strip() or fm.get("to", "?").strip()
    state = fm.get("status", "open").strip()
    bits = [
        "**Priority:** " + (fm.get("priority", "normal").strip() or "normal"),
        "**Owner:** " + owner,
        "**Status:** " + state,
        "**ETA:** " + (fm.get("eta", "").strip() or "not estimated"),
    ]
    return " · ".join(bits)


def assignees_for(fm):
    """Assign Nick the issues that are his.

    A label filter works, but assignment is what GitHub's own "Assigned to you"
    view and the mobile app's home tab key off -- so `to: nick` becomes a real
    assignment and he never has to remember a query. Agent-owned issues stay
    unassigned: there is no GitHub account behind "the fixer".
    """
    return [OWNER] if fm.get("to", "") == "nick" else []


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
    # encoding, explicitly: text=True decodes with the locale codepage, which on
    # this machine is cp1252, and GitHub returns UTF-8. Nick's first comment came
    # back with its em dash as "a-tilde-euro-mdash" -- his words reaching the
    # agents corrupted is exactly what this pipe must not do.
    p = subprocess.run(cmd, capture_output=True, text=True,
                       encoding="utf-8", errors="replace")
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
    # GitHub's markdown sanitiser strips every link whose scheme is not http,
    # https or mailto -- verified 2026-09-24 by reading issue #8's rendered
    # body_html: the https link survived, the obsidian:// one was gone, which
    # is why it showed up as plain text. http IS allowed, so the buttons point
    # at the local redirector (tools/board_link.py) and it hands the browser
    # the obsidian:// address GitHub would not print.
    head = status_line(fm) + "\n\n"
    head += "**[Open in Obsidian](%s/note/%s)**" % (LINK_HELPER, quote(in_vault))
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
    # Point the whole line at the redirector. Replacing just the URI inside the
    # markdown link would leave a link GitHub strips; replacing the line keeps
    # it a real, clickable button.
    return re.sub(
        r"^.*\(obsidian://shell-commands/\?vault=design&execute=fight-request-beast\).*$",
        "▶ **[Fight this now](%s/fight/%s)** — opens the game into this fight."
        % (LINK_HELPER, quote(beast)),
        body, count=1, flags=re.M)


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
                      *sum((["-f", "labels[]=" + l] for l in labels_for(fm)), []),
                      *sum((["-f", "assignees[]=" + a] for a in assignees_for(fm)), []))
            if not made:
                continue
            num = str(made["number"])
            with open(path, "w", encoding="utf-8", newline="") as f:
                f.write(stamp_ticket(set_field(text, "issue", num), num))
            print("  #%s opened for %s" % (num, name))
            changed.append(path)
            continue

        want_state = "closed" if status in DONE else "open"
        if dry:
            print("  would update #%s (%s) from %s" % (num, want_state, name))
            continue
        stamped = stamp_ticket(text, num)
        if stamped != text:
            with open(path, "w", encoding="utf-8", newline="") as f:
                f.write(stamped)
            _, _, body = split_note(stamped)
            changed.append(path)
        args = ["-X", "PATCH", "repos/%s/issues/%s" % (REPO, num),
                "-f", "title=" + title,
                "-f", "body=" + issue_body(path, body, fm),
                "-f", "state=" + want_state]
        # An agent hands a request back by flipping `to:` to nick, so the
        # assignment has to follow that, not just be set once at creation.
        mine = assignees_for(fm)
        args += sum((["-f", "assignees[]=" + a] for a in mine), []) or ["-F", "assignees[]="]
        for label in labels_for(fm):
            args += ["-f", "labels[]=" + label]
        gh(*args, quiet=True)
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

BOARD_NOTE = os.path.join("design", "agents", "Task board.md")


def mirror_board(dry):
    """Keep one long-lived issue holding the generated task board.

    A GitHub Project would be the obvious home, but Projects v2 is GraphQL-only
    and GraphQL is blocked for these sessions, so a single issue it is -- which
    also means it arrives in the mobile app like everything else.
    """
    if not os.path.exists(BOARD_NOTE):
        return []
    with open(BOARD_NOTE, encoding="utf-8", newline="") as f:
        text = f.read()
    fm, _, body = split_note(text)
    num = fm.get("issue", "").strip()
    if dry:
        print("  would %s the task board issue" % ("update #" + num if num else "open"))
        return []
    if not num:
        made = gh("-X", "POST", "repos/%s/issues" % REPO,
                  "-f", "title=Task board — what the agents are doing",
                  "-f", "body=" + body)
        if not made:
            return []
        num = str(made["number"])
        with open(BOARD_NOTE, "w", encoding="utf-8", newline="") as f:
            f.write(set_field(text, "issue", num))
        print("  #%s opened for the task board" % num)
        return [BOARD_NOTE]
    gh("-X", "PATCH", "repos/%s/issues/%s" % (REPO, num),
       "-f", "body=" + body, quiet=True)
    return []


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
    assert assignees_for({"to": "nick"}) == ["nbensen6"]
    assert assignees_for({"to": "artist"}) == []
    assert "blocked-on-nick" in labels_for({"to": "nick", "waiting": "true"})

    # CRLF notes are the norm here; the rewrite must not mix endings
    crlf = t.replace("\n", "\r\n")
    assert "\n" not in set_field(crlf, "issue", "7").replace("\r\n", "")

    # a note with no frontmatter is left alone rather than corrupted
    assert split_note("# just a title")[2] == "# just a title"

    # the mirrored fight link must name its beast, or it is dead from a browser
    link = "obsidian://shell-commands/?vault=design&execute=fight-request-beast"
    out = fight_link("before\n- [Fight](%s) - blurb\nafter" % link, {"beast": "cinder_jackal"})
    assert "(http://127.0.0.1:8787/fight/cinder_jackal)" in out, out
    assert "obsidian://" not in out, out
    # the whole line goes, not just the URI -- a half-replaced markdown link
    # renders as broken text on GitHub
    assert "[Fight](" not in out, out
    assert "before" in out and "after" in out
    # a note with no beast is left exactly as written, not half-rewritten
    assert fight_link("x %s y" % link, {}) == "x %s y" % link

    # the ticket number becomes visible under the title, once, however often
    # the sync runs
    stamped = stamp_ticket("---\nto: fixer\n---\n\n# A title\n\nbody\n", "12")
    assert "# A title\n\n**#12**" in stamped, stamped
    assert stamp_ticket(stamped, "12") == stamped
    # and the title itself is untouched, or the issue would rename itself every
    # run to "#12 #12 A title"
    assert title_of(stamped, "x") == "A title"
    assert stamp_ticket("no heading here", "3") == "no heading here"

    b = issue_body(os.path.join("design", "agents", "requests", "a.md"), "# T", {})
    assert "(http://127.0.0.1:8787/note/agents/requests/a)" in b, b
    assert "/blob/main/design/agents/requests/a.md" in b
    # Nothing in an issue may be an obsidian:// link: GitHub deletes those, and
    # a deleted link is what sent Nick copy-pasting in the first place
    assert "obsidian://" not in b, b
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
    changed = push(dry) + pull(dry) + mirror_board(dry)
    if not changed:
        print("  nothing changed")
    return 0


if __name__ == "__main__":
    sys.exit(main())
