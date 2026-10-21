[![en](https://img.shields.io/badge/lang-en-red.svg)](./README.md) [![pt-br](https://img.shields.io/badge/lang-pt--br-green.svg)](./README.pt-BR.md)

<div align="center">
  <img src="https://raw.githubusercontent.com/BrunoNFL/brunonfl.github.io/master/depictions/com.brunonfl.s8edge/icon%403x.png" width="80" alt="S8Edge Icon">
  <h1>S8Edge</h1>
</div>

A simple and lightweight jailbreak tweak that brought the popular curved "edge" screen aesthetic to iPhones. At its peak, this was my most downloaded tweak, responding to a popular design trend in the community.

---

<p align="center">
  <img src="https://raw.githubusercontent.com/BrunoNFL/brunonfl.github.io/master/depictions/com.brunonfl.s8edge/Screenshots/1.jpg" width="200" alt="S8Edge Screenshot 1">
  <img src="https://raw.githubusercontent.com/BrunoNFL/brunonfl.github.io/master/depictions/com.brunonfl.s8edge/Screenshots/2.jpg" width="200" alt="S8Edge Screenshot 2">
  <img src="https://raw.githubusercontent.com/BrunoNFL/brunonfl.github.io/master/depictions/com.brunonfl.s8edge/Screenshots/3.jpg" width="200" alt="S8Edge Screenshot 3">
</p>

---

## 💡 The Concept

This project wasn't about adding complex features. It was a direct response to a request from the `/r/jailbreak` subreddit. At a time when phones like the Samsung Galaxy S8 were popularizing curved-edge screens, a user wanted a simple way to bring that aesthetic to their iPhone.

S8Edge was created as a simple, elegant, and purely cosmetic solution to simulate that look and feel.

## ✨ Features

* **Simulated Curved Edges:** The tweak adds a clean overlay to the screen that gives the illusion of curved "edge" display borders.
* **Rounded Corners:** A key part of the effect was rounding the corners of the display, which became the most popular aspect of the tweak.
* **Black & White Color Options:** Users could choose between a black or white overlay to perfectly match the color of their device's bezel.
* **Lightweight & Efficient:** Designed as a simple, passive overlay, the tweak had virtually zero impact on performance or battery life.

## 🛠️ Technical Implementation & The iOS 16 Fix

### 1. The Core Issue on iOS 16
Prior to iOS 16, a SpringBoard tweak could create a custom `UIWindow` anywhere using `[[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds]`. UIKit automatically rendered any standalone window onto the primary display canvas.

Starting in **iOS 16**, Apple heavily refactored SpringBoard's multi-display and window management architectures (primarily to support Stage Manager and external screens):
* SpringBoard windows are no longer rendered globally on a screen-by-screen basis; instead, windows must be attached to an active **`UIWindowScene`** (specifically SpringBoard's primary `SBWindowScene`).
* If a `UIWindow` is initialized without a scene (or via legacy `initWithFrame:`), UIKit parks it on a disconnected dummy screen scene. The window reports `hidden = NO` and valid bounds, but the window server **never draws or composites it to the screen**.
* In addition, `SBWindowScene` is not always connected when `-[SpringBoard applicationDidFinishLaunching:]` executes. Creating the window prematurely results in a `nil` scene.

### 2. How S8Edge Was Fixed
To restore full functionality on iOS 16+:
* **Scene Discovery & Attachment:** The tweak inspects `[UIApplication sharedApplication].connectedScenes` for a `UIWindowScene` tied to `[UIScreen mainScreen]`, preferring SpringBoard's `SBWindowScene`. The overlay window is initialized explicitly using `-[CustoWindow initWithWindowScene:]`.
* **Dynamic Connection Monitoring:** If the main `SBWindowScene` has not finished connecting at SpringBoard launch, `s8EdgeUI` listens for `UISceneWillConnectNotification` and `UISceneDidActivateNotification`, deferring window instantiation until the scene is fully established. It also gracefully handles `UISceneDidDisconnectNotification`.
* **Root View Controller Architecture:** Instead of attaching raw views straight to `s8EdgeWindow`, views are hosted inside a dedicated transparent `S8EOverlayViewController` locked to portrait, ensuring proper rotation and layout updates via `viewDidLayoutSubviews`.
* **Window Level & Passthrough:** The window is set to level `10,000,000` (so it sits safely above the lock screen, Control Center, notifications, and banners) and uses `_ignoresHitTest` so all touches and gestures seamlessly pass through.
* **Native Rootless Support:** Updated project build scripts for the rootless jailbreak scheme (`THEOS_PACKAGE_SCHEME = rootless`, `iphoneos-arm64`), redirecting preference bundles and loader files into `/var/jb` and updating preference file paths and process-spawning logic.

## 📱 Compatibility

* **Rootless jailbreaks, iOS 15.0 and later** (tested on Dopamine, iOS 16.5). Rootful builds are no longer supported.
* Package ID: `com.cdustevich1.s8edge`. It replaces the original `com.brunonfl.s8edge`; uninstall that one first.
* Settings apply after a respring (there's a Respring button in the S8Edge settings pane).

## 💻 How to Compile

1.  Install [Theos](https://theos.dev/) with an iOS SDK (15.0 or later) and set `$THEOS`.
2.  Clone the repository:
    ```bash
    git clone https://github.com/cdustevich1/s8edge.git
    cd s8edge
    ```
3.  Build the rootless package:
    ```bash
    make package
    ```
    This produces a rootless `iphoneos-arm64` `.deb` in `packages/`.
4.  To build and install over SSH to your test device:
    ```bash
    make package install THEOS_DEVICE_IP=<device-ip>
    ```

**Credits:** Originally created by Bruno Andrade ([/u/BrunoNFL](https://reddit.com/u/BrunoNFL)) in 2017. Rootless / iOS 15+ update maintained by cdustevich1.
