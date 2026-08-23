"""Talk to the running Blender MCP addon socket directly.

The addon listens on localhost:9876 and speaks newline-free JSON:
{"type": "<command>", "params": {...}} in, {"status","result"|"message"} out.
This is the same socket the MCP server uses, so it works whether or not the
MCP tools happen to be loaded in the current session.

    python tools/blender/bmcp.py scene
    python tools/blender/bmcp.py obj Frog
    python tools/blender/bmcp.py code "import bpy; print(len(bpy.data.objects))"
"""
import json, socket, sys

def send(cmd, params=None, timeout=30.0):
    s = socket.create_connection(("localhost", 9876), timeout=timeout)
    try:
        s.sendall(json.dumps({"type": cmd, "params": params or {}}).encode())
        chunks = []
        while True:
            b = s.recv(65536)
            if not b:
                break
            chunks.append(b)
            try:
                return json.loads(b"".join(chunks).decode())
            except json.JSONDecodeError:
                continue          # response still arriving
        raise RuntimeError("socket closed before a whole response arrived")
    finally:
        s.close()

if __name__ == "__main__":
    a = sys.argv[1:]
    if not a:
        print(__doc__); raise SystemExit(2)
    verb = a[0]
    if verb == "scene":
        r = send("get_scene_info")
    elif verb == "obj":
        r = send("get_object_info", {"object_name": a[1]})
    elif verb == "code":
        r = send("execute_code", {"code": a[1]})
    else:
        r = send(verb, json.loads(a[1]) if len(a) > 1 else {})
    print(json.dumps(r, indent=2)[:4000])
