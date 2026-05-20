import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const SUPPORTED_ROLES = [
  "MAC",
  "APPROVING_OFFICER",
  "PRE_APPROVED_DRIVER",
  "DRIVER"
];

final storage = FlutterSecureStorage();

dynamic getUser() async {
  var auth = await storage.read(key: "auth");
  return auth;
}

dynamic getCurrentRole() async {
  var role = await storage.read(key: "currentRole");
  return role;
}
