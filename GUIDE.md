# Building and Installing iOS & watchOS Apps Without a Mac

## Complete Guide: From Linux to iPhone 12 Pro & Apple Watch Series 4

**Date:** October 28, 2026  
**Target Devices:** iPhone 12 Pro (iOS 16+), Apple Watch Series 4 (watchOS 9+)  
**Development Machine:** Ubuntu Linux  
**Build Environment:** GitHub Actions (macOS runner)  
**App:** Daily Motivation — a motivational quotes app

---

## Table of Contents

1. [Overview](#1-overview)
2. [Prerequisites](#2-prerequisites)
3. [Project Structure](#3-project-structure)
4. [How the Apps Work](#4-how-the-apps-work)
5. [Setting Up GitHub CLI on Linux](#5-setting-up-github-cli-on-linux)
6. [Creating the GitHub Repository](#6-creating-the-github-repository)
7. [How GitHub Actions Builds the Apps](#7-how-github-actions-builds-the-apps)
8. [Downloading the Built IPA Files](#8-downloading-the-built-ipa-files)
9. [Installing on iPhone (via Sideloadly on Windows)](#9-installing-on-iphone-via-sideloadly-on-windows)
10. [Enabling Developer Mode on iPhone](#10-enabling-developer-mode-on-iphone)
11. [Installing on Apple Watch](#11-installing-on-apple-watch)
12. [Lessons Learned & Gotchas](#12-lessons-learned--gotchas)
13. [Limitations & Notes](#13-limitations--notes)
14. [Choosing a Mac for iOS/watchOS Development (Budget Guide)](#14-choosing-a-mac-for-ioswatchos-development-budget-guide)
15. [Troubleshooting](#15-troubleshooting)
16. [Making Changes to the App](#16-making-changes-to-the-app)
17. [Quick Reference](#17-quick-reference)

---

## 1. Overview

Apple requires macOS + Xcode to build iOS and watchOS apps. Since we don't have a Mac, we use **GitHub Actions** which provides free macOS virtual machines for public repositories. The workflow is:

```
Write code (Linux) → Push to GitHub → GitHub Actions builds on macOS → Download .ipa → Sideload to devices
```

### What Worked and What Didn't

| Goal | Result | Method |
|---|---|---|
| Build iPhone app from Linux | ✅ **Success** | GitHub Actions with macOS runner |
| Build Watch app from Linux | ✅ **Success** | GitHub Actions with macOS runner |
| Install iPhone app without Mac | ✅ **Success** | Sideloadly on Windows PC |
| Install Watch app without Mac | ❌ **Not possible** | Requires Xcode on a Mac (see Section 11) |

---

## 2. Prerequisites

| Requirement | Details |
|---|---|
| **Linux machine** | Ubuntu (any recent version) |
| **GitHub account** | Free at github.com/signup |
| **Apple ID** | Free at appleid.apple.com |
| **Windows PC** (for sideloading) | Needed to run Sideloadly |
| **USB Lightning cable** | To connect iPhone to Windows PC |
| **iPhone 12 Pro** | Running iOS 16 or later |
| **Apple Watch Series 4** | Running watchOS 9 or later, paired with the iPhone |

### Software to Install

**On Linux:**
- Git: `sudo apt install git`
- GitHub CLI: `sudo snap install gh --classic`
  - ⚠️ The `--classic` flag is **required** — without it, snap will refuse to install. This is because `gh` needs system-level access that the snap sandbox doesn't allow.

**On Windows (download from websites, NOT the Microsoft Store):**
- iTunes: https://www.apple.com/itunes/
- iCloud: https://support.apple.com/en-us/103232
- Sideloadly: https://sideloadly.io
  - Download the **64-bit** version if your Windows is 64-bit (check: Settings → System → About → "System type")
  - The 32-bit version works on 32-bit systems but use 64-bit when possible

> ⚠️ **Critical:** The Microsoft Store versions of iTunes and iCloud will NOT work with Sideloadly. You MUST download them from Apple's website directly.

### Are Sideloadly and AltStore Safe?

- **AltStore** — Safe, open-source, created by respected developer Riley Testut, widely covered by major tech publications, approved on EU App Store
- **Sideloadly** — Safe, widely used by millions, not open-source but strong reputation with no known security issues
- **Tip:** If you're cautious, create a secondary/throwaway Apple ID just for sideloading

---

## 3. Project Structure

```
apple/
├── .github/workflows/
│   └── build-ios.yml                  ← GitHub Actions CI/CD workflow
├── .gitignore
├── GUIDE.md                           ← This document
└── MyFirstAppleApp/
    ├── MyFirstAppleApp.xcodeproj/     ← Xcode project configuration
    │   ├── project.pbxproj            ← Build settings, targets, file references
    │   └── xcshareddata/xcschemes/    ← Build schemes (MUST be shared for CI)
    │       ├── MyFirstAppleApp.xcscheme
    │       └── MyFirstWatchApp.xcscheme
    ├── MyFirstAppleApp/               ← iPhone app source code
    │   ├── MyFirstAppleAppApp.swift   ← App entry point (@main)
    │   ├── ContentView.swift          ← Main UI (quotes display)
    │   ├── QuoteManager.swift         ← Quote data model & storage
    │   └── Assets.xcassets/           ← App icons, accent colors
    └── MyFirstWatchApp/               ← Apple Watch app source code
        ├── MyFirstWatchApp.swift      ← Watch app entry point (@main)
        ├── WatchContentView.swift     ← Watch UI (compact quotes)
        ├── WatchQuoteManager.swift    ← Shorter quotes for watch screen
        └── Assets.xcassets/           ← Watch app icons, accent colors
```

---

## 4. How the Apps Work

### iPhone App — "Daily Motivation"
- Dark gradient background (purple/blue)
- Displays a motivational quote with author attribution
- "✨ New Quote" button cycles through 15 quotes
- Smooth fade-in and slide-up animations
- Built with SwiftUI (Apple's modern UI framework)

### Apple Watch App — "Daily Motivation Watch"
- Compact interface optimized for the small watch screen
- Shorter quotes selected for readability on wrist
- "✨ Next" button to cycle through 10 quotes
- Scrollable view for longer quotes
- Independent watchOS app (can run without the iPhone app nearby)

---

## 5. Setting Up GitHub CLI on Linux

### Step 1: Install GitHub CLI
```bash
sudo snap install gh --classic
```

### Step 2: Authenticate
```bash
gh auth login
```

Answer the prompts:
1. **Account:** → `GitHub.com`
2. **Protocol:** → `HTTPS`
3. **Authenticate Git:** → `Yes`
4. **Method:** → `Login with a web browser`

A one-time code will appear (e.g., `ABCD-1234`). Go to https://github.com/login/device and enter it. You can do this on your phone if the browser doesn't open.

### Step 3: Verify
```bash
gh auth status
```
You should see: `✓ Logged in to github.com as YOUR_USERNAME`

---

## 6. Creating the GitHub Repository

### Initialize Git and Push
```bash
cd /path/to/your/apple/project

# Initialize git repo
git init
git branch -m main

# Configure your identity
git config user.email "your-email@example.com"
git config user.name "Your Name"

# Commit all files
git add -A
git commit -m "Initial commit: Daily Motivation app for iPhone and Apple Watch"

# Create GitHub repo and push (--public is required for free macOS runners)
gh repo create my-first-apple-app --public --source=. --push
```

> **Why `--public`?** GitHub gives free unlimited macOS runner minutes to public repos. Private repos have limited free minutes per month.

The push automatically triggers the GitHub Actions build because the workflow file (`.github/workflows/build-ios.yml`) is configured with `on: push: branches: [main]`.

---

## 7. How GitHub Actions Builds the Apps

### What Happens Automatically

When you `git push` to the `main` branch:

1. GitHub detects `.github/workflows/build-ios.yml`
2. GitHub spins up a **macOS 14 (Sonoma)** virtual machine with **Xcode 15.4** pre-installed
3. Two parallel jobs run:
   - **Build iPhone App**: Compiles for iOS Simulator (verification) → Archives for real device → Creates `.ipa`
   - **Build Watch App**: Compiles for watchOS Simulator (verification) → Archives for real device → Creates `.ipa`
4. The `.ipa` files are uploaded as **downloadable artifacts** on the Actions page

### Key Build Settings

| Setting | Value | Why |
|---|---|---|
| `runs-on` | `macos-14` | Provides macOS with Xcode (free for public repos) |
| `CODE_SIGNING_REQUIRED` | `NO` | We sign later with Sideloadly, not during CI |
| `IPHONEOS_DEPLOYMENT_TARGET` | `16.0` | Supports iPhone 12 Pro |
| `WATCHOS_DEPLOYMENT_TARGET` | `9.0` | Supports Apple Watch Series 4 |

### How the IPA is Created

An `.ipa` file is just a renamed `.zip` containing a `Payload` folder with the `.app` inside:
```
MyFirstAppleApp.ipa (which is a zip file)
└── Payload/
    └── MyFirstAppleApp.app/
        ├── MyFirstAppleApp (executable binary)
        ├── Info.plist (app metadata)
        ├── Assets.car (compiled assets)
        └── PkgInfo
```

The workflow creates this by:
1. `xcodebuild archive` — compiles the app and creates an `.xcarchive`
2. Copies the `.app` from inside the archive into a `Payload/` directory
3. Zips the `Payload/` directory with a `.ipa` extension

### Monitoring Builds

```bash
# List recent builds
gh run list --limit 5

# View a specific build's details
gh run view <RUN_ID>

# View failure logs
gh run view <RUN_ID> --log-failed
```

Or visit: `https://github.com/YOUR_USERNAME/my-first-apple-app/actions`

---

## 8. Downloading the Built IPA Files

### Option A: From the command line (Linux)
```bash
# Download all artifacts from the latest successful build
gh run download <RUN_ID>

# Or download specific artifacts
gh run download <RUN_ID> --name MyFirstAppleApp-iPhone-IPA
gh run download <RUN_ID> --name MyFirstWatchApp-IPA
```

> **Note:** GitHub wraps all artifacts in a `.zip` when downloading. Extract the zip to find the `.ipa` file inside.

### Option B: From the GitHub website
1. Go to your repo → **Actions** tab
2. Click the latest green ✅ build
3. Scroll down to **Artifacts**
4. Click to download:
   - `MyFirstAppleApp-iPhone-IPA` (the iPhone app)
   - `MyFirstWatchApp-IPA` (the Watch app)
5. The download is a `.zip` file — **extract it** to find the `.ipa` inside

> ⚠️ **Don't download artifacts into your project directory!** If you do, they'll get committed to git on your next push. Download to `~/Downloads` or `/tmp` instead.

---

## 9. Installing on iPhone (via Sideloadly on Windows)

### Preparation (One-time setup on Windows)

1. **Install iTunes** from https://www.apple.com/itunes/
   - ⚠️ MUST be the Apple website version, NOT the Microsoft Store version
2. **Install iCloud** from https://support.apple.com/en-us/103232
   - ⚠️ MUST be the Apple website version, NOT the Microsoft Store version
3. **Install Sideloadly** from https://sideloadly.io
   - Download the 64-bit version if your Windows is 64-bit

### Installing the iPhone App

1. Transfer `MyFirstAppleApp.ipa` to the Windows PC (USB drive, email, cloud storage, etc.)
2. Connect your **iPhone 12 Pro** to the Windows PC via **USB Lightning cable**
3. On the iPhone, tap **"Trust This Computer"** when prompted
4. Open **Sideloadly**
5. Drag and drop `MyFirstAppleApp.ipa` into Sideloadly (or click the IPA icon to browse)
6. Enter your **Apple ID email** in the Apple Account field
7. Click **Start**
8. Enter your Apple ID **password** when prompted
9. If you have 2FA enabled, enter the verification code
10. Wait for the installation to complete (progress bar)

### Trust the Developer Profile on iPhone

After installation, the app won't open yet. You need to trust the developer:

1. On iPhone: **Settings → General → VPN & Device Management**
2. Under "Developer App", tap your **Apple ID email**
3. Tap **"Trust [your email]"**
4. Confirm by tapping **Trust**

---

## 10. Enabling Developer Mode on iPhone

Starting with iOS 16, Apple requires Developer Mode to be enabled to run sideloaded apps.

### Steps:

1. Go to **Settings → Privacy & Security**
2. Scroll down to find **Developer Mode**
3. Toggle **Developer Mode ON**
4. A prompt will appear warning about reduced security — tap **Restart**
5. After the iPhone restarts, a confirmation dialog appears — tap **Turn On**
6. Enter your **passcode**
7. Developer Mode is now enabled ✅

> **Note:** If you don't see the Developer Mode option, install the app via Sideloadly first. The option sometimes only appears after a sideloaded app has been detected on the device.

### Open Your App

After enabling Developer Mode and trusting the developer profile:
- Find **MyFirstAppleApp** on your home screen
- Tap to open — you should see the Daily Motivation app! 🎉

---

## 11. Installing on Apple Watch

### ⚠️ Important: Watch App Sideloading Is NOT Possible

**This is the most important finding from this project:** Sideloadly and AltStore **cannot install apps on Apple Watch.** They only support iPhone. This is a hard limitation with no workaround.

### Why Watch Apps Can't Be Sideloaded

Unlike iPhones, the Apple Watch:
- Has **no USB port** — only a magnetic charging puck
- Communicates **only via Bluetooth** through its paired iPhone
- Cannot receive apps from Sideloadly, AltStore, or any other Windows/Linux sideloading tool

The installation chain for Watch apps is always:
```
Mac (Xcode, via USB) → iPhone (via Bluetooth) → Apple Watch
```

### What We Tried and What Happened

| Attempt | Result |
|---|---|
| Install Watch `.ipa` via Sideloadly on iPhone | ❌ Error: "app is compatible with device family 4, device supports 1" (family 4 = Watch, family 1 = iPhone) |
| Look for Developer Mode on Watch | ❌ Toggle doesn't appear — it only shows after Xcode installs a dev app |
| Embed Watch app in iPhone app | ❌ Sideloadly can't properly sign the Watch component |
| Add `WKRunsIndependentlyOfCompanionApp` | Applied ✅ but doesn't help with sideloading |

### The Only Ways to Install on Apple Watch

| Method | Cost | Requirements |
|---|---|---|
| **Xcode on a Mac** (30 min) | Free | Any Mac with Xcode, iPhone via USB, Watch paired to iPhone |
| **TestFlight** | $99/year | Apple Developer Program, upload via CI or Xcode |
| **App Store** | $99/year | Apple Developer Program + Apple review process |

### If You Can Borrow a Mac for 30 Minutes

1. Clone the repo on the Mac:
   ```bash
   git clone https://github.com/YOUR_USERNAME/my-first-apple-app.git
   cd my-first-apple-app/MyFirstAppleApp
   open MyFirstAppleApp.xcodeproj
   ```
2. In Xcode: **Xcode → Settings → Accounts** → sign in with your Apple ID
3. Select the project → **MyFirstWatchApp** target → **Signing & Capabilities** → select your Team
4. Connect your **iPhone** via USB (Watch must be paired with this iPhone)
5. In the scheme selector, choose **MyFirstWatchApp** and your Watch as destination
6. Click ▶️ **Run** — Xcode installs the app: Mac → iPhone (USB) → Watch (Bluetooth)

### Developer Mode on Apple Watch

Developer Mode on Apple Watch (**Settings → Privacy & Security → Developer Mode**) only appears **after** a developer app has been installed via Xcode. It will not show up from Sideloadly-installed iPhone apps. This is expected Apple behaviour.

### Current Status

The Watch app code is **fully written and compiles successfully** on GitHub Actions. The compiled artifact is ready. It's waiting for Mac access to be installed on the physical Watch device.

---

## 12. Lessons Learned & Gotchas

These are real issues we encountered during this project. Reference them for future projects.

### 12.1 iOS vs Android: Fundamental Differences

| Aspect | Android | Apple iOS/watchOS |
|---|---|---|
| Sideload from file | ✅ Enable dev mode, install `.apk` | ❌ Must be code-signed by Apple |
| Build tools | Available on Linux, Windows, macOS | **macOS only** (Xcode) |
| Free dev account | Unlimited installs | 7-day expiry, 3 app limit |
| Watch app sideloading | ✅ ADB over Bluetooth | ❌ Not possible without Mac |
| Developer Mode | Simple toggle | Hidden until dev app is detected |
| USB required | Phone only | Phone only (Watch has no USB) |

### 12.2 GitHub Actions Gotchas

- **macOS runners can be slow to start.** They sometimes queue for 5-10+ minutes due to capacity constraints. This is normal.
- **`on: push` triggers automatically.** Every `git push` to `main` starts a build. This is by design — the workflow file at `.github/workflows/build-ios.yml` controls this.
- **Artifacts are zipped.** When you download from GitHub Actions (web or CLI), artifacts are always wrapped in a `.zip`. Extract to find the actual files.
- **Don't download artifacts into your project directory.** They'll get committed to git accidentally. Use `~/Downloads` or `/tmp`.

### 12.3 Xcode Project Gotchas

- **`SKIP_INSTALL = YES`** on a target means Xcode won't include the `.app` in the archive. We initially had this on the Watch target, causing the archive to contain only debug symbols and no actual app. **Always set `SKIP_INSTALL = NO`** for targets you want to distribute.
- **Shared schemes are required for CI.** Xcode schemes must be in `xcshareddata/xcschemes/` to be found by `xcodebuild` on CI. By default, Xcode creates schemes in `xcuserdata/` which is git-ignored.
- **`project.pbxproj` is the heart of the project.** This single file defines all targets, build settings, file references, and configurations. It uses a custom Apple format (not JSON/YAML). Hand-editing it is fragile but possible.
- **Device families matter.** `TARGETED_DEVICE_FAMILY = 1` means iPhone, `= 4` means Apple Watch. Installing a family-4 app on an iPhone gives: "app is compatible with 4 and device supports 1."

### 12.4 Sideloadly Gotchas

- **Only works for iPhones** — cannot install Watch, iPad (requires different process), or Mac apps
- **Requires Apple-website iTunes and iCloud** — the Microsoft Store versions use different APIs and Sideloadly can't communicate with them
- **Free Apple ID = 7-day expiry** — apps stop working after 7 days and must be re-installed
- **You can have max 3 sideloaded apps** at a time with a free Apple ID

### 12.5 Watch-Specific Gotchas

- **No USB port exists on any Apple Watch** — only a magnetic charging connection
- **Developer Mode toggle is hidden by default** — only appears after Xcode installs a dev app
- **`WKRunsIndependentlyOfCompanionApp = YES`** tells watchOS the app can function without the iPhone nearby — good practice but doesn't affect installation
- **`WKCompanionAppBundleIdentifier`** links the Watch app to the iPhone app logically — the bundle IDs must match the pattern (e.g., `com.myfirstapp.dailymotivation` and `com.myfirstapp.dailymotivation.watchkitapp`)

---

## 13. Limitations & Notes

### Free Apple ID Limitations
| Limitation | Detail |
|---|---|
| **App expiry** | Apps signed with a free Apple ID expire after **7 days** |
| **Re-signing needed** | You must re-install via Sideloadly every 7 days |
| **3 app limit** | Free accounts can only have 3 sideloaded apps at a time |
| **No push notifications** | Sideloaded apps can't receive push notifications |

### Apple Developer Program ($99/year)
Paying for the Apple Developer Program removes these limitations:
- Apps don't expire
- No 3-app limit
- Push notifications work
- You can distribute via TestFlight (beta testing) or the App Store
- TestFlight allows Watch app installation over-the-air (no Mac needed after initial upload)

### GitHub Actions Free Tier
- Public repositories get **free** unlimited macOS runner minutes
- Private repositories get limited free minutes per month (~2000 min for free tier)
- macOS runners may experience queue delays during busy periods (5-15 min waits are common)

---

## 14. Choosing a Mac for iOS/watchOS Development (Budget Guide)

If you plan to continue Apple development, having a Mac — even a cheap used one — eliminates all the sideloading headaches.

### What You Need (Minimum Requirements)

To develop for iPhone 12 Pro (iOS 16+) and Apple Watch Series 4 (watchOS 9+):
- **macOS Ventura 13 or later** (for latest Xcode)
- **8 GB RAM minimum** (16 GB recommended — Xcode is memory-hungry)
- **256 GB storage minimum** (Xcode alone is ~35 GB + simulators)
- **Any Apple Silicon (M1/M2/M3) or Intel Mac that supports macOS Ventura**

### Budget Recommendations (Best Value, Cheapest First)

#### 1. 🏆 Mac Mini M1 (2020) — Best Budget Pick
- **Used price:** ~$250-350 / £200-280
- **Why:** Cheapest way to get Apple Silicon. Fanless under light loads, fast enough for Xcode. You already have a monitor (your Linux machine's screen) and keyboard/mouse.
- **Specs to look for:** 8GB RAM / 256GB SSD (good enough), 16GB RAM (ideal)
- **Where to buy:** eBay, Facebook Marketplace, Swappa, refurbished from Apple ($379)
- **Supports:** macOS Sonoma 14+, Xcode 15+, all current iOS/watchOS SDKs
- **Verdict:** ⭐ Best value. Small, quiet, powerful enough. Plug into your existing monitor.

#### 2. MacBook Air M1 (2020) — If You Want Portability
- **Used price:** ~$400-550 / £350-450
- **Why:** Same M1 chip as the Mini but with built-in screen. Completely silent (no fan). Great battery life.
- **Specs to look for:** 8GB RAM / 256GB SSD minimum
- **Verdict:** Good if you want to develop on the go or don't have a spare monitor.

#### 3. Mac Mini M2 (2023) — Slight Upgrade
- **Used price:** ~$350-450 / £300-380
- **Why:** Newer chip, slightly faster, will be supported longer by Apple
- **Verdict:** Worth the extra ~$100 over M1 if you find a good deal.

#### 4. ⚠️ Intel Macs (2018-2020) — Cheapest but Limited Future
- **Used price:** ~$150-250 / £120-200
- **Mac Mini 2018, MacBook Air 2020 (Intel), iMac 2019**
- **Why cheap:** Apple is phasing out Intel support. macOS Sequoia 15 (2024) dropped most Intel Macs.
- **Risk:** May not support future Xcode versions within 1-2 years
- **Verdict:** Fine if you just need a Mac for occasional Xcode use NOW and don't mind it becoming obsolete. Not recommended for long-term investment.

### What NOT to Buy

- ❌ **Any Mac before 2018** — can't run recent macOS/Xcode
- ❌ **Mac Pro (trash can / cheese grater)** — expensive, overkill, power-hungry
- ❌ **MacBook 12" (2015-2017)** — underpowered, 1 USB-C port, can't run modern macOS
- ❌ **Any Mac with 4GB RAM** — Xcode will be painfully slow

### The "No Mac" Alternative: Cloud Mac

If you don't want to buy hardware:
- **MacinCloud** (https://www.macincloud.com/) — ~$1/hour or ~$30/month
- **AWS EC2 Mac** — Mac instances in the cloud
- **Limitation:** You can't connect your physical iPhone via USB to a cloud Mac, so you can only use simulators (not deploy to real devices)

### My Recommendation

**Get a used Mac Mini M1 for ~$250-350.** It's the cheapest path to full Apple development with no compromises:
- Plug into your existing monitor, keyboard, mouse
- Run Xcode natively with full speed
- Connect iPhone via USB, deploy to Watch wirelessly
- Small enough to sit next to your Linux machine
- Will be supported by Apple for years to come
- You can keep using your Linux machine for everything else and only switch to the Mac for iOS builds

---

## 15. Troubleshooting

### "Untrusted Developer" error on iPhone
→ Settings → General → VPN & Device Management → Trust your Apple ID

### "Developer Mode Required" error on iPhone
→ Settings → Privacy & Security → Developer Mode → Toggle ON → Restart

### Developer Mode not visible on iPhone
→ Install an app via Sideloadly first. The toggle appears after a sideloaded app is detected.

### Developer Mode not visible on Apple Watch
→ This is normal. It only appears after Xcode installs a developer app on the Watch. Sideloadly-installed iPhone apps do NOT trigger it.

### "App is compatible with device family 4, device supports 1"
→ You're trying to install a watchOS app (family 4) on an iPhone (family 1). The Watch `.ipa` cannot be installed on an iPhone — it's a Watch-only binary.

### App crashes immediately after opening
→ Check that your iPhone is running iOS 16 or later (Settings → General → About)

### Sideloadly shows "Could not connect to device"
→ Make sure iTunes (from Apple website, not Microsoft Store) is installed
→ Unlock your iPhone and tap "Trust This Computer"
→ Try a different USB cable
→ Restart both iPhone and Windows PC

### GitHub Actions build fails
→ Run `gh run view <RUN_ID> --log-failed` to see error details
→ Check that Xcode version in the workflow matches available versions on the runner

### GitHub Actions build stuck in "queued"
→ macOS runners have limited capacity. Wait 5-15 minutes. This is normal.

### Archive doesn't contain .app (only dSYMs)
→ Check that `SKIP_INSTALL = NO` is set for the target in `project.pbxproj`. If set to `YES`, the archive won't include the actual app binary.

### Watch app doesn't appear on Apple Watch
→ Watch apps cannot be sideloaded. You need Xcode on a Mac to install on Watch (see Section 11).

### "App is no longer available" (after 7 days)
→ Re-install via Sideloadly — this is a free Apple ID limitation
→ Consider the $99/year Apple Developer Program for permanent installation

---

## 16. Making Changes to the App

To modify the app and rebuild:

```bash
# 1. Edit the source files on your Linux machine
#    (e.g., add new quotes in QuoteManager.swift)

# 2. Commit and push
cd /path/to/apple/project
git add -A
git commit -m "Your change description"
git push origin main

# 3. GitHub Actions will automatically rebuild both apps

# 4. Check build status
gh run list --limit 1

# 5. Download new IPAs once the build succeeds
gh run download <NEW_RUN_ID> --name MyFirstAppleApp-iPhone-IPA
gh run download <NEW_RUN_ID> --name MyFirstWatchApp-IPA

# 6. Transfer to Windows PC and re-install via Sideloadly
```

---

## 17. Quick Reference

| Action | Command / Location |
|---|---|
| Check build status | `gh run list` |
| Download iPhone IPA | `gh run download <ID> --name MyFirstAppleApp-iPhone-IPA` |
| Download Watch IPA | `gh run download <ID> --name MyFirstWatchApp-IPA` |
| View build logs | `gh run view <ID> --log-failed` |
| GitHub Actions page | `https://github.com/YOUR_USERNAME/my-first-apple-app/actions` |
| Trigger manual build | `gh workflow run "Build iOS & watchOS Apps"` |

### Key Files to Edit

| File | What It Controls |
|---|---|
| `MyFirstAppleApp/MyFirstAppleApp/ContentView.swift` | iPhone app UI |
| `MyFirstAppleApp/MyFirstAppleApp/QuoteManager.swift` | iPhone quote data |
| `MyFirstAppleApp/MyFirstWatchApp/WatchContentView.swift` | Watch app UI |
| `MyFirstAppleApp/MyFirstWatchApp/WatchQuoteManager.swift` | Watch quote data |
| `MyFirstAppleApp/MyFirstAppleApp.xcodeproj/project.pbxproj` | Build settings, targets |
| `.github/workflows/build-ios.yml` | CI/CD build configuration |

---

*Guide created October 28, 2026. Updated with real-world findings from first deployment.*  
*Apps built with SwiftUI, compiled via GitHub Actions on macOS 14 with Xcode 15.4.*  
*Successfully installed on iPhone 12 Pro. Watch app awaiting Mac access for deployment.*
