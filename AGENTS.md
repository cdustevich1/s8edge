# AGENTS.md — S8Edge

S8Edge is an **iOS jailbreak tweak** built with **Theos**, originally from 2017 and now updated for **rootless jailbreaks on iOS 15+**. It makes an iPhone screen look like the Galaxy S8 "Infinity" display. It draws a passive overlay window in SpringBoard that adds **rounded screen corners** and a faint **white gradient glow on the left and right edges**. It also ships a **Settings (PreferenceLoader) bundle** so users can configure it.

- Package ID: `com.cdustevich1.s8edge` (see `control`, current version `1.3.0`). It `Conflicts`/`Replaces` the original `com.brunonfl.s8edge`.
- Scheme: **rootless only** (`THEOS_PACKAGE_SCHEME = rootless`, `iphoneos-arm64`, everything installs under `/var/jb`). Rootful is not supported.
- Depends on: `mobilesubstrate` (ElleKit on Dopamine), `preferenceloader`, `firmware (>= 15.0)`
- Primary test device: Dopamine, iOS 16.5
- License: GPL-3.0 (`LICENSE`). The original author is Bruno Andrade; keep him credited.

## Layout

| Path | Purpose |
|---|---|
| `Tweak.mm` | The whole tweak: prefs loading, `S8EOverlayViewController` (draws the overlay), `s8EdgeUI` (window/scene management), and the Logos `%hook SpringBoard`. |
| `Tweak.xm` | **Symlink to `Tweak.mm`.** The Makefile builds `Tweak.xm`, so edit `Tweak.mm` (they are the same file). |
| `CustoWindow.h/.m` | `UIWindow` subclass. It overrides the private `_ignoresHitTest` → `YES` so touches pass through the overlay. |
| `S8Edge.plist` | Substrate filter. The tweak loads only into `com.apple.springboard`. |
| `Makefile` | Root Theos makefile (tweak + `s8edgeprefs` subproject). Sets TARGET/ARCHS/scheme. |
| `control` | Debian package metadata. |
| `s8edgeprefs/` | Preference bundle `S8EdgePrefs` (`PSListController` subclass `S8ERootListController`, plus custom header cell `S8EdgeCustomCell`). |
| `s8edgeprefs/Resources/Root.plist` | Specifier list for the Settings pane (switches, sliders, Donate/Creators buttons). |
| `s8edgeprefs/layout/Library/PreferenceLoader/Preferences/S8EdgePrefs.plist` | PreferenceLoader entry. Theos stages `layout/` under the rootless prefix automatically. |
| `packages/` | Old build output (`.deb` files and so on). Theos writes new builds here. Don't edit; don't treat as source. |
| `README.md`, `README.pt-BR.md` | User-facing docs (EN / pt-BR). Keep both in sync when changing either. |

## How it works

1. `%hook SpringBoard -applicationDidFinishLaunching:` creates the global `s8EdgeUIvar` and calls `-initializeS8EdgeWindow`.
2. `S8ELoadPrefs()` reads the `com.cdustevich1.s8edgeprefs` domain through `CFPreferences`. If that's empty, it falls back to `/var/mobile/Library/Preferences/com.cdustevich1.s8edgeprefs.plist`. This path is the same on rootless, because cfprefsd isn't jbroot-prefixed.
3. **Window and scene (the iOS 16 fix).** On iOS 16, SpringBoard only displays windows attached to its main `SBWindowScene`, and a window created with `initWithFrame:` is never shown.
   - `S8EFindMainWindowScene()` picks the `UIWindowScene` on `UIScreen.mainScreen`, preferring `SBWindowScene`.
   - The window is created with `initWithWindowScene:`.
   - If no scene exists yet, `s8EdgeUI` waits for `UISceneWillConnectNotification`/`UISceneDidActivateNotification`. It tears the window down on `UISceneDidDisconnectNotification`.
   - On iOS 15, if there's no scene, it falls back to `initWithFrame:`.
4. The window is a `CustoWindow` at `kS8EWindowLevel` (1e7) with `_setSecure:YES`. It's shown with `hidden = NO`, **not** `makeKeyAndVisible`, so it never steals key-window or keyboard focus from SpringBoard.
5. `S8EOverlayViewController` is the window's root view controller. It's locked to portrait, so the glow stays on the physical long edges. It rebuilds layer frames and the mask path in `viewDidLayoutSubviews`.
   - **Rounded corners:** a solid black or white `UIView` masked by a `CAShapeLayer`. The mask path is a rounded rect plus a full rect, drawn with the `kCAFillRuleEvenOdd` fill rule, so only the corners stay visible.
   - **Edge overlay:** two horizontal `CAGradientLayer`s (white → clear) covering about 5% of the width at each side, on a view whose alpha comes from the opacity setting.
6. Settings only apply after a respring. The prefs pane's "Respring" button runs `ROOT_PATH("/usr/bin/killall") backboardd`.

### Debug logging
`S8E_DEBUG` in `Tweak.mm` (currently `1`) controls the `S8ELog` output, which is prefixed `[S8Edge]`. To read it, select the device in Console.app and filter on `S8Edge`. The logs show prefs, connected scenes at launch and 2 s later, and the overlay window's scene, visibility, and level. Set it to `0` for release builds.

### Preference keys (`com.cdustevich1.s8edgeprefs`)

| Key | Type | Root.plist default | Fallback in `Tweak.mm` if missing |
|---|---|---|---|
| `Status` | bool | `true` | enabled |
| `enableRoundedCorners` | bool | `true` | enabled |
| `sliderRadius` | real 0–30 | `24` | `24.0` |
| `whitePhone` | bool | `false` | black corners |
| `enableEdgeOverlay` | bool | `true` | enabled |
| `sliderOpacity` | real 1–100 (percent) | `20` | `0.2` |

When you add a setting, update **both** `Root.plist` and `S8ELoadPrefs()` in `Tweak.mm`.

## Build / install

Requires [Theos](https://theos.dev/) with `$THEOS` set and an iOS 15+ SDK.

```sh
make                                              # build
make package                                      # rootless .deb (iphoneos-arm64) into packages/
make package install THEOS_DEVICE_IP=<device-ip>  # install over SSH, then respring
```

Makefile settings: `TARGET = iphone:clang:latest:15.0`, `ARCHS = arm64 arm64e`, `THEOS_PACKAGE_SCHEME = rootless`, and `GO_EASY_ON_ME = 1`. Never commit a device IP; pass `THEOS_DEVICE_IP` on the command line.

There are no tests, linters, or CI. To verify a change, build it and check it on the jailbroken device. Run `dpkg -c` on the `.deb` to confirm every path is under `/var/jb`.

## Conventions and gotchas

- **Manual reference counting (MRC)**, not ARC. Use `retain`/`release`/`autorelease` consistently, or enable ARC on purpose for the whole project (`-fobjc-arc`).
- Objective-C++ with Logos (`%hook`, `%orig`). Don't rename `Tweak.mm` or break the `Tweak.xm` symlink.
- **Rootless paths:** never hard-code `/Library/...` or `/usr/...` for jailbreak files. Use `ROOT_PATH`/`ROOT_PATH_NS` from Theos's `<rootless.h>`, or bundle-relative loading (`S8EPrefsImage()` in the prefs controller). `/var/mobile/Library/Preferences` is **not** prefixed.
- **Windows must be scene-attached** on iOS 16+. Don't go back to a bare `initWithFrame:` window, and don't call `makeKeyAndVisible` on the overlay.
- Prefs are read once at SpringBoard launch. There is no Darwin notification or live reload.
- The prefs UI still uses the private `_UIBackdropView` on the Creators screen, with `-Wdeprecated-declarations` silenced.
- Keep the tweak lightweight and purely cosmetic. The overlay must never intercept touches (`_ignoresHitTest`, `userInteractionEnabled = NO`).
- `.DS_Store` files exist in the repo. Don't add more.
