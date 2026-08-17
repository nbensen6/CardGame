# Getting Titan-Slayers onto a phone

> Written 2026-08-16 when Nick asked to test from his phone.
> The game code is ready; what's left is a toolchain Godot needs and two
> downloads only you can click.

## What's already done

- **The interface fits a phone.** `ui/screen.gd` runs the UI at 560 logical pixels
  of height on a handheld instead of 720, so every pixel is physically bigger and
  text, buttons, cards and touch targets all grow together. Cards shrink to
  124x186 so the hand doesn't eat the screen, and the menu drops its tagline and
  its desktop-only networking hint to fit a short viewport.
- **Landscape locked.** The HUD puts the beast above, the hand below, and the
  party and climb gauge on the flanks; in portrait there is nowhere for any of it
  to go, so `handheld/orientation` is `landscape` rather than `sensor`.
- **The renderer is already right.** `gl_compatibility` — the mobile-friendly one.
- **Touch already works** without any porting: CLAUDE.md §5 has kept the game
  single-pointer from the start, with no hover-only information anywhere. A tap
  is a click.

You can see the phone layout without a phone:

```bash
Godot_v4.7.1-stable_win64_console.exe --path game --script res://tools/screenshot.gd -- out=C:/tmp/phone.png state=3d size=2340x1080 mobile
```

`mobile` forces the handheld layout; `size=` sets the aspect ratio to shoot at.

## What you need to install (about 20 minutes, mostly downloading)

You already have **Java 17**, which is the part people usually get stuck on.

### 1. Godot export templates

Godot ships the engine; the templates are the runtime it packs INTO your build,
and they are a separate ~1 GB download per version.

In Godot: **Editor → Manage Export Templates… → Download and Install**.
It must match the editor version exactly (4.7.1.stable).

### 2. Android SDK

Godot needs the command-line tools, a platform, and build-tools. The lightest
path is the standalone command-line tools rather than all of Android Studio:

1. Download "Command line tools only" from
   <https://developer.android.com/studio#command-line-tools-only>
2. Unzip to `C:\Android\cmdline-tools\latest\`
3. From `C:\Android\cmdline-tools\latest\bin`:

```bash
sdkmanager.bat "platform-tools" "build-tools;34.0.0" "platforms;android-34"
```

### 3. Point Godot at it, and make a debug key

In Godot: **Editor → Editor Settings → Export → Android**

- **Android SDK Path:** `C:\Android`
- **Debug Keystore:** Godot can generate one — or run:

```bash
keytool -keyalg RSA -genkeypair -alias androiddebugkey -keypass android -keystore debug.keystore -storepass android -dname "CN=Android Debug,O=Android,C=US" -validity 9999 -deststoretype pkcs12
```

Put `debug.keystore` somewhere stable and set it in the same Editor Settings
page, with user `androiddebugkey` and password `android`.

## Then, to get a build on the phone

**One-tap way (best for iterating):** enable Developer Options and USB debugging
on the phone, plug it in, and use Godot's **Remote Deploy** — the little phone
icon in the top-right of the editor. It builds, installs and runs in one click,
and `--remote-debug` sends errors straight back to the editor.

**APK way (no cable):** **Project → Export… → Android → Export Project**, then
get the `.apk` onto the phone however you like and open it. Android will ask you
to allow installing from that source.

Either way the first build is slow (Gradle warms up); later ones are quick.

## iPhone

**An iOS build needs a Mac.** Godot's iOS export produces an Xcode project, and
building and signing it requires Xcode, which is macOS-only. There is no Windows
path to an iPhone build — not a difficult one, not one at all.

So the options are:

| | Cost | Gets you |
|---|---|---|
| **Any Android device** | £0 if you own one | The real thing. Everything above already works. |
| **Web export → Safari** | £0 | Layout and flow on the actual phone. Not the feel. |
| **Mac mini** (used ~£300, new ~£600) | one-off | Real iOS builds, free 7-day sideload to your own device |
| **Cloud Mac** (Scaleway, MacStadium) | ~£0.10–1/hr | Same, rented. Fiddly for iterating. |
| **App Store / TestFlight** | £99/yr + a Mac | Only relevant if iOS becomes a release target |

Worth being blunt about the priority: **iOS is not a release target.** The roadmap
ships to Steam. This is a question about where you can conveniently playtest, and
for that a £0 Android device or the web build both beat spending on a Mac.

### The web route (no Mac, no account, no store)

The game uses no threads of its own and already renders through
`gl_compatibility` — WebGL2 — so a single-threaded web export works.

1. Same **Manage Export Templates** download as Android; it covers Web too.
2. **Project → Export… → Web**, and **uncheck Thread Support**.
   This matters: threads need SharedArrayBuffer, which needs cross-origin
   isolation, which needs a secure context — https or localhost. A phone opening
   `http://192.168.x.x` is neither, so a threaded build will not boot over the
   LAN at all.
3. Export to `build/web/index.html`.
4. `node tools/webserve.js`, then open the printed LAN address on the phone —
   the same shape as the Card Lab, which already reaches your phone this way.

**What the web build is good for:** does the interface fit, is the text readable
in your hand, are the buttons thumb-sized, does a run flow.

**What it is bad for:** the timing minigame. The grip bar and the timed-card
windows are latency-sensitive, and browser input lag on a phone will make them
feel worse than they are. Do not judge the feel of the game from a web build —
which is unfortunate, because the feel is the thing most worth testing on a
phone. That is the honest case for borrowing an Android device.

Also expect: audio only starts after your first tap (iOS blocks autoplay), and
the first load is a large download over wifi (the server gzips it).

## Known rough edges to expect on the first run

Worth knowing so they don't read as bugs:

- **Card rules text will still be small.** At 560 logical pixels it works out to
  roughly 1.3 mm on a handset — better than the 1 mm it was, still under the
  ~2.5 mm you want for body text. The card NAME, the icon and the big numbers are
  what you read at a glance; right-click/long-press opens the inspector for the
  rest. If it reads too small in your hand, lower `Screen.HANDHELD_HEIGHT` —
  that one number moves the whole interface, and the trade is fewer cards on
  screen at once.
- **Co-op over the network is untested on a real device.** ENet on a phone should
  work over the same wifi, but the risk register has always flagged that only
  localhost has ever been tried. Solo is the safe first test.
- **No touch gestures beyond tap.** The overworld's drag-to-look is written
  against mouse motion; it should translate, but pinch-to-zoom does not exist —
  the wheel-zoom has no touch equivalent yet.
