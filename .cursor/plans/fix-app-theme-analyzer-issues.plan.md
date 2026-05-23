---
name: ""
overview: ""
todos: []
isProject: false
---

# Plan: Fix analyzer issues in `lib/theme/app_theme.dart`

Goals
- Update ThemeData API usage to match current Flutter SDK types (`CardThemeData`, `DialogThemeData`) and replace removed text style named parameters with the new TextTheme names.

Context
- `argument_type_not_assignable` for `CardTheme`/`DialogTheme` types.
- `undefined_named_parameter` for `headline1`, `headline4`, `headline5`, `headline6`, `bodyText1`, `bodyText2`, `subtitle1`, `subtitle2` — the older TextTheme named parameters.

Steps
1. Inspect `ThemeData` construction and map existing `CardTheme`/`DialogTheme` instances to the new expected data types (or use the correct classes the SDK expects).
2. Replace deprecated `TextTheme` names with their modern equivalents (e.g. `headline1`→`displayLarge`, `headline6`→`titleSmall`, `bodyText1`→`bodyLarge`, etc.) according to the SDK documentation.
3. Run `flutter analyze` and ensure the theme compiles.
4. Review app visuals for any typography or theme regressions.