# Plan: Fix analyzer issues in `lib/screens/MAC/Maintenance.dart`

Goals
- Add const constructors for immutable classes, avoid exposing private types, fix local naming, replace unnecessary string interpolations, and remove redundant Containers.

Context
- `prefer_const_constructors_in_immutables`, `library_private_types_in_public_api`, `no_leading_underscores_for_local_identifiers`, many `avoid_unnecessary_containers`, `unnecessary_string_interpolations`, `sort_child_properties_last`, and `argument_type_not_assignable` (`int?` → `String`).

Steps
1. Make immutable constructors `const` where appropriate.
2. Change public APIs to avoid private types.
3. Rename local variables to remove leading underscores when not private.
4. Fix `int?` to `String` mismatches by converting to string safely (`?.toString() ?? ''`) or change param types as needed.
5. Replace unneeded `Container` instances and unnecessary string interpolations.
6. Run `flutter analyze` and test maintenance screens.
