# Plan: Fix analyzer issues in `lib/screens/Driver/past_14_days_elog/bloc.dart`

Goals
- Normalize prefix naming, remove `new`, avoid leading underscores on local variable names, and remove unnecessary string interpolation.

Context
- `library_prefixes` (`Request`), `unnecessary_new`, `no_leading_underscores_for_local_identifiers`, `unnecessary_string_interpolations`.

Steps
1. Rename import prefixes to snake_case.
2. Remove `new` usages.
3. Rename local variables (`_list` etc.) if they are not intended to be private fields.
4. Replace `"${value}"` with `"$value"` or use direct values where interpolation is unnecessary.
5. Run `flutter analyze` and test the bloc flows.
