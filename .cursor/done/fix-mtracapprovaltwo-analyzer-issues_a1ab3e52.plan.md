---
name: fix-mtracapprovaltwo-analyzer-issues
overview: Group and plan fixes for Flutter analyzer issues in `lib/screens/ApprovingOfficer/MTRACApprovalTwo.dart` only.
todos:
  - id: cleanup-imports
    content: Remove unused `package:flutter/cupertino.dart` import from `MTRACApprovalTwo.dart`.
    status: completed
  - id: simplify-widget-tree
    content: Remove unnecessary `Container` widgets around `Flexible` children in `_buildChildren` while preserving layout.
    status: completed
  - id: update-button-style-api
    content: Replace deprecated `MaterialStateProperty` usage in the `OutlinedButton` `ButtonStyle` with the current recommended API, keeping appearance unchanged.
    status: completed
  - id: reanalyze-file
    content: Re-run `flutter analyze` and verify that all analyzer issues for `MTRACApprovalTwo.dart` are resolved with no regressions.
    status: completed
isProject: false
---

# Plan: Fix analyzer issues in `MTRACApprovalTwo`

## 1. Understand and group the issues

From [`flutter_analyze.md`](/Volumes/MyCrucial/mtfleet/mtfleet_flutter_new/flutter_analyze.md) for `lib/screens/ApprovingOfficer/MTRACApprovalTwo.dart` we have:
- Unnecessary import:
  - `package:flutter/cupertino.dart` is unused because everything used comes from `package:flutter/material.dart`.
- Unnecessary containers:
  - Row child at lines ~27 and ~38 wraps `Flexible` in a `Container` that does nothing.
- Deprecated API usage:
  - `MaterialStateProperty` used in `ButtonStyle` for the `OutlinedButton` at lines ~55–61.

Group these into categories:
- **Imports / dead code**: remove unused `cupertino.dart` import.
- **Widget tree cleanups**: remove unnecessary `Container` wrappers while preserving layout.
- **API modernization**: replace `MaterialStateProperty` with the recommended `WidgetStateProperty` (or the current best-practice equivalent for button style configuration) in the button style.

## 2. Plan concrete changes for this file

In [`lib/screens/ApprovingOfficer/MTRACApprovalTwo.dart`](/Volumes/MyCrucial/mtfleet/mtfleet_flutter_new/lib/screens/ApprovingOfficer/MTRACApprovalTwo.dart):

1. **Imports cleanup**
   - Remove the `cupertino.dart` import at the top if no `Cupertino` widgets/symbols are used in this file.

2. **Widget tree cleanups**
   - In `_buildChildren` list:
     - For the `Row` that renders `'Overall Risk:'`, replace:
       - `Row > Container > Flexible > Text` with `Row > Flexible > Text` or just `Row > Expanded > Text`, depending on desired behavior.
     - For the `Row` that renders the overall risk value, similarly remove the `Container` around `Flexible` and keep the `Flexible` or `Expanded` directly as a child of the `Row`.
   - Ensure that removing `Container` does not impact padding or alignment (there is no decoration, margin, or padding on the container now, so behavior should be unchanged).

3. **API modernization for button style**
   - Update the `OutlinedButton` `style` definition:
     - Replace `MaterialStateProperty.all(...)` invocations with the modern equivalent. For current Flutter versions, you can typically use `WidgetStateProperty.all(...)` or adjust to the recommended pattern in your codebase (for example, using `OutlinedButton.styleFrom(...)` when acceptable).
     - Concretely:
       - For `shape`, replace `MaterialStateProperty.all(RoundedRectangleBorder(...))` with the new property builder.
       - For `side`, replace `MaterialStateProperty.all(BorderSide(...))` similarly.
   - Keep the visual appearance identical (rounded rectangle, same radius and border color).

## 3. Validation steps (for this file only)

After making the above changes:
- Re-run `flutter analyze` (or your existing analyzer command) restricted to this package/project.
- Confirm that:
  - The `unnecessary_import` warning is gone for `MTRACApprovalTwo.dart`.
  - The `avoid_unnecessary_containers` warnings are resolved and no new layout warnings appear.
  - The `deprecated_member_use` warnings related to `MaterialStateProperty` no longer appear for this file.
- Do **not** modify other files; if new issues appear elsewhere, leave them for a separate pass.