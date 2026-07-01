# React Native

## nvm - Node Version Manager

Manages node.js versions to be able to use different version of node.js (equiv to FVM)

- % curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

- fucks up .zshrc file

### nvm commands

% nvm --version

## node.js - JavaScript runtime ```react-native``` needs

### Install ```Node LTS {node Long Term Support}```

% nvm install --lts

```text
nvm install --lts
Installing latest LTS version.
Downloading and installing node v24.15.0...
Downloading https://nodejs.org/dist/v24.15.0/node-v24.15.0-darwin-arm64.tar.xz...
######################################################################### 100.0%
Computing checksum with sha256sum
Checksums matched!
Now using node v24.15.0 (npm v11.12.1)
Creating default alias: default -> lts/* (-> v24.15.0)
```

#### Post Install
```text
% node --version
v24.15.0
% npm --version
11.12.1
```

### brew install watchman

**Watchman** is Meta's file-watching service. React-Native's Fast Refresh (the hot-reload equivalent) uses it to detect file changes reliably on macOS. Without it RN works but the dev experience is flaky — this is the difference between Flutter's smooth hot reload and a stuttering one.

```text
 brew install watchman
==> Auto-updating Homebrew...
Adjust how often this is run with `$HOMEBREW_AUTO_UPDATE_SECS` or disable with
`$HOMEBREW_NO_AUTO_UPDATE=1`. Hide these hints with `$HOMEBREW_NO_ENV_HINTS=1` (see `man brew`).
==> Downloading https://ghcr.io/v2/homebrew/core/portable-ruby/blobs/sha256:e666cc63add686cf3394d7b9f27c314b22d1871cd9a751aaef7e9d44cebf54e1
######################################################################### 100.0%
==> Pouring portable-ruby-4.0.4.arm64_big_sur.bottle.tar.gz
==> Auto-updated Homebrew!
Updated 3 taps (ngrok/ngrok, homebrew/core and homebrew/cask).
==> New Formulae
arf: Modern R console with syntax highlighting and fuzzy search
backplane-cli: CLI for interacting with the OpenShift Backplane API
cargo-insta: Snapshot testing CLI for Rust
dexter-lsp: Elixir LSP optimized for large codebases
erlang@28: Programming language for highly scalable real-time systems
fallow: Codebase intelligence for TypeScript and JavaScript
far2l-tty: Unix TTY port of FAR Manager v2 (with NetRocks support)
gascity: Orchestration-builder SDK for multi-agent coding workflows
hexapoda: Colorful modal hex editor
lisette: Language inspired by Rust that compiles to Go
mado: Fast Markdown linter written in Rust
marmot: Open-source data catalog exposing metadata to AI agents
nettle@3: Low-level cryptographic library
openjdk@25: Development kit for the Java programming language
osdctl: CLI tool for managed OpenShift clusters
phpantom-lsp: Fast PHP language server written in Rust
plutosvg: Tiny SVG rendering library in C
quickjs-ng: QuickJS, the Next Generation: a mighty JavaScript engine
rustnet: Cross-platform network monitoring terminal UI with deep packet inspection
skm: Simple and powerful SSH keys manager
sol2: C++ <-> Lua API wrapper with advanced features and top notch performance
tinyice: Modern, all-in-one Icecast-compatible audio/video streaming server
vcfanno: Annotate a VCF with other VCFs/BEDs/tabixed files
vtzero: Minimalist vector tile decoder and encoder in C++
zerolang: Programming language for agents with explicit effects and predictable memory
==> New Casks
agentsview: Browse, search and analyse your past AI coding sessions
amore: App distribution platform with Sparkle, code signing, and notarization
chiri: CalDAV-compatible task management app
duo-desktop: Endpoint health checks for Duo-protected applications
executor: Tool discovery and execution layer for AI agents
general-software-fresh: Short-term memory for screenshots, downloads, clipboard, and desktop files
github-copilot-app: Native client for GitHub Copilot
input0: Voice input tool with AI transcription
mole-app: Deep clean, analyze, and optimize app
notion-cli: Command-line interface for Notion
openwork: Unofficial desktop GUI for OpenCode
pgen: PostgreSQL client
presentify: Annotate screens, highlight cursors, and spotlight or zoom key areas
revpdf-editor: PDF editor for annotation and editing
runtimeviewer: Inspect Objective-C and Swift runtime interfaces
shichizip: 7-Zip derivative GUI
sshfs-mac: Network filesystem client to connect to SSH servers
transcribex: Local AI transcription app

You have 10 outdated formulae and 1 outdated cask installed.

Inspect the formula dependency plan before installing with `brew install --ask`.
Enable ask mode by setting `HOMEBREW_ASK=1`.
Hide these hints with `HOMEBREW_NO_ENV_HINTS=1` (see `man brew`).
==> Fetching downloads for: watchman
✔︎ Bottle Manifest watchman (2026.05.18.00)           Downloaded   38.6KB/ 38.6KB
✔︎ Bottle Manifest boost (1.90.0_1)                   Downloaded   28.9KB/ 28.9KB
✔︎ Bottle Manifest double-conversion (3.4.0)          Downloaded    7.4KB/  7.4KB
✔︎ Bottle double-conversion (3.4.0)                   Downloaded   74.0KB/ 74.0KB
✔︎ Bottle Manifest gflags (2.3.0)                     Downloaded    7.7KB/  7.7KB
✔︎ Bottle gflags (2.3.0)                              Downloaded  224.5KB/224.5KB
✔︎ Bottle Manifest glog (0.7.1)                       Downloaded    8.2KB/  8.2KB
✔︎ Bottle glog (0.7.1)                                Downloaded  124.7KB/124.7KB
✔︎ Bottle Manifest ca-certificates (2026-05-14)       Downloaded    1.7KB/  1.7KB
✔︎ Bottle ca-certificates (2026-05-14)                Downloaded  112.1KB/112.1KB
✔︎ Bottle Manifest libsodium (1.0.22)                 Downloaded    7.3KB/  7.3KB
✔︎ Bottle libsodium (1.0.22)                          Downloaded  408.8KB/408.8KB
✔︎ Bottle Manifest snappy (1.2.2)                     Downloaded    9.2KB/  9.2KB
✔︎ Bottle snappy (1.2.2)                              Downloaded   47.0KB/ 47.0KB
✔︎ Bottle Manifest folly (2026.05.18.00)              Downloaded   22.3KB/ 22.3KB
✔︎ Bottle Manifest fizz (2026.05.18.00)               Downloaded   23.2KB/ 23.2KB
✔︎ Bottle fizz (2026.05.18.00)                        Downloaded  693.1KB/693.1KB
✔︎ Bottle Manifest wangle (2026.05.18.00)             Downloaded   24.3KB/ 24.3KB
✔︎ Bottle wangle (2026.05.18.00)                      Downloaded  937.7KB/937.7KB
✔︎ Bottle Manifest xxhash (0.8.3)                     Downloaded   10.4KB/ 10.4KB
✔︎ Bottle xxhash (0.8.3)                              Downloaded  149.6KB/149.6KB
✔︎ Bottle Manifest fbthrift (2026.05.18.00)           Downloaded   26.6KB/ 26.6KB
✔︎ Bottle Manifest fb303 (2026.05.18.00)              Downloaded   27.4KB/ 27.4KB
✔︎ Bottle folly (2026.05.18.00)                       Downloaded    7.7MB/  7.7MB
✔︎ Bottle Manifest edencommon (2026.05.18.00)         Downloaded   28.5KB/ 28.5KB
✔︎ Bottle fb303 (2026.05.18.00)                       Downloaded  796.6KB/796.6KB
✔︎ Bottle Manifest mpdecimal (4.0.1)                  Downloaded   11.9KB/ 11.9KB
✔︎ Bottle mpdecimal (4.0.1)                           Downloaded  186.2KB/186.2KB
✔︎ Bottle Manifest sqlite (3.53.1)                    Downloaded   11.8KB/ 11.8KB
✔︎ Bottle edencommon (2026.05.18.00)                  Downloaded  444.8KB/444.8KB
✔︎ Bottle sqlite (3.53.1)                             Downloaded    2.4MB/  2.4MB
✔︎ Bottle Manifest python@3.14 (3.14.5)               Downloaded   31.1KB/ 31.1KB
✔︎ Bottle fbthrift (2026.05.18.00)                    Downloaded    8.8MB/  8.8MB
✔︎ Bottle watchman (2026.05.18.00)                    Downloaded    3.4MB/  3.4MB
✔︎ Bottle python@3.14 (3.14.5)                        Downloaded   19.2MB/ 19.2MB
✔︎ Bottle boost (1.90.0_1)                            Downloaded   61.3MB/ 61.3MB
==> Installing dependencies for watchman: boost, double-conversion, gflags, glog, ca-certificates, libsodium, snappy, folly, fizz, wangle, xxhash, fbthrift, fb303, edencommon, mpdecimal, sqlite and python@3.14
==> Installing watchman dependency: boost
==> Pouring boost--1.90.0_1.arm64_tahoe.bottle.tar.gz
🍺  /opt/homebrew/Cellar/boost/1.90.0_1: 16,255 files, 356.5MB
==> Installing watchman dependency: double-conversion
==> Pouring double-conversion--3.4.0.arm64_tahoe.bottle.tar.gz
🍺  /opt/homebrew/Cellar/double-conversion/3.4.0: 29 files, 275.1KB
==> Installing watchman dependency: gflags
==> Pouring gflags--2.3.0.arm64_tahoe.bottle.tar.gz
🍺  /opt/homebrew/Cellar/gflags/2.3.0: 27 files, 747.0KB
==> Installing watchman dependency: glog
==> Pouring glog--0.7.1.arm64_tahoe.bottle.tar.gz
🍺  /opt/homebrew/Cellar/glog/0.7.1: 25 files, 441.8KB
==> Installing watchman dependency: ca-certificates
==> Pouring ca-certificates--2026-05-14.all.bottle.tar.gz
==> Regenerating CA certificate bundle from keychain, this may take a while...
🍺  /opt/homebrew/Cellar/ca-certificates/2026-05-14: 4 files, 200.6KB
==> Installing watchman dependency: libsodium
==> Pouring libsodium--1.0.22.arm64_tahoe.bottle.tar.gz
🍺  /opt/homebrew/Cellar/libsodium/1.0.22: 88 files, 1.1MB
==> Installing watchman dependency: snappy
==> Pouring snappy--1.2.2.arm64_tahoe.bottle.tar.gz
🍺  /opt/homebrew/Cellar/snappy/1.2.2: 19 files, 179.2KB
==> Installing watchman dependency: folly
==> Pouring folly--2026.05.18.00.arm64_tahoe.bottle.tar.gz
🍺  /opt/homebrew/Cellar/folly/2026.05.18.00: 1,047 files, 33.9MB
==> Installing watchman dependency: fizz
==> Pouring fizz--2026.05.18.00.arm64_tahoe.bottle.tar.gz
🍺  /opt/homebrew/Cellar/fizz/2026.05.18.00: 223 files, 2.6MB
==> Installing watchman dependency: wangle
==> Pouring wangle--2026.05.18.00.arm64_tahoe.bottle.tar.gz
🍺  /opt/homebrew/Cellar/wangle/2026.05.18.00: 108 files, 4.2MB
==> Installing watchman dependency: xxhash
==> Pouring xxhash--0.8.3.arm64_tahoe.bottle.tar.gz
🍺  /opt/homebrew/Cellar/xxhash/0.8.3: 28 files, 575.6KB
==> Installing watchman dependency: fbthrift
==> Pouring fbthrift--2026.05.18.00.arm64_tahoe.bottle.tar.gz
🍺  /opt/homebrew/Cellar/fbthrift/2026.05.18.00: 1,345 files, 56.1MB
==> Installing watchman dependency: fb303
==> Pouring fb303--2026.05.18.00.arm64_tahoe.bottle.tar.gz
🍺  /opt/homebrew/Cellar/fb303/2026.05.18.00: 56 files, 4.3MB
==> Installing watchman dependency: edencommon
==> Pouring edencommon--2026.05.18.00.arm64_tahoe.bottle.tar.gz
🍺  /opt/homebrew/Cellar/edencommon/2026.05.18.00: 84 files, 1.9MB
==> Installing watchman dependency: mpdecimal
==> Pouring mpdecimal--4.0.1.arm64_tahoe.bottle.tar.gz
🍺  /opt/homebrew/Cellar/mpdecimal/4.0.1: 22 files, 660.8KB
==> Installing watchman dependency: sqlite
==> Pouring sqlite--3.53.1.arm64_tahoe.bottle.tar.gz
🍺  /opt/homebrew/Cellar/sqlite/3.53.1: 13 files, 5.3MB
==> Installing watchman dependency: python@3.14
==> Pouring python@3.14--3.14.5.arm64_tahoe.bottle.tar.gz
🍺  /opt/homebrew/Cellar/python@3.14/3.14.5: 3,745 files, 75.6MB
==> Installing watchman
==> Pouring watchman--2026.05.18.00.arm64_tahoe.bottle.tar.gz
🍺  /opt/homebrew/Cellar/watchman/2026.05.18.00: 26 files, 15.3MB
==> Running `brew cleanup watchman`...
Disable this behaviour by setting `HOMEBREW_NO_INSTALL_CLEANUP=1`.
Hide these hints with `HOMEBREW_NO_ENV_HINTS=1` (see `man brew`).
🐶 % 
```

### watchman

% watchman --version

```text
2026.05.18.00
```

 That's the full toolchain — **Node, npm, Watchman, plus your existing Xcode and Android SDK***. Now ready to *scaffold* an actual app.