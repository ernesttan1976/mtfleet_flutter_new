# Plan: Fix analyzer issues in `lib/screens/MAC/CorrectiveCheckInForm.dart`

Goals
- Avoid exposing private types publicly and convert function-assigned variables to declarations when advised. Replace layout `Container` whitespace with `SizedBox`.

Context
- `library_private_types_in_public_api`, `prefer_function_declarations_over_variables`, `sized_box_for_whitespace`.

Steps
1. Refactor public APIs to avoid private types.
2. Replace function-valued variables with function declarations where applicable.
3. Replace whitespace-creating `Container`s with `SizedBox`.
4. Run `flutter analyze` and test the form.
