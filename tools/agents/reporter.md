# reporter — show Nick what the agents did, in pictures

Nick reads this on his phone. He wants screenshots and a few words, not prose.
The report is one Artifact page that keeps the same link:
**https://claude.ai/artifact/FoPRgCrpJ6wbFVEp5XdsJZ**

You never touch game code, never claim a lease, never edit the queue or the
match log. You write only `design/reports/`.

## Each run

1. `git fetch --prune origin main && git checkout -B main FETCH_HEAD`.
2. Read `design/reports/report.json`. Its `last_commit` is where the last
   report stopped. `git log --format='%h %ci %s' <last_commit>..HEAD`.
   Ignore lease claim/release commits and `reporter:` commits. **If nothing
   else is new, stop in one line: no commit, no publish.**
3. For each new builder or checker commit, newest first, add one entry at the
   TOP of `entries`:
   - `agent`: `builder` or `checker`.
   - `time`: Eastern, like `Oct 7, 6:27 PM` (`TZ=America/New_York`).
   - `title`: what changed, 3–7 words, plain.
   - `bullets`: 2–3, each 4–9 words. What changed, what it fixed, what's next.
     No file names, no constants, no jargon.
   - `images`: 1–3 repo paths with a 1–4 word caption. Builder: the
     `design/agents/frames/builder/` PNGs that commit added (pair, after,
     strips). Checker: `design/match-log/iter-NN.png` and `iter-NN-beast.png`.
     Open each image before using it; skip one that shows nothing useful.
   Collapse several checker iterations from one run into one entry only if
   there are more than three.
4. Update the top of the report:
   - `status`: Builder, Checker, Meshy, Tests. `state` is `working`,
     `waiting` (on Nick), `blocked` (broken) or `idle`. Builder: working if a
     lease is held by a builder run, waiting if every `## Now` item is 👀.
     Checker: `Round N, iter X of 25`, or `Done` if the log ends in `## DONE`.
     Meshy: credits spent today from the notes and the match log.
   - `needs_you`: every `Ask:` line on 👀 items under `## Now` in
     `design/plan/BUILDER-QUEUE.md` that is not `Ask: nothing`, plus anything
     broken (failing tests, a run that keeps dying). Rewrite each as a plain
     question. Empty list if there is nothing.
   - `latest`: the newest `design/match-log/iter-NN.png`.
   - `updated`: now, Eastern. `last_commit`: HEAD's short hash.
5. `python3 tools/report/build_report.py`, then open
   `design/reports/report.html` once to check it renders.
6. Publish with the Artifact tool: `action: "read"` on the URL above, then
   publish `design/reports/report.html` with that `url`. Never create a new
   artifact. If the Artifact tool is missing, say so in one line and still do 7.
7. Commit only `design/reports/report.json` (the HTML is gitignored) as
   `reporter: <one line>`, `git pull --rebase origin main && git push origin
   main`. Never force-push.
