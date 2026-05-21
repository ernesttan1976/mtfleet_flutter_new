---
name: fix-flutter-textscalefactor-deprecations
overview: Replace deprecated uses of MediaQuery.textScaleFactor in custom_time_picker.dart with the newer textScaler API while preserving behavior.
todos:
  - id: inspect-usage
    content: "Search `lib/components/Driver/custom_time_picker.dart` for all `textScaleFactor` usages and confirm they are limited to the tappable label builder and related code paths identified by analyzer lines 1285 and 1291. "
    status: completed
  - id: choose-textscaler-api
    content: Decide whether to use `MediaQuery.of(context).textScaler.textScaleFactor` or `textScaler.scale(1.0)` based on the project’s Flutter SDK version and available APIs.
    status: completed
  - id: update-label-scale
    content: Update `_buildTappableLabel` to compute `labelScaleFactor` using the chosen `textScaler` API while retaining the cap at 2.0x.
    status: completed
  - id: update-other-usages
    content: If any additional `textScaleFactor` usages exist in `custom_time_picker.dart`, migrate them to use `textScaler` consistently.
    status: completed
  - id: run-analyze-and-verify-ui
    content: Run `flutter analyze` and manually verify that the time picker labels look correct at different text scales and that deprecation warnings are resolved.
    status: completed
isProject: false
---

# Plan: Fix `textScaleFactor` deprecations in custom time picker

## 1. Understand current usage
- In `[lib/components/Driver/custom_time_picker.dart](/Volumes/MyCrucial/mtfleet/mtfleet_flutter_new/lib/components/Driver/custom_time_picker.dart)`, the deprecation warnings point to around lines 1285 and 1291.
- Existing code (simplified):

```1283:1292:/Volumes/MyCrucial/mtfleet/mtfleet_flutter_new/lib/components/Driver/custom_time_picker.dart
  _TappableLabel _buildTappableLabel(TextTheme textTheme, int value, String label, VoidCallback onTap) {
    final TextStyle? style = textTheme.titleMedium;
    final double labelScaleFactor = math.min(MediaQuery.of(context).textScaleFactor, 2.0);
    return _TappableLabel(
      value: value,
      painter: TextPainter(
        text: TextSpan(style: style, text: label),
        textDirection: TextDirection.ltr,
        textScaleFactor: labelScaleFactor,
      )..layout(),
      onTap: onTap,
    );
  }
```

- `MediaQuery.of(context).textScaleFactor` is deprecated; Flutter recommends `MediaQuery.textScaler` instead.

## 2. Decide on replacement behavior
- Goal: preserve existing cap at 2.0x while using the new API.
- The new API exposes `MediaQuery.textScaler` (a `TextScaler` instance) with methods like:
  - `textScaler.scale(double fontSize)` to compute scaled font size.
  - `textScaler.clamp(double textScaleFactor)` to clamp a factor.
- To keep the behavior closest to current code, we can:
  - Read the current effective factor via `MediaQuery.textScaler.textScaleFactor` (available in recent Flutter versions), or
  - Derive an equivalent capped factor using a helper.
- For forward compatibility and clarity, it’s common to implement a small helper that abstracts the deprecation fix and can be reused if more call sites are added later.

## 3. Concrete code changes

### 3.1 Introduce a helper to get capped text scale
- Add a private helper method inside the same state class as `_buildTappableLabel` (where `context` is available):
  - Signature idea: `double _labelTextScaleFactor(BuildContext context) { ... }`
  - Implementation:
    - Use `final textScaler = MediaQuery.of(context).textScaler;`
    - Get the base factor from `textScaler.textScaleFactor` if available in your Flutter SDK; otherwise approximate by applying `textScaler.scale(1.0)`.
    - Clamp the resulting factor with `math.min(effectiveFactor, 2.0)` to mimic the old behavior.

- Then update `_buildTappableLabel` to call this helper instead of referencing the deprecated property.

### 3.2 Replace deprecated usage in `_buildTappableLabel`
- Replace the line computing `labelScaleFactor` with something along these lines:

```1283:1292:/Volumes/MyCrucial/mtfleet/mtfleet_flutter_new/lib/components/Driver/custom_time_picker.dart
  _TappableLabel _buildTappableLabel(TextTheme textTheme, int value, String label, VoidCallback onTap) {
    final TextStyle? style = textTheme.titleMedium;
    final double labelScaleFactor = math.min(MediaQuery.of(context).textScaler.textScaleFactor, 2.0);
    return _TappableLabel(
      value: value,
      painter: TextPainter(
        text: TextSpan(style: style, text: label),
        textDirection: TextDirection.ltr,
        textScaleFactor: labelScaleFactor,
      )..layout(),
      onTap: onTap,
    );
  }
```

- If `textScaler.textScaleFactor` is not available in your Flutter version, adjust to:

```dart
final TextScaler textScaler = MediaQuery.of(context).textScaler;
// 1.0 is the unscaled baseline font size
final double labelScaleFactor = math.min(textScaler.scale(1.0), 2.0);
```

### 3.3 Ensure no other `textScaleFactor` usages remain
- Search within `[lib/components/Driver/custom_time_picker.dart](/Volumes/MyCrucial/mtfleet/mtfleet_flutter_new/lib/components/Driver/custom_time_picker.dart)` for `textScaleFactor`.
- If there are additional usages (for example, other `TextPainter`s or `Text` widgets), convert them using the same pattern:
  - Prefer `MediaQuery.of(context).textScaler.textScaleFactor` or `textScaler.scale(1.0)`.
  - Maintain any clamping logic (e.g., `math.min(..., 2.0)`).

## 4. Validation steps (after edits)
- Run `flutter analyze` to ensure deprecation warnings at lines 1285 and 1291 disappear.
- Verify that time picker labels still:
  - Respect system text scaling accessibility settings.
  - Do not grow beyond 2.0x (as before).
- Perform a quick manual UI check on devices/emulators with different text scale settings:
  - Normal scale (1.0)
  - Large accessibility scale (e.g. 1.8–2.0)

## 5. Optional refactor for reuse
- If you find similar label-building patterns elsewhere in the app:
  - Extract a shared helper (e.g., `_effectiveTextScaleFactor(BuildContext context, {double max = 2.0})`) either in this file or a small typography utility.
  - Update those sites to use `textScaler` instead of `textScaleFactor` as well.
- This is optional and only needed if you want to standardize text scaling behavior across multiple widgets.