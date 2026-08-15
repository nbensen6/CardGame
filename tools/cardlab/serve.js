#!/usr/bin/env node
/**
 * Tiny static server for Card Lab. No dependencies.
 * Rebuilds the dashboard on every page load, so editing card data and hitting
 * refresh is the whole workflow.
 *
 *   node tools/cardlab/serve.js   → http://localhost:5180
 */
const http = require("http");
const fs = require("fs");
const path = require("path");
const { execFileSync } = require("child_process");

const PORT = 5180;
const DIR = __dirname;

http
  .createServer((req, res) => {
    const url = (req.url || "/").split("?")[0];
    if (url === "/" || url === "/index.html" || url === "/cardlab.html") {
      try {
        execFileSync(process.execPath, [path.join(DIR, "build.js")], { stdio: "pipe" });
      } catch (e) {
        res.writeHead(500, { "content-type": "text/plain; charset=utf-8" });
        return res.end("Build failed:\n\n" + (e.stderr || e.message));
      }
      const html = fs.readFileSync(path.join(DIR, "cardlab.html"));
      res.writeHead(200, { "content-type": "text/html; charset=utf-8" });
      return res.end(html);
    }
    res.writeHead(404, { "content-type": "text/plain" });
    res.end("not found");
  })
  .listen(PORT, () => console.log(`Card Lab on http://localhost:${PORT}`));
