"""Exit 0 if design/plan/BUILDER-QUEUE.md has an open `- [ ]` item under ## Now,
else exit 1. run.cmd's loop uses it to stop when there is nothing to take."""
import re
import sys
from pathlib import Path

q = Path(__file__).resolve().parents[2] / "design" / "plan" / "BUILDER-QUEUE.md"
now = q.read_text(encoding="utf-8").split("## Now", 1)[-1].split("\n## ", 1)[0]
open_items = re.findall(r"^- \[ \] \*\*", now, re.M)
print(f"has_open: {len(open_items)} open item(s) under Now")
sys.exit(0 if open_items else 1)
