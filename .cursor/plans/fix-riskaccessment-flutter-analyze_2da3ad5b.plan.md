---
name: fix-riskAccessment-flutter-analyze
overview: Resolve flutter_analyze issues in riskAccessment.dart by updating deprecated TextTheme getters, cleaning unnecessary containers, updating deprecated MaterialStateProperty usage, and tightening the widget API.
todos:
  - id: cleanup-imports-and-const-constructor
    content: "Remove unnecessary Cupertino import and mark RiskAccessmentScreen constructor const if safe in lib/screens/Driver/riskAccessment.dart.\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
    status: completed
  - id: update-texttheme-getters
    content: Replace deprecated TextTheme getters headline4/bodyText1 with headlineMedium/bodyLarge throughout lib/screens/Driver/riskAccessment.dart while preserving copyWith styles.
    status: completed
  - id: remove-unnecessary-containers
    content: Refactor Rows in lib/screens/Driver/riskAccessment.dart to remove Container wrappers that add no layout behavior, keeping padding/width where necessary.
    status: completed
  - id: migrate-materialstateproperty
    content: Update ButtonStyle in lib/screens/Driver/riskAccessment.dart to use WidgetStateProperty instead of deprecated MaterialStateProperty for shape and side.
    status: completed
  - id: recheck-flutter-analyze-riskaccessment
    content: Re-run flutter analyze for lib/screens/Driver/riskAccessment.dart and confirm that all listed issues between lines 560–604 in flutter_analyze.md are resolved without new lints.
    status: completed
isProject: false
---

## Goals
- Fix all `flutter analyze` issues listed for `lib/screens/Driver/riskAccessment.dart` lines 560–604 in `flutter_analyze.md`.
- Keep UI/UX identical while modernizing deprecated and discouraged APIs.

## Context from current code
- File: `[lib/screens/Driver/riskAccessment.dart](lib/screens/Driver/riskAccessment.dart)`
- The screen is a `StatefulWidget` with nullable parameters and a non-const constructor.
- Typography uses deprecated `TextTheme` getters like `headline4` and `bodyText1` (e.g., lines 45–46, 55–56, 68–69, 78–79, 88–93, 106–113, etc.).
- Many `Row` children wrap `Flexible` inside a `Container` for no layout reason.
- `OutlinedButton` styles use deprecated `MaterialStateProperty` (lines 270–274, 295–299).

## Plan

### 1. Clean up imports and widget API
- Remove the unnecessary `Cupertino` import at line 1 since only Material widgets are used.
- Mark `RiskAccessmentScreen` constructor as `const` since all fields are `final` and it has no mutable parameters.
- Consider tightening the type of callbacks and booleans if straightforward (e.g., prefer `void Function(int index)` instead of bare `Function`), but only if it does not ripple into other files.

### 2. Replace deprecated TextTheme getters
- Identify all uses of:
  - `Theme.of(context).textTheme.headline4`
  - `Theme.of(context).textTheme.bodyText1`
- Replace them with modern equivalents while preserving approximate visual weight:
  - Map `headline4` to `headlineMedium`.
  - Map `bodyText1` to `bodyLarge`.
- Where `copyWith` is used, keep the same `color` and `fontWeight` arguments.
- Verify that any `Text.rich` spans consistently use the updated styles.

### 3. Remove unnecessary Container widgets
- For each `Row` like:
  - `Container(child: Flexible(child: Text(...)))`
- Simplify to just `Flexible(child: Text(...))` (or `Expanded` where width filling is desired), unless the `Container` provides non-default padding, margin, width, or decoration.
- Specifically target the lines referenced by `avoid_unnecessary_containers` diagnostics (41, 53, 64, 75, 85, 103, 122, 141, 151, 160, 170, 180, 193, 203, 214, 225, 235, 247, 257, 265, 290, 291, 300, etc.) and keep any layout-related properties by moving them to the remaining widget when needed.

### 4. Update deprecated MaterialStateProperty usage
- Locate `ButtonStyle` creation for the `OutlinedButton` near the bottom of `_buildChildren`:
  - `shape: MaterialStateProperty.all(RoundedRectangleBorder(...))`
  - `side: MaterialStateProperty.all(BorderSide(...))`
- Update these to use `WidgetStateProperty` equivalents now recommended in Flutter 3.19+:
  - `WidgetStateProperty.all<RoundedRectangleBorder>(...)`
  - `WidgetStateProperty.all<BorderSide>(...)`
- Keep the rest of the button configuration (`borderRadius`, `primaryColor` border, `onPressed` handler) unchanged.

### 5. Re-run analysis and verify
- Re-run `flutter analyze` (or check `flutter_analyze.md` regeneration) focused on `riskAccessment.dart`.
- Confirm that the following issues are resolved without introducing new ones:
  - `unnecessary_import` for `cupertino.dart`.
  - All `undefined_getter` errors for `headline4` and `bodyText1`.
  - All `avoid_unnecessary_containers` infos tied to this file.
  - All `deprecated_member_use` infos for `MaterialStateProperty`.
- If any additional lints appear after updates (e.g., about `Function` types or null checks), decide whether to:
  - Fix them if trivial and purely local, or
  - Document as future cleanups to avoid scope creep.

## Notes / Trade-offs
- Mapping `headline4` → `headlineMedium` and `bodyText1` → `bodyLarge` preserves relative hierarchy within the updated Material 3 text theme; minor visual differences are acceptable for compatibility.
- Keeping constructor arguments nullable avoids touching other callers; we only add `const` where safe.
- Container removals are conservative: only remove when they add no layout behavior, to avoid subtle spacing changes.