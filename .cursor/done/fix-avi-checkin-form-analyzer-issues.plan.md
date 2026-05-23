# Plan: Fix analyzer issues in `lib/screens/MAC/AVICheckInForm.dart`

Goals
- Fix missing URI import (`components/typeahead.dart`) and clean up other minor lints (private type exposure, unnecessary string interpolation, sized_box_for_whitespace).

Context
- `uri_does_not_exist` for `package:transport_flutter/components/typeahead.dart` (~line 13).
- Other lints include `library_private_types_in_public_api`, `prefer_function_declarations_over_variables`, `unnecessary_string_interpolations`, and `sized_box_for_whitespace`.

Steps
1. Ensure `components/typeahead.dart` exists at the expected path; if not, update the import to the correct package/path or add the missing file.
2. Replace variable-assigned functions with top-level function declarations where suggested.
3. Replace `${value}` interpolations that are unnecessary.
4. Use `SizedBox` for whitespace instead of padding `Container` per recommendations.
5. Run `flutter analyze` and test the check-in flows.
