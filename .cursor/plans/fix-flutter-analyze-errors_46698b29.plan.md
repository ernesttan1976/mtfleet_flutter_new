---
name: fix-flutter-analyze-errors
overview: Plan to resolve all flutter analyze issues in mtfleet_flutter_new, updating for modern Flutter APIs and cleaning up lints file by file.
todos:
  - id: update-analysis-options
    content: Fix analysis_options.yaml include and ensure lint package dependency is present in pubspec.yaml dev_dependencies for mtfleet_flutter_new project. Run flutter pub get afterwards when executing the plan. (Plan-only step now).
    status: pending
  - id: define-texttheme-mapping
    content: Adopt a global TextTheme migration mapping (bodyText1 -> bodyLarge, etc.) and apply it consistently wherever TextTheme getters are used in the codebase.
    status: pending
  - id: fix-alertdialog-constructor
    content: Update lib/components/AlertDialog.dart to use the current constructor signature, adding required id parameter and converting positional args to named args.
    status: pending
  - id: update-approvingofficer-components
    content: Refactor ApprovingOfficer card components (ApprovedTripCard, PendingDestinationCard, PendingTripCard) to use new TextTheme getters and clean up null-check warnings.
    status: pending
  - id: update-driver-components
    content: Update Driver components (DestinationListCard, MaintenanceCard, TripCard, custom_time_picker) for new TextTheme, ThemeData APIs, and fix non-nullable local variable initialization issues.
    status: pending
  - id: fix-immutable-component-widgets
    content: Resolve must_be_immutable warnings by making _themeData fields final or removing @immutable where appropriate in table and title widgets.
    status: pending
  - id: refactor-form-builder-typeahead
    content: Refactor lib/components/form_builder_typehead.dart to match the current typeahead/autocomplete package API, removing references to removed classes and parameters.
    status: pending
  - id: cleanup-component-lints
    content: Remove unused imports, fields, and helpers in small components like title_and_widget_shadow.dart and config/dio.dart where trivial.
    status: pending
  - id: update-main-notifications-api
    content: Update lib/main.dart to use the current flutter_local_notifications API, including permission requests and show() signature changes with named id parameter.
    status: pending
  - id: update-approvingofficer-screens
    content: Apply TextTheme mapping and minor lints cleanup to ApprovingOfficer screens (ApprovedTripDoc, DestinationApproval, MTRAC* files, TripApproval, home, trip_approval_one).
    status: pending
  - id: update-driver-screens
    content: Apply TextTheme mapping, suggestion controller updates, and simple lint fixes to Driver screens (Maintenance, PerformanceCard, additionalDetail, bocElogForm, checkList, driverCheckList, elogBook, elogBookForm, frontPassenger, home, mt_broad_cast, mtrcForm, past_14_days_elog, quiz, riskAccessment, selectVehicle, trip, tripForm, tripPageView, vehicleCommander).
    status: pending
  - id: update-mac-screens
    content: Apply TextTheme mapping, suggestion controller updates, and small lint fixes to MAC screens (AVICheckInForm, CheckInForm, CheckOutForm, CorrectiveCheckInForm, Maintenance).
    status: pending
  - id: iterate-analyze
    content: Re-run flutter analyze after groups of changes and resolve any remaining or newly introduced issues until the report is clean.
    status: pending
isProject: false
---

# Plan to fix `flutter_analyze.md` issues file by file

## 1. Fix root configuration issue

- Open `[analysis_options.yaml](/Volumes/MyCrucial/mtfleet/mtfleet_flutter_new/analysis_options.yaml)`.
- Update the `include:` to a valid lint package that exists in your `pubspec.yaml` (for example `package:flutter_lints/flutter.yaml` if that dependency is present, or `package:lints/core.yaml` / `package:lints/recommended.yaml` depending on what you use).
- Ensure the referenced package is listed under `dev_dependencies` in `[pubspec.yaml](/Volumes/MyCrucial/mtfleet/mtfleet_flutter_new/pubspec.yaml)` and run `flutter pub get`.

## 2. Define a TextTheme migration strategy (used across many files)

Most errors are of the form `The getter 'bodyText1' isn't defined for the type 'TextTheme'` and similar for `bodyText2`, `subtitle1`, `subtitle2`, `headline2`–`headline6`. These are old names removed in newer Flutter versions.

- Use the official mapping:
  - `bodyText1` → `bodyLarge`
  - `bodyText2` → `bodyMedium`
  - `subtitle1` → `titleMedium`
  - `subtitle2` → `titleSmall`
  - `headline2` → `displayMedium`
  - `headline3` → `displaySmall`
  - `headline4` → `headlineMedium`
  - `headline5` → `headlineSmall`
  - `headline6` → `titleLarge`
- In all widgets where you access text styles via `Theme.of(context).textTheme`, replace the old getters with the new ones, keeping the style usage otherwise identical.
- Where semantics suggest a different weight (e.g. something is clearly a button label or a tiny caption), you can optionally adjust to `labelLarge`/`bodySmall`, but start with mechanical mapping to avoid regressions.

This strategy will be applied consistently in all the following files:

- `lib/components/ApprovingOfficer/*.dart`
- `lib/components/Driver/*.dart`
- `lib/components/MAC/*.dart`
- `lib/components/title_and_widget_shadow.dart`
- `lib/components/form_builder_typehead.dart` (specific widgets)
- `lib/screens/**` where `TextTheme` errors are reported.

## 3. Fix `AlertDialog.dart` usage of updated API

File: `[lib/components/AlertDialog.dart](/Volumes/MyCrucial/mtfleet/mtfleet_flutter_new/lib/components/AlertDialog.dart)`

Errors:
- "The named parameter 'id' is required, but there's no corresponding argument".
- "Too many positional arguments: 0 expected, but 1 found".

Planned fix:
- Locate the constructor call at/around line 70.
- Identify the updated signature of the widget or plugin being used (likely a notification or dialog class that now requires a named `id` parameter and uses only named parameters).
- Update the call site to:
  - Provide `id: someIntValue` (probably using an existing `id` or default like `0`).
  - Convert any positional arguments into named ones according to the new signature.

## 4. Fix global TextTheme usage in card and list components

Group 4.1: Approving officer cards

Files:
- `[lib/components/ApprovingOfficer/ApprovedTripCard.dart](/Volumes/MyCrucial/mtfleet/mtfleet_flutter_new/lib/components/ApprovingOfficer/ApprovedTripCard.dart)`
- `[lib/components/ApprovingOfficer/PendingDestinationCard.dart](/Volumes/MyCrucial/mtfleet/mtfleet_flutter_new/lib/components/ApprovingOfficer/PendingDestinationCard.dart)`
- `[lib/components/ApprovingOfficer/PendingTripCard.dart](/Volumes/MyCrucial/mtfleet/mtfleet_flutter_new/lib/components/ApprovingOfficer/PendingTripCard.dart)`

Planned fixes:
- For all reported lines, replace `textTheme.bodyText1` / `bodyText2` / `subtitle1` with new getters per mapping in section 2.
- In `PendingDestinationCard`, fix the `unnecessary_null_comparison` warning by removing `!= null` checks where the operand is non-nullable (e.g. `if (value != null)` for a non-nullable `value`).

Group 4.2: Driver cards and time picker

Files:
- `[lib/components/Driver/DestinationListCard.dart](/Volumes/MyCrucial/mtfleet/mtfleet_flutter_new/lib/components/Driver/DestinationListCard.dart)`
- `[lib/components/Driver/MaintenanceCard.dart](/Volumes/MyCrucial/mtfleet/mtfleet_flutter_new/lib/components/Driver/MaintenanceCard.dart)`
- `[lib/components/Driver/TripCard.dart](/Volumes/MyCrucial/mtfleet/mtfleet_flutter_new/lib/components/Driver/TripCard.dart)`
- `[lib/components/Driver/custom_time_picker.dart](/Volumes/MyCrucial/mtfleet/mtfleet_flutter_new/lib/components/Driver/custom_time_picker.dart)`

Planned fixes:
- Remove redundant imports: delete `import 'package:flutter/cupertino.dart';` where `material.dart` already covers all used symbols.
- Update all `TextTheme` getters as per mapping.
- For `custom_time_picker.dart`:
  - Replace `headline2`/`headline3` etc. with new names.
  - Replace `Theme.of(context).backgroundColor` with `Theme.of(context).colorScheme.background`.
  - Replace `primaryColorBrightness` with `Theme.of(context).colorScheme.brightness` or logic based on `Theme.of(context).brightness`.
  - Initialize `activeColor`/`inactiveColor` before use (e.g. set defaults at declaration or in all branches before they are used).
  - Replace deprecated `accentTextTheme` and `accentColor` with `colorScheme.secondary` and `colorScheme.onSecondary` or appropriate color fields.
  - For `textScaleFactor`, switch to `textScaler: TextScaler.linear(...)` where appropriate.
  - Leave `ButtonBar`, `dialogBackgroundColor` and other deprecated-but-still-compilable usages as-is for now (since they are infos), unless they block compilation.
  - Address `unused_element_parameter` and `unused_local_variable` warnings only if trivial (e.g. remove unused parameters/variables).

## 5. Make immutable classes truly immutable or relax annotation

Files:
- `[lib/components/Driver/past_14_elog/table_elog_BAP.dart](/Volumes/MyCrucial/mtfleet/mtfleet_flutter_new/lib/components/Driver/past_14_elog/table_elog_BAP.dart)`
- `[lib/components/Driver/past_14_elog/table_elog_one.dart](/Volumes/MyCrucial/mtfleet/mtfleet_flutter_new/lib/components/Driver/past_14_elog/table_elog_one.dart)`
- `[lib/components/title_and_widget_shadow.dart](/Volumes/MyCrucial/mtfleet/mtfleet_flutter_new/lib/components/title_and_widget_shadow.dart)`

Planned fixes:
- Either:
  - Make `_themeData` fields `final`, and ensure they are only set via the constructor, or
  - Remove the `@immutable` annotation if mutability is intentional.
- Also update `TextTheme` getters in these files.

## 6. Fix `form_builder_typehead.dart` for typeahead package changes

File: `[lib/components/form_builder_typehead.dart](/Volumes/MyCrucial/mtfleet/mtfleet_flutter_new/lib/components/form_builder_typehead.dart)`

Errors include undefined classes (`ItemBuilder`, `SuggestionsBoxDecoration`, `SuggestionsBoxController`, `ErrorBuilder`, `AnimationTransitionBuilder`, `TextFieldConfiguration`) and undefined named parameters such as `decoration`, `onSuggestionSelected`, `textFieldConfiguration`, etc.

Planned approach:
- Confirm which typeahead package you use in `pubspec.yaml` (likely `flutter_typeahead` v5+ or v6+).
- Open the current package docs and check the latest API for `TypeAheadField` / `RawAutocomplete` equivalents.
- Refactor this widget to use the current recommended API:
  - Replace outdated `TextFieldConfiguration` with a standard `TextField`/`TextFormField` builder.
  - Replace `SuggestionsBoxDecoration`/`SuggestionsBoxController` with the updated configuration on the new widget (or remove if no longer needed).
  - Replace outdated named parameters with their modern equivalents (e.g. `onSuggestionSelected`, `suggestionsCallback`, `itemBuilder`, `noItemsFoundBuilder`, `loadingBuilder`, etc., as defined by the package).
- Update any `AxisDirection` → `VerticalDirection` argument to pass `VerticalDirection` directly or adjust parameter usage.
- Update `TextTheme` getters to new names.

If the package mismatch is too large, an alternate plan is to:
- Drop the custom wrapper and replace it with inline usage of `flutter_typeahead` in each caller.

## 7. Clean up small component and config lints

Files:
- `[lib/components/title_and_widget_shadow.dart](/Volumes/MyCrucial/mtfleet/mtfleet_flutter_new/lib/components/title_and_widget_shadow.dart)`
- `[lib/config/dio.dart](/Volumes/MyCrucial/mtfleet/mtfleet_flutter_new/lib/config/dio.dart)`

Planned fixes:
- Remove unused imports like `package:transport_flutter/extensions/extensions.dart`.
- For unused fields like `_initDioMemoizer`, either remove them or wire them into actual memoization logic if you still need it.
- For unused private helper methods (`_buildInputTitle`) and unused optional parameters (`isShadow`), either use them or remove them to avoid warnings.

## 8. Update `main.dart` for new local notifications API

File: `[lib/main.dart](/Volumes/MyCrucial/mtfleet/mtfleet_flutter_new/lib/main.dart)`

Errors:
- `requestPermission` undefined on `AndroidFlutterLocalNotificationsPlugin`.
- Named parameter `onDidReceiveLocalNotification` is no longer defined.
- `id` now required for `show` or similar, plus extra positional arguments error.

Planned fixes:
- Check the version of `flutter_local_notifications` in `pubspec.yaml`.
- Update initialization code according to the plugin’s README for that version:
  - Use `resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission()` or the newer platform-level permission request as per the docs.
  - Remove `onDidReceiveLocalNotification` and follow the example for handling notification taps using `onDidReceiveNotificationResponse`/`onDidReceiveBackgroundNotificationResponse`.
- For `show(...)` calls, update to pass `id` as a named parameter and provide other parameters (`title`, `body`, `payload`) as required by the new signature. Replace positional argument usage with named arguments.

## 9. Fix screens using old TextTheme getters and minor lints (ApprovingOfficer)

Files (selection from errors):
- `[lib/screens/ApprovingOfficer/ApprovedTripDoc.dart](/Volumes/MyCrucial/mtfleet/mtfleet_flutter_new/lib/screens/ApprovingOfficer/ApprovedTripDoc.dart)`
- `[lib/screens/ApprovingOfficer/DestinationApproval.dart](/Volumes/MyCrucial/mtfleet/mtfleet_flutter_new/lib/screens/ApprovingOfficer/DestinationApproval.dart)`
- `[lib/screens/ApprovingOfficer/MTRACApprovalThree.dart](/Volumes/MyCrucial/mtfleet/mtfleet_flutter_new/lib/screens/ApprovingOfficer/MTRACApprovalThree.dart)`
- `[lib/screens/ApprovingOfficer/MTRACApprovalTwo.dart](/Volumes/MyCrucial/mtfleet/mtfleet_flutter_new/lib/screens/ApprovingOfficer/MTRACApprovalTwo.dart)`
- `[lib/screens/ApprovingOfficer/MTRACApprovedDoc.dart](/Volumes/MyCrucial/mtfleet/mtfleet_flutter_new/lib/screens/ApprovingOfficer/MTRACApprovedDoc.dart)`
- `[lib/screens/ApprovingOfficer/TripApproval.dart](/Volumes/MyCrucial/mtfleet/mtfleet_flutter_new/lib/screens/ApprovingOfficer/TripApproval.dart)`
- `[lib/screens/ApprovingOfficer/home.dart](/Volumes/MyCrucial/mtfleet/mtfleet_flutter_new/lib/screens/ApprovingOfficer/home.dart)`
- `[lib/screens/ApprovingOfficer/trip_approval_one.dart](/Volumes/MyCrucial/mtfleet/mtfleet_flutter_new/lib/screens/ApprovingOfficer/trip_approval_one.dart)`

Planned fixes:
- Remove unnecessary `cupertino.dart` and unused extension imports.
- Replace all `bodyText1`, `bodyText2`, `subtitle1`, `headline4`, `headline5`, `headline6` with the mapped new getters.
- Keep `MaterialStateProperty` in place even though deprecated, as these are info-level; consider migrating to `WidgetStateProperty` later if needed but not required for compilation.
- Remove unused fields like `_safetyKey` where safe.

## 10. Fix screens using old TextTheme getters and minor lints (Driver)

Files (subset):
- `[lib/screens/Driver/Maintenance.dart](/Volumes/MyCrucial/mtfleet/mtfleet_flutter_new/lib/screens/Driver/Maintenance.dart)`
- `[lib/screens/Driver/PerformanceCard.dart](/Volumes/MyCrucial/mtfleet/mtfleet_flutter_new/lib/screens/Driver/PerformanceCard.dart)`
- `[lib/screens/Driver/additionalDetail.dart](/Volumes/MyCrucial/mtfleet/mtfleet_flutter_new/lib/screens/Driver/additionalDetail.dart)`
- `[lib/screens/Driver/bocElogForm.dart](/Volumes/MyCrucial/mtfleet/mtfleet_flutter_new/lib/screens/Driver/bocElogForm.dart)`
- `[lib/screens/Driver/checkList.dart](/Volumes/MyCrucial/mtfleet/mtfleet_flutter_new/lib/screens/Driver/checkList.dart)`
- `[lib/screens/Driver/driverCheckList.dart](/Volumes/MyCrucial/mtfleet/mtfleet_flutter_new/lib/screens/Driver/driverCheckList.dart)`
- `[lib/screens/Driver/elogBook.dart](/Volumes/MyCrucial/mtfleet/mtfleet_flutter_new/lib/screens/Driver/elogBook.dart)`
- `[lib/screens/Driver/elogBookForm.dart](/Volumes/MyCrucial/mtfleet/mtfleet_flutter_new/lib/screens/Driver/elogBookForm.dart)`
- `[lib/screens/Driver/frontPassenger.dart](/Volumes/MyCrucial/mtfleet/mtfleet_flutter_new/lib/screens/Driver/frontPassenger.dart)`
- `[lib/screens/Driver/home.dart](/Volumes/MyCrucial/mtfleet/mtfleet_flutter_new/lib/screens/Driver/home.dart)`
- `[lib/screens/Driver/mt_broad_cast/page.dart](/Volumes/MyCrucial/mtfleet/mtfleet_flutter_new/lib/screens/Driver/mt_broad_cast/page.dart)`
- `[lib/screens/Driver/mtrcForm.dart](/Volumes/MyCrucial/mtfleet/mtfleet_flutter_new/lib/screens/Driver/mtrcForm.dart)`
- `[lib/screens/Driver/past_14_days_elog/page.dart](/Volumes/MyCrucial/mtfleet/mtfleet_flutter_new/lib/screens/Driver/past_14_days_elog/page.dart)`
- `[lib/screens/Driver/quiz.dart](/Volumes/MyCrucial/mtfleet/mtfleet_flutter_new/lib/screens/Driver/quiz.dart)`
- `[lib/screens/Driver/riskAccessment.dart](/Volumes/MyCrucial/mtfleet/mtfleet_flutter_new/lib/screens/Driver/riskAccessment.dart)`
- `[lib/screens/Driver/selectVehicle.dart](/Volumes/MyCrucial/mtfleet/mtfleet_flutter_new/lib/screens/Driver/selectVehicle.dart)`
- `[lib/screens/Driver/trip.dart](/Volumes/MyCrucial/mtfleet/mtfleet_flutter_new/lib/screens/Driver/trip.dart)`
- `[lib/screens/Driver/tripForm.dart](/Volumes/MyCrucial/mtfleet/mtfleet_flutter_new/lib/screens/Driver/tripForm.dart)`
- `[lib/screens/Driver/tripPageView.dart](/Volumes/MyCrucial/mtfleet/mtfleet_flutter_new/lib/screens/Driver/tripPageView.dart)`
- `[lib/screens/Driver/vehicleCommander.dart](/Volumes/MyCrucial/mtfleet/mtfleet_flutter_new/lib/screens/Driver/vehicleCommander.dart)`

Planned fixes:
- For each file, systematically:
  - Remove unnecessary `cupertino.dart` and unused extension imports.
  - Apply the TextTheme mapping to all usages.
  - For `DioError` deprecation, keep existing types (as infos) unless you want to migrate to `DioException` now; this is optional for compilation.
  - For `WillPopScope` deprecation, leave as-is for now since it’s info-level.
  - For `SuggestionsBoxController` errors in `mtrcForm.dart`, `selectVehicle.dart`, and `tripForm.dart`, update to the new typeahead API similarly to section 6 (or change to simple dropdowns/autocomplete if easier).
  - Fix any `unnecessary_null_comparison` warnings by removing null checks on non-nullable values.

## 11. Fix MAC screens (Check-in/out and maintenance) and suggestions controllers

Files:
- `[lib/screens/MAC/AVICheckInForm.dart](/Volumes/MyCrucial/mtfleet/mtfleet_flutter_new/lib/screens/MAC/AVICheckInForm.dart)`
- `[lib/screens/MAC/CheckInForm.dart](/Volumes/MyCrucial/mtfleet/mtfleet_flutter_new/lib/screens/MAC/CheckInForm.dart)`
- `[lib/screens/MAC/CheckOutForm.dart](/Volumes/MyCrucial/mtfleet/mtfleet_flutter_new/lib/screens/MAC/CheckOutForm.dart)`
- `[lib/screens/MAC/CorrectiveCheckInForm.dart](/Volumes/MyCrucial/mtfleet/mtfleet_flutter_new/lib/screens/MAC/CorrectiveCheckInForm.dart)`
- `[lib/screens/MAC/Maintenance.dart](/Volumes/MyCrucial/mtfleet/mtfleet_flutter_new/lib/screens/MAC/Maintenance.dart)`

Planned fixes:
- Remove unnecessary `cupertino.dart` imports.
- Apply TextTheme getter mapping.
- Update any `SuggestionsBoxController` usages to the new typeahead/autocomplete API as in section 6.
- Fix `body_might_complete_normally_nullable` by ensuring all execution paths in a `String?`-returning function return `String?` (add explicit `return null;` or fall-through default).
- Replace deprecated `required` from `meta` with the built-in `required` keyword in Dart 2.12+.

## 12. Re-run analysis iteratively and clean up remaining issues

After applying the above grouped fixes:

1. Run `flutter analyze` (or your script that generates `flutter_analyze.md`).
2. Update `flutter_analyze.md` to reflect the current state.
3. Address any remaining errors or new warnings, which might include:
   - Missed TextTheme calls.
   - Additional null-safety adjustments.
   - Straggling typeahead/notification API changes.

## 13. High-level flow diagram for the migration work

```mermaid
flowchart TD
  start["Start migration"] --> cfg["Fix analysis_options & lints package"]
  cfg --> themeStrategy["Define TextTheme mapping"]
  themeStrategy --> coreComponents["Update components TextTheme & imports"]
  coreComponents --> typeahead["Refactor form_builder_typehead & suggestion controllers"]
  typeahead --> notifications["Update main.dart notifications API"]
  notifications --> screensAO["Fix ApprovingOfficer screens"]
  screensAO --> screensDriver["Fix Driver screens"]
  screensDriver --> screensMAC["Fix MAC screens"]
  screensMAC --> analyze["Re-run flutter analyze & iterate"]
  analyze --> end["All analyze errors resolved"]
```

This plan ensures we fix issues file by file but reuses common strategies (TextTheme mapping, typeahead migration, notification API update) so the work is systematic rather than ad-hoc.