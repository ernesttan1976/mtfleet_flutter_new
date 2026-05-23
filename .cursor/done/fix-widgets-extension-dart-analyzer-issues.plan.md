# Plan: Fix analyzer issues in `lib/components/extension/widgets.dart`

Goals
- Replace deprecated `withOpacity` uses with the recommended API.
- Preserve visual appearance.
- Clear `flutter analyze` for this file.

Context
- Analyzer: `deprecated_member_use` for `.withOpacity` at ~line 16.

Steps
1. Open the file and find `.withOpacity(...)` usage(s).
2. Replace with the current API (e.g. `.withValues(alpha: ...)` or `Color.fromRGBO`/`withAlpha`) that matches Flutter SDK used.
3. Validate alpha mapping and visual parity.
4. Run `flutter analyze` and fix any follow-up warnings.
5. Add a short note in the commit message why the replacement was made (SDK upgrade compatibility).
