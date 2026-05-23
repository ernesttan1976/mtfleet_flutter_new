# Plan: Fix analyzer issues in `lib/screens/appLoading.dart`

Goals
- Normalize import prefix naming, mark immutable constructors `const`, replace `DioError` usages with `DioException` if appropriate, and remove unnecessary containers.

Context
- `library_prefixes` (`DioClient`), `prefer_const_constructors_in_immutables`, `library_private_types_in_public_api`, `unnecessary_new`, `deprecated_member_use` (`DioError`), `avoid_unnecessary_containers`.

Steps
1. Rename import prefixes to snake_case and update references.
2. Add `const` where appropriate.
3. Replace deprecated `DioError` with `DioException` and adjust error handling as SDK requires.
4. Replace unnecessary `Container` instances.
5. Run `flutter analyze` and test app loading flows.
