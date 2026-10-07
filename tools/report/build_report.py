"""Render Nick's visual status report from design/reports/report.json.

    python3 tools/report/build_report.py [spec.json] [out.html]

The reporter agent edits the JSON (status, needs-you, newest entries first)
and this script does all the layout, so every report looks the same. Images
are repo paths; they are downscaled and embedded, so the page is one
self-contained file the Artifact tool can publish.
"""
import base64
import html
import io
import json
import sys
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
SPEC = Path(sys.argv[1]) if len(sys.argv) > 1 else ROOT / "design/reports/report.json"
OUT = Path(sys.argv[2]) if len(sys.argv) > 2 else ROOT / "design/reports/report.html"
MAX_ENTRIES = 14
IMG_W = 1100


def img_uri(rel: str) -> str:
    p = (ROOT / rel) if not Path(rel).is_absolute() else Path(rel)
    if not p.exists():
        return ""
    im = Image.open(p).convert("RGB")
    if im.width > IMG_W:
        im = im.resize((IMG_W, round(im.height * IMG_W / im.width)), Image.LANCZOS)
    buf = io.BytesIO()
    im.save(buf, "JPEG", quality=74, optimize=True)
    return "data:image/jpeg;base64," + base64.b64encode(buf.getvalue()).decode()


def e(s) -> str:
    return html.escape(str(s))


def figure(im: dict, cls: str = "") -> str:
    uri = img_uri(im["path"])
    if not uri:
        return ""
    cap = e(im.get("caption", ""))
    return (f'<figure class="{cls}"><button class="zoom" type="button" aria-label="Enlarge: {cap}">'
            f'<img src="{uri}" alt="{cap}" loading="lazy"></button>'
            f'<figcaption>{cap}</figcaption></figure>')


def render(spec: dict) -> str:
    status = "".join(
        f'<div class="stat" data-state="{e(s.get("state", "idle"))}"><span class="k">{e(s["label"])}</span>'
        f'<span class="v">{e(s["value"])}</span></div>' for s in spec.get("status", []))
    needs = spec.get("needs_you", [])
    needs_html = ("<section class=\"needs\"><h2>Needs you</h2><ul>" +
                  "".join(f"<li>{e(n)}</li>" for n in needs) + "</ul></section>") if needs else ""
    latest = spec.get("latest")
    latest_html = ""
    if latest:
        latest_html = ('<section class="latest"><h2>Your drawing vs the game, now</h2>'
                       + figure(latest, "hero") + "</section>")
    items = []
    for en in spec.get("entries", [])[:MAX_ENTRIES]:
        bullets = "".join(f"<li>{e(b)}</li>" for b in en.get("bullets", []))
        figs = "".join(figure(i) for i in en.get("images", []))
        items.append(
            f'<article class="entry" data-agent="{e(en.get("agent", ""))}">'
            f'<header><span class="chip">{e(en.get("agent", ""))}</span>'
            f'<time>{e(en.get("time", ""))}</time></header>'
            f'<h3>{e(en["title"])}</h3><ul>{bullets}</ul>'
            f'<div class="shots">{figs}</div></article>')
    return TEMPLATE.format(
        updated=e(spec.get("updated", "")), status=status, needs=needs_html,
        latest=latest_html, entries="".join(items))


TEMPLATE = """<title>Titan-Slayers Agent Report</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Saira+Condensed:wght@600;700&family=IBM+Plex+Sans:wght@400;500&family=IBM+Plex+Mono:wght@500&display=swap">
<style>
/* Layout: a field log. Status strip, then what needs Nick, then the live
   pair, then a newest-first column of run cards, each mostly pictures. */
:root {{
  --bg: #f3efec; --panel: #fffaf6; --fg: #241a17; --muted: #75655e; --line: #e2d6cf;
  --ember: #c4471b; --builder: #2f6f8f; --checker: #9a3d7a;
  --ok: #2e7d4f; --warn: #b7791f; --bad: #b3261e;
  --display: "Saira Condensed", "Arial Narrow", sans-serif;
  --body: "IBM Plex Sans", system-ui, sans-serif;
  --mono: "IBM Plex Mono", ui-monospace, monospace;
}}
@media (prefers-color-scheme: dark) {{ :root:not([data-theme="light"]) {{
  --bg: #16110f; --panel: #211915; --fg: #f1e6df; --muted: #a8968c; --line: #3a2d27;
  --ember: #ff7a3d; --builder: #6fb6d8; --checker: #e08ac4;
  --ok: #5cc98a; --warn: #f0b54a; --bad: #ff7b72; color-scheme: dark }} }}
:root[data-theme="dark"] {{
  --bg: #16110f; --panel: #211915; --fg: #f1e6df; --muted: #a8968c; --line: #3a2d27;
  --ember: #ff7a3d; --builder: #6fb6d8; --checker: #e08ac4;
  --ok: #5cc98a; --warn: #f0b54a; --bad: #ff7b72; color-scheme: dark }}
body {{ background: var(--bg); color: var(--fg); font: 15px/1.5 var(--body); }}
.wrap {{ max-width: 1080px; margin: 0 auto; padding-inline: 16px; padding-block: 20px 48px;
  display: grid; gap: 28px; }}
.top {{ display: flex; flex-wrap: wrap; align-items: baseline; justify-content: space-between; gap: 8px; }}
h1 {{ font: 700 clamp(28px, 6vw, 40px)/1 var(--display); letter-spacing: .02em; margin: 0;
  text-transform: uppercase; text-wrap: balance; }}
h1 span {{ color: var(--ember); }}
.updated {{ font: 500 12px var(--mono); color: var(--muted); }}
h2 {{ font: 700 15px var(--display); letter-spacing: .08em; text-transform: uppercase;
  color: var(--muted); margin: 0 0 10px; }}
.status {{ display: grid; grid-template-columns: repeat(auto-fit, minmax(190px, 1fr)); gap: 10px; }}
.stat {{ background: var(--panel); border: 1px solid var(--line); border-left: 4px solid var(--muted);
  border-radius: 6px; padding: 10px 12px; display: grid; gap: 2px; min-width: 0; }}
.stat[data-state="working"] {{ border-left-color: var(--ok); }}
.stat[data-state="blocked"] {{ border-left-color: var(--bad); }}
.stat[data-state="waiting"] {{ border-left-color: var(--warn); }}
.k {{ font: 500 11px var(--mono); text-transform: uppercase; letter-spacing: .08em; color: var(--muted); }}
.v {{ font-weight: 500; }}
.needs {{ background: color-mix(in srgb, var(--warn) 12%, var(--panel)); border: 1px solid
  color-mix(in srgb, var(--warn) 45%, var(--line)); border-radius: 8px; padding: 14px 16px; }}
.needs h2 {{ color: var(--warn); }}
.needs ul, .entry ul {{ margin: 0; padding-left: 18px; display: grid; gap: 4px; }}
figure {{ margin: 0; display: grid; gap: 4px; min-width: 0; }}
figcaption {{ font: 500 12px var(--mono); color: var(--muted); }}
.zoom {{ all: unset; cursor: zoom-in; display: block; border-radius: 6px; overflow: hidden;
  border: 1px solid var(--line); background: #000; }}
.zoom:focus-visible {{ outline: 2px solid var(--ember); outline-offset: 2px; }}
.zoom img {{ display: block; width: 100%; height: auto; }}
.entries {{ display: grid; gap: 14px; }}
.entry {{ background: var(--panel); border: 1px solid var(--line); border-radius: 8px;
  padding: 14px 16px; display: grid; gap: 8px; min-width: 0; }}
.entry header {{ display: flex; gap: 10px; align-items: center; }}
.chip {{ font: 700 12px var(--display); letter-spacing: .1em; text-transform: uppercase;
  padding: 2px 8px; border-radius: 4px; color: var(--panel); background: var(--muted); }}
.entry[data-agent="builder"] .chip {{ background: var(--builder); }}
.entry[data-agent="checker"] .chip {{ background: var(--checker); }}
time {{ font: 500 12px var(--mono); color: var(--muted); font-variant-numeric: tabular-nums; }}
h3 {{ margin: 0; font: 700 21px/1.15 var(--display); letter-spacing: .01em; text-wrap: balance; }}
.shots {{ display: grid; grid-template-columns: repeat(auto-fit, minmax(260px, 1fr)); gap: 10px; }}
.lb {{ position: fixed; inset: 0; background: rgb(0 0 0 / .92); display: grid; place-items: center;
  padding: 16px; z-index: 9; cursor: zoom-out; }}
.lb img {{ max-width: 100%; max-height: 100%; }}
</style>
<div class="wrap">
  <div class="top"><h1>Titan-Slayers <span>agents</span></h1><span class="updated">Updated {updated}</span></div>
  <section><h2>Right now</h2><div class="status">{status}</div></section>
  {needs}
  {latest}
  <section><h2>Recent runs</h2><div class="entries">{entries}</div></section>
</div>
<div class="lb" hidden></div>
<script>
const lb = document.querySelector('.lb');
document.querySelectorAll('.zoom').forEach(b => b.addEventListener('click', () => {{
  lb.innerHTML = ''; const i = new Image(); i.src = b.querySelector('img').src; i.alt = '';
  lb.append(i); lb.hidden = false; }}));
lb.addEventListener('click', () => {{ lb.hidden = true; }});
document.addEventListener('keydown', ev => {{ if (ev.key === 'Escape') lb.hidden = true; }});
</script>
"""

if __name__ == "__main__":
    spec = json.loads(SPEC.read_text(encoding="utf-8"))
    OUT.write_text(render(spec), encoding="utf-8")
    print(f"wrote {OUT} ({OUT.stat().st_size // 1024} KB)")
