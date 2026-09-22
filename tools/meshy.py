"""Minimal Meshy API client. Reads MESHY_API_KEY from the meshy MCP entry in
~/.claude.json at run time; never prints it.

    python meshy.py balance
    python meshy.py preview "<prompt>"          -> prints task id
    python meshy.py refine <preview_id> ["<texture prompt>"]
    python meshy.py get <id>                     -> status, progress
    python meshy.py fetch <id> <out_prefix>      -> <out>.glb + <out>_thumb.png
"""
import json, os, sys, urllib.request

def key():
    cfg = json.load(open(os.path.expanduser("~/.claude.json"), encoding="utf-8"))
    return cfg["mcpServers"]["meshy"]["env"]["MESHY_API_KEY"]

BASE = "https://api.meshy.ai"

def call(method, path, body=None):
    req = urllib.request.Request(BASE + path, method=method,
        data=json.dumps(body).encode() if body is not None else None,
        headers={"Authorization": "Bearer " + key(), "Content-Type": "application/json"})
    with urllib.request.urlopen(req, timeout=120) as r:
        return json.loads(r.read().decode())

def dl(url, out):
    with urllib.request.urlopen(url, timeout=300) as r, open(out, "wb") as f:
        f.write(r.read())

cmd = sys.argv[1]
if cmd == "balance":
    print(call("GET", "/openapi/v1/balance"))
elif cmd == "preview":
    print(call("POST", "/openapi/v2/text-to-3d", {
        "mode": "preview", "prompt": sys.argv[2], "ai_model": "latest",
        "should_remesh": True, "topology": "quad", "target_polycount": 14000,
        "target_formats": ["glb"]})["result"])
elif cmd == "refine":
    body = {"mode": "refine", "preview_task_id": sys.argv[2], "target_formats": ["glb"],
            "texture_resolution": "2k"}
    if len(sys.argv) > 3:
        body["texture_prompt"] = sys.argv[3]
    print(call("POST", "/openapi/v2/text-to-3d", body)["result"])
elif cmd == "get":
    t = call("GET", "/openapi/v2/text-to-3d/" + sys.argv[2])
    print(t["status"], t.get("progress"), t.get("task_error") or "")
elif cmd == "fetch":
    t = call("GET", "/openapi/v2/text-to-3d/" + sys.argv[2])
    dl(t["model_urls"]["glb"], sys.argv[3] + ".glb")
    if t.get("thumbnail_url"):
        dl(t["thumbnail_url"], sys.argv[3] + "_thumb.png")
    print("saved", sys.argv[3])
