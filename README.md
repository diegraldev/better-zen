# Better Zen 🌀

> A curated, glassmorphic **userChrome.css** configuration for **Zen Browser**.
> Floating URL bar, floating bookmarks bar, macOS-style window controls and a
> cohesive flat dark theme built around the single accent color `#202326`.

[![Zen Browser](https://img.shields.io/badge/Zen%20Browser-1.8%2B-ff5f57?style=flat-square&logo=firefox&logoColor=white)](https://zen-browser.app)
[![License](https://img.shields.io/badge/license-MIT-blue?style=flat-square)](LICENSE)
[![made with opencode](https://img.shields.io/badge/made%20with-%F0%9F%96%A4%20opencode-8a5cf5?style=flat-square)](https://opencode.ai)

---

## ✨ Features

### 🌊 Floating URL Bar
Centered glass URL bar that floats below the bookmarks bar.

- Fixed position (`position: fixed`), horizontally centered
- Transparent backdrop with `backdrop-filter: blur(20px)`
- No native border / shadow — replaced by a subtle rounded card
- Responsive width `min(44vw, 640px, 100vw - 32px)`, `min-width: 300px`
- Centered text when idle, left-aligned once focused
- Stacks automatically below the bookmarks bar via `calc()`

### 📑 Floating Bookmarks Bar
The bookmarks toolbar is an overlay pill that reveals on interaction.

- Hidden by default (`opacity: 0`), shows on hover / focus / active
- Centered with `fit-content`, capped at `min(92vw, 760px)`
- Chevron (`>>`) fully removed — no overflow
- Items scale to `1.20` + brighten on hover, `0.95` on press
- Custom `cubic-bezier` easing replaces Zen's bounce

### 🚦 macOS-style Window Controls
Replaces the window buttons with traffic-light circles.

- Close `#ff5f57` / Minimize `#febc2e` / Maximize `#28c840`
- `12×12px`, round, scale to `1.2` on hover
- Grey `#5c5c5c` when the window is inactive

### ◀▶ macOS-style Back/Forward Arrows
- Custom SVG chevron icons instead of Firefox defaults
- Transparent hover / press pill backgrounds
- Disabled forward button dimmed (`opacity: 0.35`)

### 🎭 Cinematic Vignette
A soft dark radial gradient frames the viewport when the URL bar is focused
or floating — smooth `250ms` fade, non-interactive.

### 🎚 Compact Sidebar (anchor bottom-left)
- Sidebar hugs the bottom edge (no floating card, no rounded corners/shadow)
- No overshoot easing when expanding
- Zero horizontal padding shift while animating
- Hides the pinned-tabs separator and the "close unpinned tabs" button

### 🔊 Audio Indicator
Static circular playback indicator on tabs, with the classic Firefox icons.

- Play / mute / media-blocked states
- Muted shows a red tint; scales on hover
- Hides Zen's default audio button

### 🧹 QoL & Cleanup
- Hides the workspace indicator
- Hides tab close (`X`) buttons
- Hides the status bar (hover link) panel
- Hides extension & internal-page name labels in the URL bar
- Hides the app menu (three-dot) button
- Hides URL-bar results & top sites when the bar opens without typing
- Split-view: outlines the active pane

### 🪟 Consistent Blank Windows
Makes **New Blank Window** (unsynced) use the same `#202326` theme instead of
Zen's hard-coded blue/purple override, so all windows look identical.

---

## 📂 What's what

| Path | Role |
|------|------|
| `userChrome.css` | **Your** custom rules — everything above |
| `zen-themes.css` | Auto-generated aggregate of installed mods (`about:addons`). **Do not edit by hand.** |
| `zen-themes/*/` | Per-mod CSS + preferences |
| `.gitignore` | Keeps only customization files (ignores cache/session) |

---

## 🚀 Install

1. Open your Zen profile folder:
   `about:support` → **Profile Folder** → **Open Directory**.
2. Put the files in `.../chrome/`:
   ```bash
   git clone https://github.com/diegraldev/better-zen chrome/
   ```
3. In `about:config` set:
   `toolkit.legacyUserProfileCustomizations.stylesheets` → `true`
4. Restart Zen. Changes apply on next launch.

---

## ⚙️ Tune it

Sizing lives at the top of `userChrome.css`:

```css
--floating-bookmarks-top: clamp(140px, 30vh, 320px);     /* bookmarks bar top offset */
--floating-bookmarks-height: 36px;                        /* bookmarks bar height   */
--floating-stack-gap: clamp(0px, 0.1vh, 2px);             /* gap bookmarks ↔ urlbar */
--floating-bookmarks-max-width: min(92vw, 760px);         /* bookmarks max width   */
```

Accent / theme color `#202326` is used across the floating bars and the blank-window
override — change it in one place to re-tint the whole UI.

> ⚠️ The configuration assumes a **collapsed sidebar (icons only)** and vertical
> tabs. If you run an expanded sidebar or right-side tabs, some selectors need
> tuning.

---

## ✅ Compatibility

| Feature | Status |
|---------|--------|
| Zen Browser 1.8+ | ✅ |
| Vertical tabs | ✅ |
| Collapsed sidebar | ✅ |
| Compact mode | ✅ |
| Left / Right sidebar | ✅ |

---

## 🧡 Credits

- **[Zen Browser](https://zen-browser.app)** — the calmer, gorgeous Firefox fork
- **[Audio Indicator Enhanced](https://github.com/Kaedriz/zen-themes)** — audio indicator reimplemented locally
- **[No Top Sites / Ivaon](https://github.com/Ivaon/zen-theme)** — URL results hiding reimplemented locally
- **[OpenCode](https://opencode.ai)** — AI coding agent that crafted this config