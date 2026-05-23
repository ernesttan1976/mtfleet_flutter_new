# Plan: Fix analyzer issues in `lib/screens/video.dart`

Goals
- Remove unnecessary imports, add `key` parameters, prefer const constructors, replace deprecated `VideoPlayerController.network` usage, and simplify string interpolations.

Context
- `unnecessary_import` (`cupertino`), `depend_on_referenced_packages` (`video_player`), `use_key_in_widget_constructors`, `prefer_const_constructors_in_immutables`, `deprecated_member_use` (`VideoPlayerController.network`), `unnecessary_string_interpolations`.

Steps
1. Remove redundant `cupertino` import.
2. Ensure `video_player` is declared in `pubspec.yaml` if used; add it if missing.
3. Add `Key? key` to widget constructors and mark them `const` if appropriate.
4. Replace `VideoPlayerController.network(...)` with `VideoPlayerController.networkUrl(...)` per SDK guidance.
5. Simplify string interpolations where unnecessary.
6. Run `flutter analyze` and test video playback.
