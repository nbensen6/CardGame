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


def answered(text):
    """Has Nick actually said something under `## Nick's answer` yet?

    "Waiting on Nick" has to clear itself the moment he replies, rather than
    when an agent next happens to notice -- otherwise his own board keeps
    showing him work he has already done. Blank lines and the template's HTML
    comment do not count as an answer; a heading that carries his own date
    (`## Nick's answer - 2026-09-24 11:47 EDT`) does, because that is how he
    and Claude have been writing them.
    """
    i = text.find("## Nick's answer")
    if i == -1:
        return False
    if "\n" in text[i:] and text[i:text.find("\n", i)].strip() != "## Nick's answer":
        return True  # the heading itself is dated, so it was answered
    rest = text[text.find("\n", i) + 1:] if "\n" in text[i:] else ""
    nxt = rest.find("\n## ")
    body = rest[:nxt if nxt != -1 else len(rest)]
    body = re.sub(r"<!--.*?-->", "", body, flags=re.S)
    return bool(body.strip())


def assignees_for(fm):
    """Assign Nick the issues that are his.

    A label filter works, but assignment is what GitHub's own "Assigned to you"
    view and the mobile app's home tab key off -- so `to: nick` becomes a real
    assignment and he never has to remember a query. Agent-owned issues stay
    unassigned: there is no GitHub account behind "the fixer".
    """
    return [OWNER] if fm.get("to", "") == "nick" and not fm.get("_answered") else []


def labels_for(fm):
    out = []
    to = fm.get("to", "")
    if to == "nick" and not fm.get("_answered"):
        out.append("for:nick")
    elif to in ("director", "artist", "playtester", "fixer"):
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


def gh_json(method, path, payload):
    """PATCH/POST with a JSON body on stdin, for fields `-f` cannot express."""
    p = subprocess.run([GH, "api", "-X", method, path, "--input", "-"],
                       input=json.dumps(payload), capture_output=True,
                       text=True, encoding="utf-8", errors="replace")
    if p.returncode != 0:
        print("  gh %s %s failed: %s" % (method, path,
                                         (p.stderr or "").strip().split("\n")[0]))
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
    # A ticket waiting on Nick is laid out for ONE job: open it, know what to
    # answer, comment. Nick, 2026-09-25: "click them and then immediately know
    # what i need to answer and be able to comment my answer." Everything that
    # is not the question -- mirror links, the agent's own write-up, the
    # frames, the plumbing -- goes into a collapsed section underneath, so the
    # first screen is the decision and nothing else.
    if fm.get("to", "").strip() == "nick" and not fm.get("_answered"):
        return decision_body(path, body, fm)

    head = status_line(fm) + "\n\n"
    head += "**[Open in Obsidian](%s/note/%s)**" % (LINK_HELPER, quote(in_vault))
    head += " · [read it on GitHub](https://github.com/%s/blob/main/%s)\n\n" % (REPO, rel)
    head += "_Mirror of `%s`. The note is the source of truth; " % rel
    head += "comment here and the sync copies it back into the note for the agents._\n\n"
    return head + fight_link(embed_frames(body), fm)


def first_bullets(body, limit=4):
    """The first bullet list in the note -- normally the options he is choosing
    between. Capped, because a fifteen-bullet brief is not a decision screen."""
    out = []
    started = False
    for line in body.split("\n"):
        stripped = line.strip()
        if stripped.startswith(("- ", "* ")):
            if len(out) >= limit:
                break
            started = True
            out.append(stripped[2:].strip())
        elif started and stripped == "":
            continue
        elif started and line.startswith((" ", "\t")):
            # A wrapped continuation of the bullet above. The notes wrap at
            # ~75 columns, so taking only a bullet's first line cut every
            # option off mid-sentence on his decision screen.
            out[-1] += " " + stripped
        elif started:
            break
    # Each option gets a line he can read at a glance, not a paragraph.
    return ["- " + (o if len(o) <= 160 else o[:160].rsplit(" ", 1)[0] + " …")
            for o in out]


def decision_body(path, body, fm):
    """The issue body for something waiting on Nick: question, options, reply.

    Deliberately not the agent's write-up with a heading bolted on top. That is
    what it was, and the question was followed by a status line, two links, a
    mirror disclaimer, the note's own title again and then a relay written for
    another agent -- six lines of plumbing before anything he could act on.
    """
    rel = path.replace(os.sep, "/")
    in_vault = rel[len("design/"):-3] if rel.endswith(".md") else rel
    ask = fm.get("ask", "").strip()
    out = "## ➤ %s\n\n" % (ask or "_No question written — ask the agent what it needs._")
    bullets = first_bullets(body)
    if bullets:
        out += "\n".join(bullets) + "\n\n"
    out += "**Reply in a comment below.** One word is usually enough; "
    out += "the sync passes it to the agent within the half hour.\n\n"
    out += "<details>\n<summary>Background, frames and the full note</summary>\n\n"
    out += "**[Open in Obsidian](%s/note/%s)**" % (LINK_HELPER, quote(in_vault))
    out += " · [read it on GitHub](https://github.com/%s/blob/main/%s)\n\n" % (REPO, rel)
    out += fight_link(embed_frames(body), fm)
    out += "\n\n</details>\n"
    return out


def embed_frames(body):
    """Turn Obsidian's ![[frames/...]] into images GitHub actually renders.

    These tickets argue from evidence -- "here is what a player sees" followed
    by a frame -- and on GitHub that frame was a line of literal text, so the
    argument arrived with its evidence missing and Nick could not tell what was
    being asked (2026-09-25). The blob?raw=1 form renders inline for anyone
    signed in to a private repo, and is still a working link if it does not.

    A target that is not actually in the repo is left exactly as written rather
    than turned into a link that 404s.
    """
    def one(m):
        inner = m.group(1).split("|")[0].strip()
        for base in ("design/agents", "design"):
            path = "%s/%s" % (base, inner)
            if os.path.exists(path.replace("/", os.sep)):
                return "![%s](https://github.com/%s/blob/main/%s?raw=1)" % (
                    os.path.basename(inner), REPO, quote(path))
        return m.group(0)
    return re.sub(r"!\[\[([^\]]+)\]\]", one, body)


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
        fm["_answered"] = answered(text)
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
            # A decision request hangs off the ticket it came out of, as a real
            # GitHub sub-issue. Nick, 2026-09-25: a ticket that starts life
            # addressed to an agent and is later flipped to him reuses the same
            # "What I need" section for two different asks, and it stops being
            # clear who is asking whom. A separate child fixes that -- the
            # parent stays the agent's, the child is his.
            parent = fm.get("parent", "").strip()
            if parent.lstrip("#").isdigit():
                gh_json("POST", "repos/%s/issues/%s/sub_issues" % (
                    REPO, parent.lstrip("#")), {"sub_issue_id": made["id"]})
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
        # Sent as one JSON body rather than -f pairs. Labels and assignees have
        # to go as the WHOLE set every time -- GitHub leaves a key it is not
        # given untouched, so an answered ticket kept its for:nick label and sat
        # on his filter after it stopped being his. And an empty set cannot be
        # expressed with -f at all: `-F "labels[]="` is an empty label NAME and
        # GitHub answers 422, which the quiet call then swallowed.
        gh_json("PATCH", "repos/%s/issues/%s" % (REPO, num), {
            "title": title,
            "body": issue_body(path, body, fm),
            "state": want_state,
            "assignees": assignees_for(fm),
            "labels": labels_for(fm),
        })
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
    # once he has answered it is no longer his: off his assigned list and
    # out of the Waiting-on-Nick column, without waiting for an agent to notice
    assert assignees_for({"to": "nick", "_answered": True}) == []
    assert "for:nick" not in labels_for({"to": "nick", "_answered": True})
    assert answered("## Nick's answer\n\nyes do it\n")
    # the dated-heading form he and Claude actually use
    assert answered("## Nick's answer — 2026-09-24 11:47 EDT\n\nanything\n")
    # the untouched template must NOT read as answered
    assert not answered("## Nick's answer\n\n<!-- type below -->\n\n## Result\n")
    assert not answered("no such heading here")
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

    # an Obsidian embed becomes an image GitHub renders, and an embed whose
    # file is not in the repo is left alone rather than linked to a 404
    real = "agents/frames/director/2026-09-25-0753-director-sigil.png"
    import os as _os
    if _os.path.exists(_os.path.join("design", *real.split("/"))):
        out2 = embed_frames("![[%s]]" % real)
        assert out2.startswith("![") and "blob/main/design/" in out2, out2
        assert "![[" not in out2
    assert embed_frames("![[no/such/file.png]]") == "![[no/such/file.png]]"

    # a ticket waiting on him opens with the question, then options, then how
    # to reply -- and nothing else above the fold
    note = "\n".join(["# Title", "", "## What I need", "",
                      "- option A", "- option B", "", "long prose", ""])
    d = decision_body(os.path.join("design", "agents", "requests", "x.md"),
                      note, {"to": "nick", "ask": "A or B?"})
    assert d.startswith("## ➤ A or B?"), d[:60]
    assert "- option A" in d and "- option B" in d
    assert d.index("Reply in a comment") < d.index("<details>")
    assert "long prose" in d.split("<details>")[1], "the full note is kept, just folded"
    assert first_bullets("\n".join(["- a", "- b", "- c", "- d", "- e"])) \
        == ["- a", "- b", "- c", "- d"]
    assert first_bullets("no bullets here") == []
    # a wrapped bullet is rejoined, not cut off mid-sentence
    wrapped = "\n".join(["- first part of it", "  and the rest", "- second"])
    assert first_bullets(wrapped) == ["- first part of it and the rest", "- second"]
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
