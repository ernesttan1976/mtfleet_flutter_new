# Plan: Fix analyzer issues in `lib/screens/Driver/mtrcForm.dart`

Goals
- Remove unnecessary braces and `new` usages, fix override annotations, and simplify string interpolations.

Context
- `unnecessary_brace_in_string_interps`, `override_on_non_overriding_member`, `unnecessary_new`, `curly_braces_in_flow_control_structures`.

Steps
1. Replace `"${value}"` with `"$value"` when braces are unnecessary.
2. Ensure methods marked with `@override` truly override a superclass method; remove `@override` where not applicable or correct the signature.
3. Remove `new` keywords.
4. Add braces to single-statement `if` blocks where required.
5. Run `flutter analyze` and test form behaviour.
