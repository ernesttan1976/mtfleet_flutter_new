# Plan: Fix analyzer issues in `lib/screens/Driver/home.dart`

Goals
- Remove unnecessary `Container` usage and prefer const literals where possible.

Context
- Several `avoid_unnecessary_containers` entries and `prefer_const_literals_to_create_immutables`.

Steps
1. Replace trivial `Container` instances with `SizedBox`, `Padding`, or direct child usage.
2. Convert collection literals to `const` where contained values are compile-time constants.
3. Run `flutter analyze` and visually test the home screen.
