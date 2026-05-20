# Migration checklist — mtfleet-flutter → mtfleet_flutter_new

This document explains a safe, minimal process to migrate the necessary native and configuration changes from the old Flutter project (`mtfleet-flutter`) into the new project (`mtfleet_flutter_new`). Do NOT copy `.dart_tool` or overwrite the whole `android/` or `ios/` folders; instead inspect and selectively port only custom additions.

---

## 1) Important principles

- `.dart_tool`
  - This is a generated cache. Do NOT copy it. Run `flutter pub get` in the new project to generate a fresh one.

- `android/` and `ios/`
  - Keep the `android/` and `ios/` directories created by `mtfleet_flutter_new` as the canonical host projects.
  - Manually migrate only app-specific or non-template changes from the old project's `android/` and `ios/`.

- Work incrementally on a feature branch and test frequently on device/emulator.

---

## 2) Quick reference to current Flutter dependencies (new project)

See the `dependencies` in `pubspec.yaml` — these are the libraries you need to support in native projects and during plugin setup.

```30:66:/Volumes/MyCrucial/mtfleet/mtfleet_flutter_new/pubspec.yaml
dependencies:
  flutter:
    sdk: flutter

  # The following adds the Cupertino Icons font to your application.
  # Use with the CupertinoIcons class for iOS style icons.
  cupertino_icons: ^1.0.8
  chewie: ^1.3.6
  # The following adds the Cupertino Icons font to your application.
  # Use with the CupertinoIcons class for iOS style icons.
  dio: ^5.9.2
  flutter_secure_storage: ^10.2.0
  webview_flutter: ^4.13.1
  async: ^2.8.2
  flutter_form_builder: ^10.3.0+2
  intl: ^0.20.2
  sqflite: ^2.0.3+1
  cached_network_image: ^3.2.1
  flutter_file_dialog: ^3.0.3
  percent_indicator: ^4.2.2
  flutter_chips_input: ^2.0.0
  sentry_flutter: ^9.0.0
  rxdart: ^0.28.0
  image: ^4.8.0
  flutter_local_notifications: ^21.0.0
  app_badge_plus: ^1.2.10
  external_path: ^2.2.0
  permission_handler: ^12.0.1
  flutter_typeahead: ^6.0.0
  form_builder_validators: ^11.3.0
  logger: ^2.7.0
  firebase_core: ^4.9.0
  firebase_messaging: ^16.2.2

  http: any
  path_provider: any
  video_player: any
```

Note: plugin-heavy projects like this typically require some platform-specific setup (Firebase, notifications, file access, permissions, etc.).

---

## 3) High-level migration steps (recommended order)

1. Create a branch in the new project:
   - git checkout -b migrate/native-from-old

2. Compare `pubspec.yaml` files between the old and new projects and ensure all required plugins are listed in the new project's `pubspec.yaml`. Run:
   - flutter pub get

3. Copy assets and fonts
   - Copy `assets/` and `fonts/` referenced in `pubspec.yaml` from old → new. Preserve folder structure and permissions.

4. Identify native changes in the old project to port. In the old repo, examine (but do NOT copy entire folders):
   - iOS
     - `ios/Runner/Info.plist` — URL schemes, permissions descriptions (NSCameraUsageDescription, etc.)
     - `ios/Runner/Runner.entitlements` — push, app groups, etc.
     - `ios/Runner/AppDelegate.swift` (or AppDelegate.m) — custom native code, plugin setup hooks
     - `ios/Podfile` — CocoaPods platform or post_install tweaks
     - `ios/GoogleService-Info.plist` — Firebase iOS config (DON'T commit secrets to repo if you keep them private)
   - Android
     - `android/app/src/main/AndroidManifest.xml` — permissions, intent filters, deep links
     - `android/app/src/main/kotlin/.../MainActivity.kt` or `MainActivity.java` — custom native code & plugin bridging
     - `android/app/google-services.json` — Firebase Android config
     - `android/app/build.gradle` and root `build.gradle` — signing configs, minSdk, targetSdk, proguard rules, additional repositories
     - `android/gradle.properties` — property flags used by plugins

5. For each native item you found, port only the necessary snippets into the new project's corresponding file. Example small-port checklist:
   - Add entries from old `Info.plist` (usage descriptions, URL schemes) into new `ios/Runner/Info.plist`.
   - Add Firebase `GoogleService-Info.plist` into new `ios/Runner/` (and follow plugin docs to integrate).
   - Apply only the needed `AndroidManifest.xml` permissions/intent-filters into new `android/app/src/main/AndroidManifest.xml`.
   - Copy `google-services.json` into new `android/app/` and follow plugin docs for Gradle setup.
   - Re-apply any small `AppDelegate` native code into new `ios/Runner/AppDelegate.*` (resolve API changes if templates differ).

6. Follow plugin-specific manual steps
   - Consult plugin docs (Firebase, flutter_local_notifications, permission_handler, etc.) and apply required platform changes. Example:
     - firebase_messaging: add background handlers, update AppDelegate, set up capabilities for iOS (Push Notifications, Background Modes), add `google-services.json` and `GoogleService-Info.plist`.
     - flutter_local_notifications: add required Swift or Kotlin setup and manifest entries.
     - permission_handler: ensure Android `Gradle` config and iOS usage descriptions exist.

7. Run build & fix issues iteratively
   - Run `flutter clean` then `flutter pub get`.
   - Build and run on Android emulator: `flutter run -d emulator-xxxx` or `flutter build apk`.
   - Build and run on iOS device/simulator: `flutter build ios` then open `ios/Runner.xcworkspace` in Xcode as needed to resolve signing/capability issues.

8. Test thoroughly (emulator/device) for features that rely on native integrations (notifications, file pickers, webviews, firebase, background tasks).

---

## 4) Concrete checklist: files to inspect & example snippets

- Copy or inspect these files in the old repo and port only the necessary lines:

  - iOS
    - ios/Runner/Info.plist  → copy NSCameraUsageDescription, NSPhotoLibraryUsageDescription, URL schemes
    - ios/Runner/AppDelegate.swift → port initialization code (e.g. FirebaseApp.configure())
    - ios/GoogleService-Info.plist → add to new project (do NOT commit secrets to public repo)

  - Android
    - android/app/src/main/AndroidManifest.xml → copy needed <uses-permission/> and <intent-filter/>
    - android/app/google-services.json → add to new project
    - android/app/src/main/kotlin/.../MainActivity.kt → copy only custom methods or plugin registrations
    - android/app/build.gradle(.kts) → apply signing config or proguard rules only if necessary

- Example: Info.plist addition (merge into new project's Info.plist):

```xml
<key>NSCameraUsageDescription</key>
<string>Camera access is required to take photos for profile pictures</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Photo library access is required to pick images</string>
```

- Example: AndroidManifest permission (merge into new project's AndroidManifest.xml):

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
```

---

## 5) Notes about secrets and config files

- `google-services.json` and `GoogleService-Info.plist` contain app-specific credentials. Keep them out of public repos. Use CI/secret management or local developer copies.
- If your old project used environment-based config (flavors, build variants), document these and port only the relevant config.

---

## 6) Git workflow & safety

- Make a branch `migrate/native-from-old`.
- Commit only the intentional changes (Info.plist edits, AndroidManifest edits, added GoogleService files if allowed).
- Do not add `.dart_tool/` to repo. Ensure `.gitignore` contains it.
- Keep a small PR describing what native changes were ported and why.

---

## 7) Follow-up actions I can do for you

- Compare `pubspec.yaml` between the old and new projects and produce a diff of missing plugins.
- Scan the old `ios/` and `android/` for non-template files and produce a short list of concrete changes (file and line ranges) you may want to port.
- Create a small patch (targeted edits) to the new project's `Info.plist` / `AndroidManifest.xml` if you give me write permission to apply them.

---

Place this file in your new project's root and follow the checklist step-by-step. If you want, I can now scan the old `ios/` and `android/` folders for likely non-template changes and prepare the exact snippets to paste into the new project.
