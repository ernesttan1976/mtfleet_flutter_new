# Plan: Fix analyzer issues in `lib/screens/Driver/trip.dart`

Goals
- Use const literals for collection creation where possible.

Context
- `prefer_const_literals_to_create_immutables` at ~line 193.

Steps
1. Locate collection literals and change them to `const` where contents are compile-time constants.
2. Run `flutter analyze` and run a quick UI test for trip-related screens.
