<div align="center">

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="images/unport-logo-dark.png">
  <img src="images/unport-logo.png" alt="Unport" width="420">
</picture>

**Manage ports from your menu bar.**
Find, open and kill listening ports in a couple of clicks — so you can go back to writing code.

[![CI](https://github.com/iaurg/unport/actions/workflows/ci.yml/badge.svg)](https://github.com/iaurg/unport/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
![macOS 13+](https://img.shields.io/badge/macOS-13%2B-black?logo=apple)

<img src="images/showcase-unport-mac.jpg" alt="Unport's ethernet port icon sitting in the macOS menu bar" width="820">

</div>

## What it does

- **Find** — every listening TCP port with its process, pid and user. Type to filter by port, name or pid.
- **Open** — jump to `http://localhost:<port>` in your browser, or copy `localhost:<port>`.
- **Kill** — one click. Sends `SIGTERM`, and escalates to `SIGKILL` only if the same process still holds the port.

Native SwiftUI, no dependencies, no Dock icon, nothing running while the popover is closed.

## Install

```bash
brew install iaurg/tap/unport
brew services start unport   # start now and at every login
```

Homebrew compiles Unport on your machine (about a minute), so there are no Gatekeeper warnings. Requires macOS 13+ and the Xcode Command Line Tools.

To launch it once without a login item: `open "$(brew --prefix unport)/Unport.app"`.

> **No icon?** On a crowded menu bar macOS silently hides new items behind the notch. Remove or ⌘-drag other items, or use a menu bar manager such as [Ice](https://github.com/jordanbaird/Ice).

## Build from source

```bash
git clone https://github.com/iaurg/unport.git
cd unport
make run       # build build/Unport.app and launch it
make install   # copy it to /Applications
make test
```

Only the Command Line Tools are needed; there is no Xcode project.

## How it works

Unport runs `lsof -nP -iTCP -sTCP:LISTEN -F pcLn` every 3 seconds while the popover is open and parses the machine-readable output. Without root, `lsof` only lists your own processes, which is what you want for dev servers. Killing a process you do not own fails with a message instead of asking for a password.

| Path | What |
|---|---|
| `Sources/UnportCore` | `lsof` parsing, port model, icon geometry — UI-free and unit tested |
| `Sources/Unport` | SwiftUI `MenuBarExtra` app |
| `Sources/IconGenerator` | Renders `AppIcon.icns` at build time |
| `scripts/build-app.sh` | Wraps the SwiftPM binary in an `.app` bundle |
| `packaging/homebrew/unport.rb` | Formula published to [iaurg/homebrew-tap](https://github.com/iaurg/homebrew-tap) |

## Releasing

```bash
git tag v1.2.3 && git push origin v1.2.3
curl -sL https://github.com/iaurg/unport/archive/refs/tags/v1.2.3.tar.gz | shasum -a 256
```

Put the new `url` and `sha256` in `packaging/homebrew/unport.rb`, copy it to `Formula/unport.rb` in the tap and push.

## License

[MIT](LICENSE)
