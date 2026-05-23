# Plan: Fix analyzer issues in `lib/navigations/macNavigation.dart`

Goals
- Address import prefix style, private type exposure, unnecessary `this.` and `new`, and constructor arg ordering.

Context
- `library_prefixes`, `library_private_types_in_public_api`, `unnecessary_this`, `sort_child_properties_last`, `unnecessary_new`.

Steps
1. Rename import prefixes to snake_case and update references.
2. Remove unnecessary `this.` qualifiers.
3. Replace `new` with direct constructor invocation.
4. Reorder widget named parameters so `child:` is last when required.
5. Run `flutter analyze` and verify.
