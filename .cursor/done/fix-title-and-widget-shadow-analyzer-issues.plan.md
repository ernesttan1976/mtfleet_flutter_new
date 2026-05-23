# Plan: Fix analyzer issues in `lib/components/title_and_widget_shadow.dart`

Goals
- Add named `Key? key` parameter to public widget constructors.
- Mark immutable widget constructors `const` when possible.
- Remove or re-use the unused private helper `_buildInputTitle`.

Context
- `use_key_in_widget_constructors`, `prefer_const_constructors_in_immutables` at ~line 12.
- `unused_element` for `_buildInputTitle` at ~line 63.

Steps
1. Edit the widget constructor to include `Key? key` and call `super(key: key)`.
2. If the class is `@immutable` and fields are `final`, mark the constructor as `const`.
3. Search references for `_buildInputTitle`; if unused, remove it; if intended, connect it to the build flow.
4. Run `flutter analyze` and fix any follow-up issues.
5. Verify UI where this widget is used remains unchanged.
