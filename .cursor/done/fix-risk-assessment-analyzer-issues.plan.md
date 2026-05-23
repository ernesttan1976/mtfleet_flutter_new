# Plan: Fix analyzer issues in `lib/screens/Driver/riskAccessment.dart`

Goals
- Replace unnecessary containers with more appropriate widgets or remove them when redundant.

Context
- Multiple `avoid_unnecessary_containers` warnings.

Steps
1. Inspect each flagged `Container` and decide if it can be removed or replaced with `SizedBox`/`Padding`/`DecoratedBox` as required.
2. Run `flutter analyze` to confirm warnings are gone.
3. Visual test the risk assessment screens for layout regressions.
