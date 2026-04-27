import 'package:flutter/material.dart';
import 'api_service.dart';

class AuthService extends ChangeNotifier {
  String? token;

  bool get loggedIn => token != null;

  Future<void> login(String username, String password) async {
    final data = await ApiService.login(username, password);
    token = data['access_token'] as String?;
    notifyListeners();
  }

  void logout() {
    token = null;
    notifyListeners();
  }
}
