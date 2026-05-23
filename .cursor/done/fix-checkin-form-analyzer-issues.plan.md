# Plan: Fix analyzer issues in `lib/screens/MAC/CheckInForm.dart`

Goals
- Convert collection literals to `const` where safe.

Context
- `prefer_const_literals_to_create_immutables` at multiple locations.

Steps
1. Find collection literals that can be `const` and change them.
2. Run `flutter analyze` and verify nothing else is flagged.
3. Run the check-in form flow to ensure runtime correctness.
