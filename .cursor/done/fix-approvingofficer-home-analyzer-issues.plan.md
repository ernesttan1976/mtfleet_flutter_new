# Plan: Fix analyzer issues in `lib/screens/ApprovingOfficer/home.dart`

Goals
- Resolve private type exposure and encourage const literals where applicable.

Context
- `library_private_types_in_public_api`, `prefer_const_literals_to_create_immutables`.

Steps
1. Inspect any public API that references private types and refactor to public types or wrappers.
2. Convert list/collection literals to `const` where safe.
3. Run `flutter analyze` and verify no regressions.
