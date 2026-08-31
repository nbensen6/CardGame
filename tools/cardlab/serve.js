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
const { execFileSync, execFile, exec } = require("child_process");

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


/** Godot's headless importer. Without this an uploaded PNG is invisible.
 *
 * Godot does not load a raw file from res:// - it loads the .import sidecar it
 * generates when the editor (or `--headless --import`) first sees the file. So
 * an upload landed on disk, got committed, and the card went on showing its
 * shared icon, because ResourceLoader.exists() was quite correctly saying no.
 *
 * The path can be overridden with GODOT= for anyone whose install is elsewhere.
 */
const GODOT = process.env.GODOT ||
  "C:/Users/nbens/AppData/Local/Programs/Godot/Godot_v4.7.1-stable_win64_console.exe";

function importArt(id, file) {
  if (!fs.existsSync(GODOT)) {
    console.log("art import: no Godot at " + GODOT + " - set GODOT=<path>. " +
      "The file is saved but the game will not see it until something imports it.");
    return commitArt(id, file);
  }
  execFile(GODOT, ["--headless", "--path", path.join(ROOT, "game"), "--import"],
    { timeout: 180000 }, (err) => {
      if (err) console.log("art import: failed - " + err.message);
      else console.log("art import: " + id + ".png is now visible to the game");
      // Commit either way, and AFTER the import, so the .import sidecar goes in
      // the same commit as the picture. Splitting them leaves a checkout where
      // the art exists and the game cannot see it.
      commitArt(id, file);
    });
}


/** Commit a piece of uploaded art, and try to push it.
 *
 * game/assets/cardart/ is tracked but nothing was putting new files INTO a
 * commit, so every upload sat untracked in the working tree - one careless
 * `rm` or `git clean` from gone. That is not hypothetical: on 2026-08-31 a
 * piece of Nick's art was deleted along with two test files by exactly that
 * command, and because it had never been committed there was nothing to
 * recover.
 *
 * Best effort, and deliberately AFTER the response has already been sent. The
 * upload has succeeded by the time this runs; if git is missing, mid-rebase, or
 * the push is rejected, the artist should never see an error about it. Failures
 * are logged to the server console and nowhere else.
 */
function commitArt(id, file) {
  const opts = { cwd: ROOT, timeout: 60000 };
  execFile("git", ["add", "--", file, file + ".import"], opts, (addErr) => {
    if (addErr) return console.log("art commit: git add failed - " + addErr.message);
    execFile("git", ["commit", "-m",
      "Card art for " + id + " (uploaded from the Card Lab, committed so it "
      + "cannot be lost to a stray rm the way an earlier upload was)"
    ], opts, (cErr) => {
      if (cErr) return console.log("art commit: nothing to commit, or " + cErr.message);
      console.log("art commit: committed " + id + ".png");
      // Push is a bonus, not the point. A local commit already makes the file
      // recoverable; this just gets it off the machine.
      execFile("git", ["push", "origin", "HEAD"], opts, (pErr) => {
        if (pErr) {
          console.log("art commit: committed but not pushed - it will go with "
            + "the next push");
        } else {
          console.log("art commit: pushed " + id + ".png");
        }
      });
    });
  });
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
    // Upload art for one card, straight from the browser into the game.
    //
    // Nick asked for the Lab to be where he replaces a card's art, and the
    // alternative was a round trip through the file system for every one of 187
    // cards: export, find the folder, get the filename exactly right, refresh.
    // The Lab already knows the id, so it can name the file itself.
    //
    // Writes ONLY to game/assets/cardart/, only .png, and the id is stripped to
    // its basename and checked against a strict pattern first. A dev server
    // bound to 0.0.0.0 that accepts writes is worth being careful about even on
    // a home network.
    const put = url.match(/^\/upload\/([A-Za-z0-9_]+)$/);
    if (put && req.method === "POST") {
      const dir = path.join(ROOT, "game", "assets", "cardart");
      fs.mkdirSync(dir, { recursive: true });
      const file = path.join(dir, put[1] + ".png");
      const chunks = [];
      let size = 0;
      req.on("data", (c) => {
        size += c.length;
        // 12 MB. A 1024x768 PNG is a few hundred KB; anything past this is a
        // mistake or a probe, and an unbounded upload is a way to fill a disk.
        if (size > 12 * 1024 * 1024) { req.destroy(); return; }
        chunks.push(c);
      });
      req.on("end", () => {
        const buf = Buffer.concat(chunks);
        // Check it really is a PNG rather than trusting the extension.
        const png = buf.length > 8 && buf[0] === 0x89 && buf[1] === 0x50 &&
          buf[2] === 0x4e && buf[3] === 0x47;
        if (!png) {
          res.writeHead(400, { "content-type": "text/plain" });
          return res.end("not a PNG");
        }
        // PNG dimensions live in the IHDR chunk: width and height as big-endian
        // 32-bit ints at bytes 16 and 20. Read them so a wrong-shaped export is
        // caught HERE rather than discovered on a card weeks later.
        //
        // This is not hypothetical. The first art uploaded was 768x1024 -
        // portrait, the shape of the CARD - while the art window is 1024x768
        // landscape, the shape of the WINDOW. It went in, committed, and showed
        // up letterboxed with bars either side, and the obvious conclusion was
        // that the upload had not worked.
        const w = buf.readUInt32BE(16), h = buf.readUInt32BE(20);
        const want = 25 / 19, got = w / h;
        const warn = Math.abs(got - want) > 0.08
          ? "saved, but it is " + w + "x" + h + " and the art window is 4:3 " +
            "landscape - export 1000x760 or it will be cropped"
          : "";
        fs.writeFileSync(file, buf);
        console.log("card art: wrote " + put[1] + ".png (" + buf.length + " bytes)");
        res.writeHead(200, { "content-type": "text/plain" });
        res.end(warn || "ok");
        importArt(put[1], file);
      });
      return;
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
