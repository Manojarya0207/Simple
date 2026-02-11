import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_role.dart';

/// Manages user session (specifically, the selected role).
/// Persists the selected role using SharedPreferences.
class UserSession extends ChangeNotifier {
  UserRole _userRole;

  late SharedPreferences _prefs;
  static const String _userRoleKey = 'userRole';

  UserSession({UserRole userRole = UserRole.unselected})
      : _userRole = userRole {
    _initPrefsAndLoadData();
  }

  Future<void> _initPrefsAndLoadData() async {
    _prefs = await SharedPreferences.getInstance();
    final String? roleString = _prefs.getString(_userRoleKey);
    _userRole = UserRole.values.firstWhere(
      (UserRole e) => e.name == roleString,
      orElse: () => UserRole.unselected,
    );
    notifyListeners();
  }

  bool get isLoggedIn => _userRole != UserRole.unselected;
  UserRole get userRole => _userRole;

  set userRole(UserRole newValue) {
    if (_userRole != newValue) {
      _userRole = newValue;
      _saveState();
      notifyListeners();
    }
  }

  Future<void> _saveState() async {
    await _prefs.setString(_userRoleKey, _userRole.name);
  }
}