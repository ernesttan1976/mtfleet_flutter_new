# Plan: Fix analyzer issues in `lib/models/trip_driver_model.dart`

Goals
- Use `??` operator instead of ternary null-checks.

Context
- `prefer_if_null_operators` at ~lines 50–52.

Steps
1. Replace ternary null patterns with `x ?? defaultValue` where safe.
2. Run `flutter analyze` and confirm issues resolved.
3. Run model-related tests or a quick runtime check if used in JSON parsing.
