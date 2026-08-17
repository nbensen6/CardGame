#!/usr/bin/env node
/**
 * Serve a Godot web export over the LAN, so a phone can open it.
 *
 * This exists because an iPhone build needs a Mac (Xcode signs it; there is no
 * Windows path). A web export needs neither a Mac nor a developer account nor a
 * store — you open a URL. Same trick, and the same serve-on-the-LAN shape, as
 * tools/cardlab/serve.js.
 *
 * IMPORTANT: export with **Thread Support OFF**. Threads need SharedArrayBuffer,
 * SharedArrayBuffer needs cross-origin isolation, and that needs a secure
 * context — https or localhost. A phone opening http://192.168.x.x is neither,
 * so a threaded build simply will not boot over the LAN. The game uses no
 * threads of its own, so single-threaded costs nothing here.
 *
 *   Godot → Project → Export… → Web → uncheck Thread Support
 *   → Export Project → build/web/index.html
 *   node tools/webserve.js
 */
const http = require("http");
const fs = require("fs");
const os = require("os");
const path = require("path");
const zlib = require("zlib");

const PORT = 5190;
const ROOT = path.join(__dirname, "..", "build", "web");

const TYPES = {
  ".html": "text/html; charset=utf-8",
  ".js": "text/javascript; charset=utf-8",
  ".json": "application/json",
  // Served with the right type or the browser refuses to stream-compile it,
  // which is the difference between a few seconds and half a minute of staring.
  ".wasm": "application/wasm",
  ".pck": "application/octet-stream",
  ".png": "image/png",
  ".svg": "image/svg+xml",
  ".ico": "image/x-icon",
  ".webmanifest": "application/manifest+json",
};

function lanUrls() {
  const out = [];
  for (const list of Object.values(os.networkInterfaces())) {
    for (const n of list || []) {
      if (n.family === "IPv4" && !n.internal) out.push(`http://${n.address}:${PORT}`);
    }
  }
  return out;
}

if (!fs.existsSync(path.join(ROOT, "index.html"))) {
  console.log(`No web export found at ${ROOT}`);
  console.log("\nIn Godot: Project > Export... > Web (uncheck Thread Support)");
  console.log(`Export to: ${path.join(ROOT, "index.html")}`);
  process.exit(1);
}

http
  .createServer((req, res) => {
    let url = decodeURIComponent((req.url || "/").split("?")[0]);
    if (url === "/") url = "/index.html";
    // Never serve outside the export directory, however the path is written.
    const file = path.join(ROOT, path.normalize(url).replace(/^(\.\.[\\/])+/, ""));
    if (!file.startsWith(ROOT) || !fs.existsSync(file) || fs.statSync(file).isDirectory()) {
      res.writeHead(404, { "content-type": "text/plain" });
      return res.end("not found");
    }
    const type = TYPES[path.extname(file).toLowerCase()] || "application/octet-stream";
    const headers = { "content-type": type, "cache-control": "no-cache" };
    // A Godot wasm+pck is tens of megabytes and this is going over wifi to a
    // phone; gzip turns a minute of waiting into a few seconds.
    const wantsGzip = /\bgzip\b/.test(req.headers["accept-encoding"] || "");
    const compressible = /^(text|application\/(javascript|json|wasm|octet-stream))/.test(type);
    const body = fs.createReadStream(file);
    if (wantsGzip && compressible) {
      headers["content-encoding"] = "gzip";
      res.writeHead(200, headers);
      return body.pipe(zlib.createGzip()).pipe(res);
    }
    headers["content-length"] = fs.statSync(file).size;
    res.writeHead(200, headers);
    body.pipe(res);
  })
  .listen(PORT, "0.0.0.0", () => {
    console.log(`Titan-Slayers (web)   http://localhost:${PORT}`);
    for (const u of lanUrls()) console.log(`  on your phone       ${u}`);
    console.log("\n(Windows may ask to allow Node through the firewall - say yes for Private networks.)");
    console.log("Phone and PC must be on the same wifi. Ctrl+C to stop.");
  });
