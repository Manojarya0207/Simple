import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../student/student.dart';

/// Manages the single student profile for the current app user
/// when they are in 'student' role.
class CurrentStudentProfile extends ChangeNotifier {
  Student? _profile;

  late SharedPreferences _prefs;
  static const String _profileKey = 'currentStudentProfile';

  CurrentStudentProfile({Student? initialProfile}) : _profile = initialProfile {
    _initPrefsAndLoadData();
  }

  Future<void> _initPrefsAndLoadData() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadProfile();
    notifyListeners();
  }

  Student? get profile => _profile;

  Future<void> setProfile(Student? newProfile) async {
    if (_profile != newProfile) {
      _profile = newProfile;
      await _saveProfile();
      notifyListeners();
    }
  }

  Future<void> clearProfile() async {
    _profile = null;
    await _prefs.remove(_profileKey);
    notifyListeners();
  }

  Future<void> _saveProfile() async {
    if (_profile != null) {
      await _prefs.setString(_profileKey, jsonEncode(_profile!.toJson()));
    } else {
      await _prefs.remove(_profileKey);
    }
  }

  Future<void> _loadProfile() async {
    final String? profileString = _prefs.getString(_profileKey);
    if (profileString != null && profileString.isNotEmpty) {
      try {
        _profile = Student.fromJson(
          jsonDecode(profileString) as Map<String, dynamic>,
        );
      } catch (e) {
        debugPrint(
          'Error loading student profile: $e. Clearing corrupted data.',
        );
        _profile = null;
        await _prefs.remove(_profileKey);
      }
    } else {
      _profile = null;
    }
  }
}