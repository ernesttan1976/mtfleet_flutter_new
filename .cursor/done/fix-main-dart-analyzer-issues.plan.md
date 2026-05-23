# Plan: Fix analyzer issues in `lib/main.dart`

Goals
- Fix missing required named parameters and positional/named argument mismatch.
- Add `key` parameters to widgets, remove unused locals, and apply small style improvements.

Context
- Missing required named args: `servicingId` (line ~154), `id` (line ~306).
- `extra_positional_arguments_could_be_named` at ~307.
- `use_key_in_widget_constructors`, `library_private_types_in_public_api`, unused locals and `prefer_conditional_assignment`.

Steps
1. Inspect call sites that the analyzer flagged; supply required named arguments or update constructors to accept the current call pattern.
2. Convert positional args to named ones if the callee expects named parameters.
3. Add `Key? key` to public widget constructors and forward to `super`.
4. Remove or use unused local variables (notification streams) or wire them properly.
5. Apply `x ??= ...` where `prefer_conditional_assignment` suggests.
6. Run `flutter analyze` and smoke-test app startup flows.
