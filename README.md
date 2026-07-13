# Better Zen Browser ✨

[![Zen Browser](https://img.shields.io/badge/Zen%20Browser-1.8%2B-ff5f57?style=flat-square&logo=firefox&logoColor=white)](https://zen-browser.app)
[![Catppuccin](https://img.shields.io/badge/Catppuccin-Macchiato-f4f4f7?style=flat-square&logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIxNiIgaGVpZ2h0PSIxNiIgdmlld0JveD0iMCAwIDE2IDE2Ij48cGF0aCBkPSJNOCAxYy0zLjkgMC03IDMuMS03IDdzMy4xIDcgNyA3IDctMy4xIDctNy0zLjEtNy03LTd6IiBmaWxsPSIjZjRjYjcwIi8+PC9zdmc+&labelColor=24273a)](https://catppuccin.com)
[![License](https://img.shields.io/badge/license-MIT-blue?style=flat-square)](LICENSE)
[![GitHub](https://img.shields.io/badge/made%20with-%F0%9F%96%A4%20by%20opencode-8a5cf5?style=flat-square)](https://opencode.ai)

> A premium, glassmorphic userChrome.css configuration for **Zen Browser** — featuring a floating URL bar, floating bookmarks bar, macOS-style window controls, and the elegant **Catppuccin Macchiato** color palette.

---

## Showcase 🎬

| State | Preview |
|-------|---------|
| **Idle** | Floating bookmarks bar visible, clean glass UI |
| **Focused** | Floating URL bar + cinematic dark vignette overlay |
| **Compact** | Buttons collapse, macOS traffic lights stay visible |

---

## Features 🚀

### Floating URL Bar 🌊
- Centered, fixed-position URL bar with `backdrop-filter: blur(20px)` glass effect
- Responsive width: `clamp(300px, 44vw, 640px)`
- Seamless integration with bookmarks bar (auto-stacking via `calc()`)
- No toolbar shift on focus (sidebar compensation fix)

### Floating Bookmarks Bar 📑
- Hover-reveal bookmarks bar with elastic opacity transition
- Centered with `fit-content` width, capped at `92vw`
- No chevron overflow — hidden gracefully
- Bookmark items scale to `1.20` on hover with brightness boost

### Safari / macOS-style Navigation 🎯
- **Window controls**: Red `#ff5f57` / Yellow `#febc2e` / Green `#28c840` traffic light circles
- Gray out when window is inactive (`:-moz-window-inactive`)
- **Back / Forward**: Clean chevron arrows replacing default Firefox icons
- Subtle circular hover background

### Cinematic Vignette 🎭
- Radial gradient overlay on the viewport when URL bar is focused or floating
- Smooth `250ms` opacity transition
- Enhances focus on the active URL bar

### Sidebar Tab Hover Animation 🎞️
- Staggered scale (`1.3`) + brightness (`1.3`) animation on tab hover
- `15ms` delay cascade per tab for a wave-like effect

### Findbar Minimal Redesign 🔍
- Floating, glass-styled findbar positioned top-right
- Compact single-line layout — no overflow
- Instant appearance, no transition lag

### Global Flat Theme 🎨
- **Catppuccin Macchiato**: `#24273a` base background
- Uniform coloring across sidebar, toolbar, and web panels
- Zero gradients — fully flat aesthetic

---

## Installation 📦

1. **Open your Zen Browser profile folder:**
   - `about:support` → *Profile Folder* → **Open Directory**
   - Or navigate to: `~/.zen/<profile>/chrome/`

2. **Clone or copy these files:**
   ```bash
   git clone https://github.com/YOUR_USER/YOUR_REPO chrome/
   # or manually copy userChrome.css, zen-themes.css, zen-themes/
   ```

3. **Enable custom stylesheets:**
   - Go to `about:config`
   - Set `toolkit.legacyUserProfileCustomizations.stylesheets` → `true`

4. **Restart Zen Browser** — changes apply on next launch.

---

## Configuration ⚙️

All customization variables are at the top of `userChrome.css`:

```css
--floating-urlbar-width: clamp(300px, 44vw, 640px);
--floating-bookmarks-top: clamp(140px, 30vh, 320px);
--floating-bookmarks-height: 36px;
--floating-stack-gap: clamp(0px, 0.1vh, 2px);
```

Tweak these to match your screen size and preference.

---

## Compatibility ✅

| Feature | Status |
|---------|--------|
| Zen Browser 1.8+ | ✅ |
| Multiple Toolbars | ✅ |
| Collapsed Bar | ✅ |
| Single Toolbar | ⚠️ May need adjustments |
| Compact Mode | ✅ (sidebar position: fixed) |
| Vertical Tabs | ✅ |
| Left Sidebar | ✅ |

---

## Credits 💝

- **[Zen Browser](https://zen-browser.app)** — the most beautiful Firefox fork
- **[Catppuccin](https://catppuccin.com)** — soothing pastel theme colors
- **[OpenCode](https://opencode.ai)** — AI coding agent used to craft this config

---

> **Note**: This configuration is tailored for a collapsed sidebar with icons only.  
> If you use an expanded sidebar or right-side tabs, some selectors may need adjustment.
