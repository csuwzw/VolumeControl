<p align="center">
  <img src="assets/icon-v2.png" width="96" height="96" alt="VolumeControl">
</p>

<h1 align="center">VolumeControl</h1>

<p align="center">
  <a href="README.md">简体中文</a> | <b>English</b>
</p>

<p align="center">
  Global volume hotkeys for desktop keyboards that have no volume keys.<br>
  A single exe, runs on double-click, nothing to install.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/platform-Windows%207%20%7C%208%20%7C%2010%20%7C%2011-blue" alt="platform">
  <img src="https://img.shields.io/badge/license-MIT-green" alt="license">
</p>

---

## What is this

Many desktop keyboards have no volume keys, so adjusting the volume means reaching for the speaker icon in the system tray.

**VolumeControl** gives you a set of global hotkeys using `Ctrl + Alt + Arrow keys`: whether you are in a game, watching a video, or writing a document, press the hotkeys to change the volume, and the native system volume overlay appears — exactly like pressing physical volume keys.

## Hotkeys

| Hotkey | Function |
| :--- | :--- |
| `Ctrl + Alt + ↑` | Volume up (shows the system volume overlay) |
| `Ctrl + Alt + ↓` | Volume down (shows the system volume overlay) |
| `Ctrl + Alt + ←` | Mute / unmute (shows the system volume overlay) |
| `Ctrl + Alt + →` | Open the system volume mixer (adjust each app separately) |

## Quick Start

1. Go to the [**Releases**](https://github.com/csuwzw/VolumeControl/releases) page and download the latest build:
   - **`VolumeControl.exe`** — 32-bit build; **runs on both 32-bit and 64-bit Windows, the most universal choice** for almost everyone.
   - **`VolumeControl-x64.exe`** — native 64-bit build, for 64-bit Windows only.
2. Double-click it; a blue speaker icon appears in the system tray.
3. Press `Ctrl + Alt + Arrow keys` to control the volume.

> The program runs in the background with no main window. **Right-click the speaker icon in the system tray** to manage or close it.

## Run at Startup

Either way:

- **Recommended**: right-click the tray icon → click **"开机自动启动" (Run at Startup)**; a checkmark appears next to the menu item. The program creates a shortcut to itself in the Windows startup folder. Click again to remove it.
- Or press `Win + R`, type `shell:startup`, and place a shortcut to `VolumeControl.exe` in the folder that opens.

## How it works

The program does one thing: when you press a hotkey, it sends the **standard Windows multimedia volume-key messages** (`VK_VOLUME_UP` / `VK_VOLUME_DOWN` / `VK_VOLUME_MUTE`). Windows itself then performs the volume change and shows the overlay.

As a result it:

- does not depend on any particular sound card or driver;
- does not read or write audio parameters directly, so it won't conflict with games or players;
- ships as an exe with the runtime built in — **end users never need to install AutoHotkey or anything else**.

## Requirements

- Windows 7 / 8 / 8.1 / 10 / 11 (32-bit or 64-bit).
- The 32-bit exe runs on both 32-bit and 64-bit systems; the 64-bit exe requires a 64-bit system.

## FAQ

**Q: Nothing happens when I press `Ctrl + Alt + Arrow keys`?**

On some computers this combination is taken by the **graphics card's screen-rotation hotkeys** (common on Intel integrated graphics). Fix it by:

- Intel graphics: open "Intel Graphics Control Center / Graphics Properties → Options and Support (or Hotkeys)" and disable or change the screen-rotation hotkeys;
- or disable the `Ctrl + Alt + Arrow keys` hotkey in the graphics control panel, then run this program again.

**Q: I double-clicked the exe but see no window?**

That is expected — it stays in the background and only shows a blue speaker icon in the system tray.

**Q: How do I exit completely?**

Right-click the tray icon → "退出" (Exit).

## Build from source

The source is an AutoHotkey v2 script at `src/VolumeHotkey.ahk`. After installing [AutoHotkey v2](https://www.autohotkey.com/), run from the project root:

```powershell
powershell -ExecutionPolicy Bypass -File .\build.ps1
```

The script generates the icon, downloads the Ahk2Exe compiler on demand, and outputs both the 32-bit and 64-bit exes into `dist/`.

## Project structure

```
VolumeControl/
├── src/
│   └── VolumeHotkey.ahk   # Source (AutoHotkey v2)
├── assets/
│   ├── icon.ico           # Program icon
│   └── icon-v2.png        # Icon for the README
├── tools/                 # Build tools (Ahk2Exe auto-downloaded here)
├── dist/                  # Build output (not in git)
├── build.ps1              # One-click build script
├── README.md              # Chinese
├── README_EN.md           # English
├── LICENSE                # MIT
├── .gitignore
└── .gitattributes
```

## Security and privacy

- The program collects no data, never connects to the network, writes no registry entries, and installs no services.
- "Run at Startup" only creates a normal shortcut in the current user's startup folder.
- To uninstall: exit via the tray icon and delete the exe. If you enabled startup, disable it in the menu first or delete the shortcut in the startup folder.

## License

[MIT](LICENSE) © csuwzw
