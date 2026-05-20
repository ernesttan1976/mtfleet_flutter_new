import 'package:notification_badge_plus/notification_badge_plus.dart';

class Badger {
  Badger._init();

  static final Badger _instance = Badger._init();

  factory Badger() => _instance;
  int _badgeCount = 0;

  int get badgeCount => _badgeCount;

  static Future<void> changeBadgeCount({int count = 1}) async {
    _instance._badgeCount += count;
    if (_instance._badgeCount < 0) _instance._badgeCount = 0;
    await NotificationBadgePlus.setBadgeCount(_instance._badgeCount);
  }
}
