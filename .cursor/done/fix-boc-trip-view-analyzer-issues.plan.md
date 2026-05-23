# Plan: Fix analyzer issues in `lib/screens/Driver/bocTripView.dart`

Goals
- Mark constructors `const` where immutable, make private types public in APIs where needed, and add explicit types for uninitialized fields.

Context
- `prefer_const_constructors_in_immutables`, `library_private_types_in_public_api`, `prefer_typing_uninitialized_variables`.

Steps
1. Add `const` to constructors of immutable classes with `final` fields.
2. For any public APIs using private types, refactor to avoid exposing private types.
3. Add explicit type annotations to previously untyped uninitialized fields.
4. Run `flutter analyze` and run any relevant UI tests.
