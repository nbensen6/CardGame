"""Exit 0 if design/plan/BUILDER-QUEUE.md has an open `- [ ]` item under ## Now,
else exit 1. run.cmd's loop uses it to stop when there is nothing to take."""
import re
import sys
from pathlib import Path

q = Path(__file__).resolve().parents[2] / "design" / "plan" / "BUILDER-QUEUE.md"
text = q.read_text(encoding="utf-8")
m = re.search(r"^## Now.*$", text, re.M)
now = text[m.end():].split("\n## ", 1)[0] if m else ""
open_items = re.findall(r"^- \[ \] \*\*", now, re.M)
print(f"has_open: {len(open_items)} open item(s) under Now")
sys.exit(0 if open_items else 1)
