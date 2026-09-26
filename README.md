<div align="center">
  <img src="./Topit/Assets.xcassets/AppIcon.appiconset/icon_128x128@2x.png" width="200" height="200" alt="Topit app icon" />
  <h1>Topit</h1>
  <p>Pin any window to the top of your screen</p>
</div>

## Screenshots

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="./img/preview_dark.png">
    <source media="(prefers-color-scheme: light)" srcset="./img/preview.png">
    <img alt="Topit screenshot" src="./img/preview.png" width="816" />
  </picture>
</p>

## Build and Install

### Requirements

- macOS 13 or later
- Xcode 26 or later
- Internet access to resolve Swift package dependencies on the first build

Run from the project directory:

```bash
./install.command --open
```

The script clears Topit's privacy permissions, removes stale build artifacts, builds and installs `Topit.app` in `~/Applications`, then opens it. Omit `--open` to install without launching. Since permissions are reset on every build, macOS will ask you to grant them again after each installation.

This is an ad-hoc signed local build, not a notarized release.

## Usage

Open Topit and select a window to pin. You can pin multiple windows, then move, resize, or interact with them.

## Q&A

**Why does Topit need screen recording and accessibility permissions?**

Topit uses accessibility and screen recording permissions to control and capture windows. The installer resets these permissions before each build, so you need to grant them again after installing.

**Does Topit consume a lot of power?**

Topit uses ScreenCaptureKit to capture windows with relatively low CPU overhead. Pinning many windows may still increase power consumption.
