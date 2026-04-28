import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  String? token;

  bool get loggedIn => token != null;
  void logout() {
    token = null;
    notifyListeners();
  }
}
