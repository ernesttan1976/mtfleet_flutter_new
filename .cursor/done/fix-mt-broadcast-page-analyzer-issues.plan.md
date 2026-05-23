# Plan: Fix analyzer issues in `lib/screens/Driver/mt_broad_cast/page.dart`

Goals
- Add `key` to widgets, avoid exposing private types publicly, prefer const literals, replace deprecated `withOpacity`, and fix undefined getters on `TextTheme`.

Context
- `use_key_in_widget_constructors`, `library_private_types_in_public_api`, `prefer_const_literals_to_create_immutables`, `deprecated_member_use` for `withOpacity`, `undefined_getter` for `subtitle1`.

Steps
1. Add `Key? key` to public widget constructors and forward it.
2. Replace any `.withOpacity` calls as per SDK guidance.
3. If `subtitle1` is not available in the current `TextTheme`, map to the appropriate replacement (e.g. `titleMedium`/`bodyMedium`, depending on SDK version).
4. Use `const` for immutable collection literals.
5. Run `flutter analyze` and visually inspect affected pages.
