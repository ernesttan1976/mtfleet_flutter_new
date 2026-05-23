# Plan: Fix analyzer issues in `lib/screens/loginWebView.dart`

Goals
- Fix `depend_on_referenced_packages` warnings and unnecessary imports.

Context
- Imported packages `webview_flutter_android` and `webview_flutter_platform_interface` flagged as not being direct dependencies; `unnecessary_import` for platform_interface.

Steps
1. Check `pubspec.yaml` for required platform packages; add them as dependencies if the file uses them directly.
2. Remove `package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart` if `webview_flutter` already covers used symbols.
3. Run `flutter pub get` and `flutter analyze` to ensure dependencies and imports align.
4. Test the login webview on the target platforms.
