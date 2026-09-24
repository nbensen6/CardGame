"""A tiny localhost redirector, so GitHub issues can have real buttons.

Why
---
GitHub's markdown sanitiser strips every link whose scheme is not http, https
or mailto -- verified 2026-09-24 against issue #8's rendered HTML: the https
link survived, the obsidian:// one was gone. So `[Fight this now](obsidian://)`
renders as plain text and there is nothing to click, in any tab.

http:// IS allowed. So the issue links here instead, and this hands the browser
a redirect to the obsidian:// address it was not allowed to print:

    http://127.0.0.1:8787/fight/cinder_jackal   -> opens that fight
    http://127.0.0.1:8787/note/agents/requests/x -> opens that note in Obsidian

Only ever binds to 127.0.0.1, so nothing outside this machine can reach it, and
it only ever emits obsidian:// URIs built from a strict whitelist pattern -- a
request for anything else gets a 404 rather than being echoed back.

    python tools/board_link.py            # serve (blocks)
    python tools/board_link.py --selftest # the routing rules, no socket

tools/board_pull.cmd starts it if it is not already running, so the half-hourly
sync doubles as a keep-alive: the link is dead only if the PC is off, in which
case Obsidian would not open anyway.
"""

import re
import sys
from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib.parse import quote, unquote

PORT = 8787
VAULT = "design"

# A beast id is a bare lowercase identifier; a note path is vault-relative with
# no traversal. Anything else is refused rather than reflected into a URI.
BEAST = re.compile(r"^[a-z0-9_]+$")
NOTE = re.compile(r"^[A-Za-z0-9 _./-]+$")


def target(path):
    """The obsidian:// address for a request path, or None to 404."""
    path = unquote(path.split("?")[0]).strip("/")
    if path.startswith("fight/"):
        beast = path[len("fight/"):]
        if BEAST.match(beast):
            return ("obsidian://shell-commands/?vault=%s&execute=fight-uri-beast&_beast=%s"
                    % (VAULT, quote(beast)))
        return None
    if path.startswith("note/"):
        note = path[len("note/"):]
        if NOTE.match(note) and ".." not in note:
            return "obsidian://open?vault=%s&file=%s" % (VAULT, quote(note))
        return None
    return None


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        where = target(self.path)
        if not where:
            self.send_response(404)
            self.end_headers()
            self.wfile.write(b"Titan-Slayers link helper: nothing at that address.")
            return
        # 302 rather than 301: a permanent redirect gets cached by the browser,
        # and then changing what a link points at stops working until someone
        # clears it.
        self.send_response(302)
        self.send_header("Location", where)
        self.end_headers()

    def log_message(self, *a):
        pass  # it runs hidden; a console it cannot show is just noise


def selftest():
    assert target("/fight/cinder_jackal").endswith("_beast=cinder_jackal")
    assert "execute=fight-uri-beast" in target("/fight/thrasher")
    assert target("/note/agents/requests/a-note") == (
        "obsidian://open?vault=design&file=agents/requests/a-note")
    # a path with a space survives, encoded
    assert "%20" in target("/note/My Note")
    # everything else is refused rather than echoed into a URI
    assert target("/") is None
    assert target("/fight/") is None
    assert target("/fight/../../etc/passwd") is None
    assert target("/note/../../../secrets") is None
    assert target("/fight/Cinder Jackal") is None      # not an id
    assert target("/evil") is None
    print("BOARD LINK SELFTEST OK")


def main():
    if "--selftest" in sys.argv[1:]:
        selftest()
        return 0
    try:
        HTTPServer(("127.0.0.1", PORT), Handler).serve_forever()
    except OSError as e:
        # Already running is the normal case when the sync starts it again.
        print("board link helper not started: %s" % e)
        return 0


if __name__ == "__main__":
    sys.exit(main())
