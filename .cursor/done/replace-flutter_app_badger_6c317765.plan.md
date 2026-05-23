---
name: Replace-flutter_app_badger
overview: Replace deprecated `flutter_app_badger` with `notification_badge_plus` (strong Android OEM support) across the transport_flutter codebase. The plan updates pubspec, replaces the wrapper in `lib/badger.dart`, and verifies platform configuration and device testing.
todos:
  - id: update-pubspec
    content: Remove `flutter_app_badger` and add `notification_badge_plus` to `/Volumes/MyCrucial/mtfleet/mtfleet_flutter_new/pubspec.yaml`, then run `flutter pub get`.
    status: pending
  - id: update-badger
    content: "Edit `/Volumes/MyCrucial/mtfleet/mtfleet_flutter_new/lib/badger.dart`: replace import and `FlutterAppBadger.updateBadgeCount(...)` with `NotificationBadgePlus.setBadgeCount(...)`. Make `changeBadgeCount` async and await the call. Keep singleton semantics."
    status: pending
  - id: ios-permissions-check
    content: "Confirm iOS notification permission request includes badge option. If missing, add `UNAuthorizationOptionBadge` to the existing permission request (code lives near notification setup using firebase_messaging or flutter_local_notifications). Files to inspect: `/Volumes/MyCrucial/mtfleet/mtfleet_flutter_new/ios/Runner/AppDelegate.*` and any notification-init code in Dart."
    status: pending
  - id: android-manifest-check
    content: Open `/Volumes/MyCrucial/mtfleet/mtfleet_flutter_new/android/app/src/main/AndroidManifest.xml` and follow `notification_badge_plus` README for any manifest permissions or receivers. Test on Samsung/Xiaomi/Huawei devices/emulators.
    status: pending
  - id: run-and-test
    content: Run `flutter pub get`, build and install on an iOS device and Android devices (Pixel and at least one OEM like Samsung). Validate badge set/clear behavior and fix platform-specific issues.
    status: pending
  - id: cleanup-deps
    content: After validation, remove unused plugin files (if any) and update `ios/Podfile.lock` and Android Gradle caches by running `pod install` in `ios/` and a clean Android build. Commit the changes with a clear message.
    status: pending
isProject: false
---

Summary

- Replace `flutter_app_badger` with `notification_badge_plus` because this project requires both iOS and broad Android (OEM) launcher support. `notification_badge_plus` provides set/get/clear APIs and explicit Android OEM handling.

Files to change (high-level)

- [transport_flutter/pubspec.yaml](/Volumes/MyCrucial/mtfleet/mtfleet_flutter_new/pubspec.yaml)
- [lib/badger.dart](/Volumes/MyCrucial/mtfleet/mtfleet_flutter_new/lib/badger.dart)
- iOS: possibly `ios/Runner/Info.plist` and confirm notification permission flow (project already uses `firebase_messaging` & `flutter_local_notifications`).
- Android: check `android/app/src/main/AndroidManifest.xml` and follow package install notes for OEM badges.

Current usage (excerpt)

```1:18:/Volumes/MyCrucial/mtfleet/mtfleet_flutter_new/lib/badger.dart
import 'package:flutter_app_badger/flutter_app_badger.dart';

class Badger {
  Badger._init();

  static final Badger _instance = Badger._init();

  factory Badger() => _instance;
  int _badgeCount = 0;

  int get badgeCount => _badgeCount;

  static void changeBadgeCount({int count = 1}) {
    _instance._badgeCount += count;
    if (_instance._badgeCount < 0) _instance._badgeCount = 0;
    FlutterAppBadger.updateBadgeCount(_instance._badgeCount);
  }
}
```

Proposed code change (replacement wrapper)

```dart
import 'package:notification_badge_plus/notification_badge_plus.dart';

class Badger {
  Badger._init();

  static final Badger _instance = Badger._init();

  factory Badger() => _instance;
  int _badgeCount = 0;

  int get badgeCount => _badgeCount;

  static Future<void> changeBadgeCount({int count = 1}) async {
    _instance._badgeCount += count;
    if (_instance._badge_count < 0) _instance._badgeCount = 0;
    await NotificationBadgePlus.setBadgeCount(_instance._badgeCount);
  }
}
```

(If you prefer `flutter_badge_manager` instead, the migration is identical conceptually—only import and API names differ.)

Platform notes & required checks

- iOS: App badges are controlled by APNs/UNUserNotificationCenter. The app must have notification authorization; since this repo already uses `firebase_messaging` + `flutter_local_notifications`, confirm the app requests notification permission with badge option. If not, add a permission request flow (UNAuthorizationOptionBadge).
- Android: Stock Android launchers do not support numeric icon badges — instead they show notification dots. `notification_badge_plus` implements OEM-specific methods for Samsung/Xiaomi/Huawei/OPPO/Vivo/Sony etc. Follow the package README for any AndroidManifest entries or receiver/service additions; some OEMs need no manifest change but others might require a small setup.
- Tests: test on a physical iOS device and several Android devices/launchers (Samsung, Xiaomi, stock Pixel) to confirm behavior.

Backward-compatibility

- The wrapper preserves the singleton and API shape so other code calling `Badger.changeBadgeCount(...)` doesn't need to change beyond being async-aware. We will keep the same method name but make it async returning Future<void>.

Migration steps (detailed todos below)

