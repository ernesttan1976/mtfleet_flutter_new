---
name: fix-flutter-analyze
description: Automates a tight loop for fixing Flutter `flutter analyze` errors: run analysis, focus on the first repeated error type in a single file, plan and apply minimal fixes, re-run analysis to confirm, commit successful fixes with meaningful messages, and repeat. Use when working in the `mtfleet_flutter_new` Flutter app and the user asks to fix or reduce `flutter analyze` errors.
disable-model-invocation: true
---

# fix_flutter_analyze

## Instructions

Follow this workflow to iteratively reduce `flutter analyze` errors in the `mtfleet_flutter_new` project.

### Preconditions
- You are operating in the `mtfleet_flutter_new` Flutter project directory.
- Respect the user's Composer-style editing rules: read-before-edit, minimal targeted changes, and run linters on edited files only.

### Main Loop

Repeat this loop until the user stops you or no actionable errors remain.

#### Step 1 – Run `flutter analyze`
1. Run Flutter analyze from the project root:
   - `cd /Volumes/MyCrucial/mtfleet/mtfleet_flutter_new`
   - `flutter analyze > flutter_analyze.md`
2. If the command fails for non-analysis reasons (e.g., missing SDK, build issues), stop and ask the user for guidance.

#### Step 2 – Identify the first repeated error type in one file
1. Open `flutter_analyze.md` max 20 lines and parse from the top.
2. Find the first error type and file combination that appears **more than once** near the top of the report, for example:
   - Same error code (e.g., `avoid_print`, `unused_import`, `invalid_assignment`, etc.)
   - Same Dart file path.
3. Limit scope:
   - Focus only on that one error type in that one file for this iteration.
   - Ignore other files and error types until the next loop iteration.

#### Step 3 – Create and get approval for a fix plan
1. Read the target Dart file completely (or at least the relevant regions) before editing.
2. For the chosen error type in that file, collect the first few occurrences (e.g., 3–10 instances, depending on complexity).
3. Draft a short, concrete plan of **minimal** code changes that would resolve those occurrences. For example:
   - `unused_import` → remove the unused import.
   - `avoid_print` → replace `print` with a proper logger or remove debug logging, based on project conventions.
   - `dead_code` → remove or refactor unreachable code.
   - `invalid_assignment` / `type` errors → adjust types, nullability, or control flow with minimal change.
4. Write this plan into a markdown file at the project root (e.g. `flutter_analyze_plan.md`), clearly listing the file, error type, and the specific minimal changes you intend to make.
5. Present the contents of `flutter_analyze_plan.md` to the user and explicitly ask them to approve, request changes, or reject the plan.
6. Only proceed to the next step after the user has approved the plan. If the plan is ambiguous, risky, or the user requests adjustments, update the plan in `flutter_analyze_plan.md` and re-seek approval.
7. Ensure the final approved plan does **not** change runtime behavior beyond what is required to fix the error, unless clearly safe and agreed with the user.

#### Step 4 – Apply the fixes
1. Implement the user-approved changes as minimal, targeted edits in the chosen Dart file.
2. Avoid broad refactors or style-only changes that are unrelated to the targeted error.
3. After editing, run any relevant format/lint commands for that file if available (e.g., `dart format <file>`), or rely on project conventions.

#### Step 5 – Re-run `flutter analyze`
1. Run `flutter analyze > flutter_analyze.md` again from the project root.
2. Check whether the previously targeted error type in that file has disappeared:
   - If all of those specific errors are gone → treat this iteration as a **success**.
   - If some of them persist or new related errors appear → stop and show the updated analysis to the user, explaining what remains and why you are stopping.

#### Step 6 – Commit successful fixes
1. If the targeted error cluster is fully resolved and the user has not disabled committing, create a Git commit containing only the relevant changes.
2. Commit message guidelines:
   - Mention Flutter analyze and the error type/file.
   - Example messages:
     - `fix: resolve flutter analyze unused_import in custom_time_picker.dart`
     - `fix: address flutter analyze type errors in PendingDestinationCard`
3. Do **not** include unrelated files or changes in this commit.
4. Do not push to remote unless the user explicitly requests it.

#### Step 7 – Repeat
1. After a successful commit, return to **Step 1** and rerun `flutter analyze`.
2. Continue iterating until:
   - The user asks you to stop, or
   - Remaining errors are ambiguous / risky to fix automatically.

## Notes and Constraints
- Always obey the read-before-edit rule and summarize observed code before editing.
- Prefer small, easy-to-review commits (one error-type-per-file per commit when possible).
- If `flutter_analyze.md` is very large, you may process just the top portion first, then expand as needed.
- If you encounter a non-deterministic or environment-specific error, stop and ask the user for context instead of guessing.

## Example Session Flow

1. Run `flutter analyze > flutter_analyze.md`.
2. Identify repeated `unused_import` errors in `lib/components/Driver/custom_time_picker.dart`.
3. Draft `flutter_analyze_plan.md` describing the specific unused imports to remove from that file and get user approval.
4. Edit `custom_time_picker.dart` to remove those imports and format the file if needed.
5. Re-run `flutter analyze` and confirm those `unused_import` errors are gone.
6. Commit with a message like:
   - `fix: clean up unused imports in custom_time_picker.dart`
7. Repeat from step 1 for the next error cluster.
