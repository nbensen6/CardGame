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
const { execFileSync, exec } = require("child_process");

const PORT = 5180;
const DIR = __dirname;
const ROOT = path.resolve(__dirname, "..", "..");
const OPEN = process.argv.includes("--open");

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
    // Card art and the shared icons, so the Art tab can actually show them.
    // Read-only, from two fixed folders, and the filename is stripped to its
    // basename first — a static server that will happily read ../../.. is how a
    // dev tool on 0.0.0.0 becomes a way off the machine.
    const asset = url.match(/^\/(art|icon)\/(.+)$/);
    if (asset) {
      const dir = asset[1] === "art"
        ? path.join(ROOT, "game", "assets", "cardart")
        : path.join(ROOT, "game", "assets", "icons");
      const file = path.join(dir, path.basename(decodeURIComponent(asset[2])));
      if (file.startsWith(dir) && fs.existsSync(file)) {
        res.writeHead(200, { "content-type": "image/png", "cache-control": "no-cache" });
        return res.end(fs.readFileSync(file));
      }
      res.writeHead(404);
      return res.end();
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
    // --open is for the desktop shortcut: launch the browser only once the
    // server is actually listening, so the first request can't 404.
    if (OPEN) {
      const url = `http://localhost:${PORT}`;
      const cmd = process.platform === "win32" ? `start "" "${url}"`
        : process.platform === "darwin" ? `open "${url}"` : `xdg-open "${url}"`;
      exec(cmd, () => {});
    }
    console.log("\nLeave this window open while you use the lab. Ctrl+C to stop.");
  });
