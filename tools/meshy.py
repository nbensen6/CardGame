"""Minimal Meshy API client. Reads MESHY_API_KEY from the meshy MCP entry in
~/.claude.json at run time; never prints it.

    python meshy.py balance                      (spend is capped per day: MESHY_DAILY_CAP, default 8 tasks)
    python meshy.py preview "<prompt>"          -> prints task id
    python meshy.py refine <preview_id> ["<texture prompt>"]
    python meshy.py get <id>                     -> status, progress
    python meshy.py fetch <id> <out_prefix>      -> <out>.glb + <out>_thumb.png
"""
import datetime, json, os, sys, urllib.request

# Spending guard. Every generation is logged; past the daily cap the script
# refuses. A preview is ~20 credits, a refine ~10 (2026-09-22: three previews
# plus two refines cost ~100). The builder lane runs unattended, so the cap is
# what stands between a bad loop and Nick's monthly allowance.
DAILY_CAP = int(os.environ.get("MESHY_DAILY_CAP", "8"))   # tasks per day
LEDGER = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "design", "progress", "meshy-ledger.md")

def spent_today():
    today = datetime.date.today().isoformat()
    try:
        return sum(1 for l in open(LEDGER, encoding="utf-8") if l.startswith("| " + today))
    except FileNotFoundError:
        return 0

def log_task(kind, tid, note):
    os.makedirs(os.path.dirname(LEDGER), exist_ok=True)
    new = not os.path.exists(LEDGER)
    with open(LEDGER, "a", encoding="utf-8", newline="\n") as f:
        if new:
            f.write("# Meshy spend ledger\n\nWritten by tools/meshy.py. One row per generation task.\n\n"
                    "| date | kind | task | note |\n|---|---|---|---|\n")
        f.write("| %s | %s | %s | %s |\n" % (datetime.date.today().isoformat(), kind, tid,
                                              note[:80].replace("|", "/")))

def guard():
    n = spent_today()
    if n >= DAILY_CAP:
        sys.exit("REFUSED: %d Meshy tasks already today (cap %d, MESHY_DAILY_CAP)" % (n, DAILY_CAP))

def key():
    """The key, or None. None is normal in the cloud: the environment holds it
    as an API credential and Anthropic's agent proxy adds the Authorization
    header to requests for api.meshy.ai AFTER they leave the sandbox, so the
    agent never sees it. This PC keeps it in the meshy MCP entry."""
    if os.environ.get("MESHY_API_KEY"):
        return os.environ["MESHY_API_KEY"]
    try:
        cfg = json.load(open(os.path.expanduser("~/.claude.json"), encoding="utf-8"))
        return cfg["mcpServers"]["meshy"]["env"]["MESHY_API_KEY"]
    except (OSError, KeyError, ValueError):
        return None

BASE = "https://api.meshy.ai"

def call(method, path, body=None):
    req = urllib.request.Request(BASE + path, method=method,
        data=json.dumps(body).encode() if body is not None else None,
        headers=({"Authorization": "Bearer " + key()} if key() else {}) | {"Content-Type": "application/json"})
    with urllib.request.urlopen(req, timeout=120) as r:
        return json.loads(r.read().decode())

def dl(url, out):
    with urllib.request.urlopen(url, timeout=300) as r, open(out, "wb") as f:
        f.write(r.read())

cmd = sys.argv[1]
if cmd == "balance":
    print(call("GET", "/openapi/v1/balance"))
elif cmd == "preview":
    guard()
    tid = call("POST", "/openapi/v2/text-to-3d", {
        "mode": "preview", "prompt": sys.argv[2], "ai_model": "latest",
        "should_remesh": True, "topology": "quad", "target_polycount": 14000,
        "target_formats": ["glb"]})["result"]
    log_task("preview", tid, sys.argv[2])
    print(tid)
elif cmd == "refine":
    guard()
    body = {"mode": "refine", "preview_task_id": sys.argv[2], "target_formats": ["glb"],
            "texture_resolution": "2k"}
    if len(sys.argv) > 3:
        body["texture_prompt"] = sys.argv[3]
    tid = call("POST", "/openapi/v2/text-to-3d", body)["result"]
    log_task("refine", tid, sys.argv[2])
    print(tid)
elif cmd == "get":
    t = call("GET", "/openapi/v2/text-to-3d/" + sys.argv[2])
    print(t["status"], t.get("progress"), t.get("task_error") or "")
elif cmd == "fetch":
    t = call("GET", "/openapi/v2/text-to-3d/" + sys.argv[2])
    dl(t["model_urls"]["glb"], sys.argv[3] + ".glb")
    if t.get("thumbnail_url"):
        dl(t["thumbnail_url"], sys.argv[3] + "_thumb.png")
    print("saved", sys.argv[3])
