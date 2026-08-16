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
const os = require("os");
const path = require("path");
const { execFileSync } = require("child_process");

const PORT = 5180;
const DIR = __dirname;

/** Every LAN address this machine answers on, so a phone on the same wifi can
 *  reach the lab without any tunnelling or hosting. */
function lanUrls() {
  const out = [];
  for (const list of Object.values(os.networkInterfaces())) {
    for (const n of list || []) {
      if (n.family === "IPv4" && !n.internal) out.push(`http://${n.address}:${PORT}`);
    }
  }
  return out;
}

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
  // 0.0.0.0, not localhost — binding to the loopback only is what stops a phone
  // on the same wifi from opening this. Nothing here is sensitive: it serves one
  // generated page from your own card data, read-only.
  .listen(PORT, "0.0.0.0", () => {
    console.log(`Card Lab   http://localhost:${PORT}`);
    for (const u of lanUrls()) console.log(`  on phone  ${u}`);
    // Plain ASCII: the Windows console mangles non-ASCII punctuation.
    console.log("\n(Windows may ask to allow Node through the firewall - say yes for Private networks.)");
  });
