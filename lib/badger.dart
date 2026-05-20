import 'package:flutter_app_badger/flutter_app_badger.dart';

class Badger {
  Badger._init();

  static final Badger _instance = Badger._init();

  factory Badger() => _instance;
  int _badgeCount = 0;

  int get badgeCount => _badgeCount;

  static void changeBadgeCount({int count = 1}) {
    _instance._badgeCount += count;
    if (_instance._badgeCount < 0) _instance._badgeCount = 0;
    FlutterAppBadger.updateBadgeCount(_instance._badgeCount);
  }
}
