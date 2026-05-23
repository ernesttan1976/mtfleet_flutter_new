# Plan: Fix analyzer issues in `lib/screens/Driver/PerformanceCard.dart`

Goals
- Address `library_private_types_in_public_api` and remove unused private fields.

Context
- `library_private_types_in_public_api`, `unused_field` (`_performanceCardScaffoldKey`).

Steps
1. Make fields public or change API signatures to avoid exposing private types publicly.
2. If `_performanceCardScaffoldKey` is unused, remove it. If intended for future use, add a `// TODO:` with explanation or wire it into the scaffold.
3. Run `flutter analyze` and ensure no remaining issues.
