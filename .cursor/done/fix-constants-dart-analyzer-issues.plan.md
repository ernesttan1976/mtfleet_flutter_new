# Plan: Fix analyzer issues in `lib/constants.dart`

Goals
- Resolve `constant_identifier_names` warnings either by renaming or by explicitly ignoring with a comment.
- Keep consumers compiling.

Context
- Constants flagged: `SERVER_URI`, `SERVER_URI_API`, `AUTH_CALLBACK`, `CURRENT_VERSION`.

Steps
1. Search project for usages of these constants.
2. If safe, rename to lowerCamelCase (e.g. `serverUri`) via IDE refactor to update all references.
3. If renaming is too invasive, add `// ignore: constant_identifier_names` above each constant or `// ignore_for_file: constant_identifier_names` with comment explaining legacy reasons.
4. Run `flutter analyze` and confirm issues addressed.
5. Add a short changelog entry describing the rename or lint exception.
