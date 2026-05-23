# Plan: Fix analyzer issues in `lib/screens/learningVideo.dart`

Goals
- Normalize import prefixes, prefer const constructors/collections, remove unused elements, and enforce braces on control flow statements.

Context
- `library_prefixes` (`Constants`), `prefer_const_constructors_in_immutables`, `library_private_types_in_public_api`, `unused_element` (`_buildList`), `curly_braces_in_flow_control_structures`, `unnecessary_new`.

Steps
1. Fix import prefix names and update references.
2. Mark immutable constructors `const` and collection literals `const` where possible.
3. Remove or rewire `_buildList` if unused.
4. Add braces for single-line `if` statements where flagged.
5. Run `flutter analyze` and check relevant video list UI.
