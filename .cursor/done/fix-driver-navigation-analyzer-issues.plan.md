# Plan: Fix analyzer issues in `lib/navigations/driverNavigation.dart`

Goals
- Fix library prefix naming, remove unnecessary keywords, and reorder widget constructor args.

Context
- `library_prefixes`, `library_private_types_in_public_api`, `unnecessary_this`, `sort_child_properties_last`, `unnecessary_new`.

Steps
1. Update prefix `Constants` to `constants` and change references.
2. Remove any `this.` qualifiers that are unnecessary.
3. Replace `new` usages with direct constructor calls.
4. Ensure `child:` is the last named parameter in widget constructors and reorder where appropriate.
5. Run `flutter analyze` and adjust until clean.
