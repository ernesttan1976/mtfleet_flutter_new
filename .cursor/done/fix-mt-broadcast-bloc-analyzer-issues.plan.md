# Plan: Fix analyzer issues in `lib/screens/Driver/mt_broad_cast/bloc.dart`

Goals
- Normalize import prefixes, remove `new`, fix local naming conventions, handle nullable argument types, and prefer string interpolation.

Context
- `library_prefixes`, `unnecessary_new`, `no_leading_underscores_for_local_identifiers`, `argument_type_not_assignable` (`String?` → `String`), `prefer_interpolation_to_compose_strings`.

Steps
1. Rename import prefixes (e.g. `Request` → `request`) and update usages across the file.
2. Remove `new` keywords.
3. Rename local variables to avoid leading underscores where not intended private fields.
4. Fix types for function calls expecting `String` but receiving `String?` by providing fallbacks or making params nullable.
5. Replace string concatenation with interpolation where recommended.
6. Run `flutter analyze`.
