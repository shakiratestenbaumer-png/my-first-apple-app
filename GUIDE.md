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
12. [Limitations & Notes](#12-limitations--notes)
13. [Troubleshooting](#13-troubleshooting)

---

## 1. Overview

Apple requires macOS + Xcode to build iOS and watchOS apps. Since we don't have a Mac, we use **GitHub Actions** which provides free macOS virtual machines for public repositories. The workflow is:

```
Write code (Linux) → Push to GitHub → GitHub Actions builds on macOS → Download .ipa → Sideload to devices
```

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

**On Windows (download from websites, NOT the Microsoft Store):**
- iTunes: https://www.apple.com/itunes/
- iCloud: https://support.apple.com/en-us/103232
- Sideloadly: https://sideloadly.io

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
    │   └── xcshareddata/xcschemes/    ← Build schemes
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
- Independent watchOS app (doesn't require iPhone app to run)

---

## 5. Setting Up GitHub CLI on Linux

### Step 1: Install GitHub CLI
```bash
sudo snap install gh --classic
```
> Note: The `--classic` flag is required because `gh` needs system-level access.

### Step 2: Authenticate
```bash
gh auth login
```

Answer the prompts:
1. **Account:** → `GitHub.com`
2. **Protocol:** → `HTTPS`
3. **Authenticate Git:** → `Yes`
4. **Method:** → `Login with a web browser`

A one-time code will appear. Go to https://github.com/login/device and enter it.

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

The push automatically triggers the GitHub Actions build because the workflow file (`.github/workflows/build-ios.yml`) is configured to run on every push to `main`.

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

### Option B: From the GitHub website
1. Go to your repo → **Actions** tab
2. Click the latest green ✅ build
3. Scroll down to **Artifacts**
4. Click to download:
   - `MyFirstAppleApp-iPhone-IPA` (the iPhone app)
   - `MyFirstWatchApp-IPA` (the Watch app)
5. The download is a `.zip` file — **extract it** to find the `.ipa` inside

---

## 9. Installing on iPhone (via Sideloadly on Windows)

### Preparation (One-time setup on Windows)

1. **Install iTunes** from https://www.apple.com/itunes/
   - ⚠️ MUST be the Apple website version, NOT the Microsoft Store version
2. **Install iCloud** from https://support.apple.com/en-us/103232
   - ⚠️ MUST be the Apple website version, NOT the Microsoft Store version
3. **Install Sideloadly** from https://sideloadly.io
   - Download the 64-bit version if your Windows is 64-bit
   - Check: Settings → System → About → "System type"

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

### ⚠️ Important: Watch App Sideloading Limitations

**Sideloadly and AltStore cannot install apps on Apple Watch.** They only support iPhone.

Unlike iPhones, the Apple Watch has no USB port — it communicates only via Bluetooth through its paired iPhone. The only ways to install a custom app on Apple Watch are:

| Method | Requirements |
|---|---|
| **Xcode on a Mac** | Physical or cloud Mac, iPhone connected via USB, Watch paired to iPhone. Xcode pushes the app: Mac → iPhone (USB) → Watch (Bluetooth) |
| **TestFlight** | $99/year Apple Developer Program. Upload via Xcode or CI, then install over-the-air on Watch |
| **App Store** | $99/year Apple Developer Program + Apple review process |

### If You Can Borrow a Mac for 30 Minutes

This is the quickest path to getting the Watch app on your wrist:

1. Clone the repo on the Mac:
   ```bash
   git clone https://github.com/YOUR_USERNAME/my-first-apple-app.git
   cd my-first-apple-app/MyFirstAppleApp
   open MyFirstAppleApp.xcodeproj
   ```
2. In Xcode: **Xcode → Settings → Accounts** → sign in with your Apple ID
3. In the project navigator, select the project → **MyFirstWatchApp** target → **Signing & Capabilities** → select your Team
4. Connect your **iPhone** via USB (the Watch must be paired with this iPhone)
5. In the scheme selector (top bar), choose **MyFirstWatchApp** and your Watch as destination
6. Click ▶️ **Run** — Xcode will install the app on your Watch via iPhone

### Developer Mode on Apple Watch

Developer Mode on Apple Watch (Settings → Privacy & Security → Developer Mode) only appears **after** a developer app has been installed via Xcode. It will not show up from Sideloadly-installed iPhone apps. This is expected behaviour — once you install via Xcode, the toggle will appear.

### Current Status

The Watch app code is **fully written and compiles successfully** on GitHub Actions. The `.ipa` artifact is built and ready. It's waiting for Mac access to be installed on the physical Watch device.

---

## 12. Limitations & Notes

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
- You can distribute via TestFlight or the App Store

### GitHub Actions Free Tier
- Public repositories get **free** macOS runner minutes
- Private repositories get limited free minutes per month
- macOS runners may experience queue delays during busy periods

---

## 13. Troubleshooting

### "Untrusted Developer" error on iPhone
→ Settings → General → VPN & Device Management → Trust your Apple ID

### "Developer Mode Required" error
→ Settings → Privacy & Security → Developer Mode → Toggle ON → Restart

### App crashes immediately after opening
→ Check that your iPhone is running iOS 16 or later (Settings → General → About)

### Sideloadly shows "Could not connect to device"
→ Make sure iTunes (from Apple website, not Microsoft Store) is installed
→ Unlock your iPhone and tap "Trust This Computer"
→ Try a different USB cable

### GitHub Actions build fails
→ Run `gh run view <RUN_ID> --log-failed` to see error details
→ Check that Xcode version in the workflow matches available versions on the runner

### Watch app doesn't appear on Apple Watch
→ Make sure the Watch is paired with the iPhone
→ Open the Watch app on iPhone → scroll to "Available Apps"
→ Ensure both iPhone and Watch have Developer Mode enabled

### "App is no longer available" (after 7 days)
→ Re-install via Sideloadly — this is a free Apple ID limitation
→ Consider the $99/year Apple Developer Program for permanent installation

---

## Making Changes to the App

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

## Quick Reference

| Action | Command / Location |
|---|---|
| Check build status | `gh run list` |
| Download iPhone IPA | `gh run download <ID> --name MyFirstAppleApp-iPhone-IPA` |
| Download Watch IPA | `gh run download <ID> --name MyFirstWatchApp-IPA` |
| View build logs | `gh run view <ID> --log-failed` |
| GitHub Actions page | `https://github.com/YOUR_USERNAME/my-first-apple-app/actions` |
| Trigger manual build | `gh workflow run "Build iOS & watchOS Apps"` |

---

*Guide created October 28, 2026. Apps built with SwiftUI, compiled via GitHub Actions on macOS 14 with Xcode 15.4.*
