# iPhone Mirroring MCP

MCP server that lets Claude Code see and operate your iPhone through macOS **iPhone Mirroring**.

![Claude Code completing a daily-tasks checklist in Taobao on a real iPhone through iPhone Mirroring](docs/demo.gif)

*Hands off: Claude Code works through a daily-tasks checklist in Taobao on a real iPhone — tapping buttons by their
label, reading the screen with OCR, waiting out the in-app timers, and confirming each reward landed.*

## Install

```bash
swift build -c release
claude mcp add iphone -- "$PWD/.build/release/iphone-mirroring-mcp"
```

Requires macOS 15+, iPhone Mirroring connected, and **Screen Recording + Accessibility** granted to the app
that launches Claude Code (Claude desktop app or your terminal). `iphone-mirroring-mcp status` shows what is missing.

## Tools

screenshot, screenshot_text (OCR), tap_text, tap, long_press, scroll (wheel — use for lists), swipe (pages/flicks),
drag, type_text, press_key,
home, app_switcher, spotlight, launch_app, status. Coordinates are pixels of the 1x screenshot.
Action tools return compact OCR text by default (`return: "text"`, ~3x cheaper than an image);
pass `return: "image" | "both" | "none"` as needed — the image is added automatically when a screen has almost no text.

## Reading the screen as text

`screenshot_text` returns the screen as OCR: one line per visible text element, with its bounding box in 1x pixels.
Every action tool returns the same thing by default, so a whole session can run without a single image.
Settings › General on a Chinese-language iPhone:

```
screen 328x712
20:49 @35,17,54,14
通用 @29,182,31,17
管理iPhone的整体设置和偏好设置，例如软件 @30,202,256,17
更新、设备语言、CarPlay车载、隔空投送等。 @30,220,252,16
关于本机 @59,283,52,14
软件更新 @59,322,51,14
iPhone储存空间 @58,362,92,14
AppleCare与保修 @59,427,100,15
隔空投送 @60,492,50,14
隔空播放与连续互通 @60,531,113,14
画中画 @59,570,39,14
屏幕捕捉 @60,609,50,14
CarPlay车载 @59,648,71,16
```

Why text instead of pixels:

- **Fewer tokens.** A dozen short lines describe this screen; a screenshot of it costs several times more, on every step.
- **Accurate taps.** Coordinates come from the OCR boxes, not from the model estimating pixel positions in an image.
  `tap_text "软件更新"` (Software Update) lands on (84, 329), the centre of that box, and the result confirms it before
  showing the new screen: `ok: tapped "通用" at (72, 537); screen 328x712` (通用 = General).
- **Works with text-only models.** No vision capability is needed; any model that can read a line and call a tool
  can drive the phone. Screens with almost no text (photos, maps, icon-only UI) get the image added automatically.

## How it works

Screenshots are captured in the background (ScreenCaptureKit). iPhone Mirroring ignores input unless it is
the active app, so each action briefly activates it (~0.3–0.5 s), posts real HID events, then restores your
cursor and previous app. Typing during that moment would go to the phone; actions wait for ~0.75 s of
idleness first.

## Safety

- `IPHONE_MIRRORING_MCP_READONLY=1` exposes only screenshot, screenshot_text, status.
- Leave input tools un-allowlisted in Claude Code to approve every action.
- `IPHONE_MIRRORING_MCP_LOG=/path/file` logs tool names and argument keys only.

## Debugging

```bash
iphone-mirroring-mcp status
iphone-mirroring-mcp shot out.png [--full]
iphone-mirroring-mcp call <tool> '<json>'
iphone-mirroring-mcp selftest
scripts/smoke.sh
```

## Known limitations

- No multi-touch (pinch/rotate).
- Drag gestures do not scroll lists in iPhone Mirroring; `scroll` uses the scroll wheel with the cursor over the phone.
- Landscape apps: the bezel crop assumes the portrait insets (unverified in landscape).
- While your phone is in use (unlocked in hand), Mirroring pauses and every tool returns `PHONE_NOT_CONNECTED`.
- Not usable while you are actively working in the same instant an action fires.

## License

MIT — see [LICENSE](LICENSE).
