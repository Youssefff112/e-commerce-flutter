import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  String? _currentUserEmail;
  String? _currentUserId;

  bool get isLoggedIn => _currentUserEmail != null;
  String? get currentUserEmail => _currentUserEmail;
  String? get currentUserId => _currentUserId;

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUserEmail = prefs.getString('user_email');
    _currentUserId = prefs.getString('user_id');
  }

  Future<bool> register(String email, String password) async {
    // Simple validation
    if (email.isEmpty || password.isEmpty || password.length < 6) {
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    final users = prefs.getStringList('registered_users') ?? [];

    // Check if user exists
    if (users.contains(email)) {
      return false;
    }

    // Register user
    users.add(email);
    await prefs.setStringList('registered_users', users);
    await prefs.setString('user_${email}_password', password);

    // Auto login
    _currentUserEmail = email;
    _currentUserId = DateTime.now().millisecondsSinceEpoch.toString();
    await prefs.setString('user_email', email);
    await prefs.setString('user_id', _currentUserId!);

    return true;
  }

  Future<bool> login(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final users = prefs.getStringList('registered_users') ?? [];

    if (!users.contains(email)) {
      return false;
    }

    final savedPassword = prefs.getString('user_${email}_password');
    if (savedPassword != password) {
      return false;
    }

    _currentUserEmail = email;
    _currentUserId = DateTime.now().millisecondsSinceEpoch.toString();
    await prefs.setString('user_email', email);
    await prefs.setString('user_id', _currentUserId!);

    return true;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_email');
    await prefs.remove('user_id');
    _currentUserEmail = null;
    _currentUserId = null;
  }
}
