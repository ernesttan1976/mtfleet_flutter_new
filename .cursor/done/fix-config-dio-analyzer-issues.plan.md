# Plan: Fix analyzer issues in `lib/config/dio.dart`

Goals
- Rename import prefixes to lower_case_with_underscores.
- Remove unnecessary `new` keywords.
- Remove or use the unused `_initDioMemoizer` field.

Context
- `library_prefixes` for `Constants` (~line 7).
- `unnecessary_new` at several lines.
- `unused_field` `_initDioMemoizer` (~line 19).

Steps
1. Change `import '.../constants.dart' as Constants;` → `as constants;` and update usages.
2. Remove `new` keywords throughout the file.
3. Inspect `_initDioMemoizer`: if unused, delete; if intended, implement memoization or document and use it.
4. Run `flutter analyze` and confirm no remaining issues for the file.
5. Run any relevant integration tests that exercise HTTP init logic.
