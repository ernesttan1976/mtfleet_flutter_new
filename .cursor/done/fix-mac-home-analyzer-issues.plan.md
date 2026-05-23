# Plan: Fix analyzer issues in `lib/screens/MAC/home.dart`

Goals
- Address library private type exposures and replace `MaterialStateProperty` deprecated usages.

Context
- `library_private_types_in_public_api`, many `deprecated_member_use` for `MaterialStateProperty`.

Steps
1. Refactor public APIs to avoid returning or accepting private types.
2. Migrate `MaterialStateProperty` usages to the recommended replacement for the installed SDK.
3. Run `flutter analyze` and visually test the Home UI.
