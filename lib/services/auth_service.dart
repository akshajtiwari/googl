class AuthService {
  // Default admin credentials — change these in production
  static const String adminUsername = 'admin';
  static const String adminPassword = 'admin123';

  static bool isLoggedIn = false;

  // API keys stored in-memory for this demo
  static String? geminiApiKey;
  static String? googleApiKey;

  static Future<bool> login(String username, String password) async {
    // simple credential check (replace with secure auth in production)
    if (username == adminUsername && password == adminPassword) {
      isLoggedIn = true;
      return true;
    }
    return false;
  }

  static void logout() {
    isLoggedIn = false;
  }
}
