"""Write design/Needs Nick.md: one line per thing waiting on Nick, nothing else.

Read from design/plan/BUILDER-QUEUE.md. A `[?]` item is "built, look and tick";
an open item under `## Waiting on Nick` is "decide". Title only, no detail;
the queue has the detail. Run by tools/builder/run.cmd after every run, or by
hand:  python tools\\needs_nick.py
"""
import re
from datetime import datetime
from pathlib import Path
from zoneinfo import ZoneInfo

ROOT = Path(__file__).resolve().parents[1]
QUEUE = ROOT / "design" / "plan" / "BUILDER-QUEUE.md"
OUT = ROOT / "design" / "Needs Nick.md"
FRAMES = ROOT / "design" / "agents" / "frames" / "builder"

text = QUEUE.read_text(encoding="utf-8")
now_section = text.split("## Waiting on Nick")[0]
waiting = text.split("## Waiting on Nick")[1].split("\n## ")[0] if "## Waiting on Nick" in text else ""

def titles(block, mark):
    return re.findall(r"^- \[" + re.escape(mark) + r"\] \*\*(.+?)\*\*", block, re.M)

look = titles(now_section, "?")
decide = titles(waiting, " ")
frames = sorted(FRAMES.glob("*-after.png"), key=lambda p: p.stat().st_mtime, reverse=True)[:8]
stamp = datetime.now(ZoneInfo("America/New_York")).strftime("%Y-%m-%d %H:%M %Z")

lines = ["---", "tags:", "  - home", "---", "", "# Needs Nick", "",
         f"_{stamp}. Generated from [[BUILDER-QUEUE]]; edit there, or tell Claude._", ""]
if decide:
    lines += ["## Decide", ""] + [f"- [ ] {t}" for t in decide] + [""]
if look:
    lines += ["## Look, then tick or send back", ""] + [f"- [ ] {t}" for t in look] + [""]
if not decide and not look:
    lines += ["Nothing. The builder is either running or waiting for a new line in [[BUILDER-QUEUE]].", ""]
if frames:
    lines += ["## Latest frames", ""] + [f"- [[agents/frames/builder/{p.name}|{p.stem.removesuffix('-after')}]]" for p in frames] + [""]
OUT.write_text("\n".join(lines), encoding="utf-8")
print(f"{OUT.name}: {len(decide)} to decide, {len(look)} to look at")
