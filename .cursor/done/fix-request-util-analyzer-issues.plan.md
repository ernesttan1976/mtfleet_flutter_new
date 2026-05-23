# Plan: Fix analyzer issues in `lib/util/request.dart`

Goals
- Ensure external packages are declared as dependencies if used, and resolve `depend_on_referenced_packages` warnings.

Context
- `http` package imports flagged as not a direct dependency.

Steps
1. Open `pubspec.yaml` and ensure `http` is listed under `dependencies` if `lib/util/request.dart` imports it directly.
2. If `http` is only used transitively and you prefer not to add it, replace usage with an available client that is a direct dependency or add the dependency.
3. Run `flutter pub get` and `flutter analyze` to confirm warnings are resolved.
4. Run any network-related tests to validate behavior.
