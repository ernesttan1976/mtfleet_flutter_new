# Plan: Fix analyzer issues in `lib/util/currentUserData.dart`

Goals
- Address `constant_identifier_names` for `SUPPORTED_ROLES`.

Context
- `SUPPORTED_ROLES` flagged for not following lowerCamelCase.

Steps
1. Evaluate whether renaming is feasible; if so, rename to `supportedRoles` and update all references via refactor.
2. If renaming is not acceptable, add a file-level `// ignore_for_file: constant_identifier_names` with a short comment.
3. Run `flutter analyze` and ensure there are no remaining warnings.
