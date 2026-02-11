import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Data model for application-wide settings.
/// Includes persistence for notification settings and theme.
class AppSettings extends ChangeNotifier {
  ThemeMode _selectedThemeMode;
  final String _appName;
  bool _dailyReminderEnabled;
  DateTime? _lastReminderDate;

  late SharedPreferences _prefs;
  static const String _dailyReminderEnabledKey = 'dailyReminderEnabled';
  static const String _lastReminderDateKey = 'lastReminderDate';
  static const String _selectedThemeModeKey = 'selectedThemeMode';

  AppSettings({
    ThemeMode selectedThemeMode = ThemeMode.light,
    String appName = 'Smart Bunker',
    bool dailyReminderEnabled = true,
    DateTime? lastReminderDate,
  })  : _selectedThemeMode = selectedThemeMode,
        _appName = appName,
        _dailyReminderEnabled = dailyReminderEnabled,
        _lastReminderDate = lastReminderDate {
    _initPrefsAndLoadData();
  }

  ThemeMode get selectedThemeMode => _selectedThemeMode;
  String get appName => _appName;
  bool get dailyReminderEnabled => _dailyReminderEnabled;
  DateTime? get lastReminderDate => _lastReminderDate;

  set selectedThemeMode(ThemeMode newValue) {
    if (_selectedThemeMode != newValue) {
      _selectedThemeMode = newValue;
      _savePrefs();
      notifyListeners();
    }
  }

  set dailyReminderEnabled(bool newValue) {
    if (_dailyReminderEnabled != newValue) {
      _dailyReminderEnabled = newValue;
      _savePrefs();
      notifyListeners();
    }
  }

  set lastReminderDate(DateTime? newValue) {
    if (_lastReminderDate != newValue) {
      _lastReminderDate = newValue;
      _savePrefs();
      notifyListeners();
    }
  }

  Future<void> _initPrefsAndLoadData() async {
    _prefs = await SharedPreferences.getInstance();
    _dailyReminderEnabled = _prefs.getBool(_dailyReminderEnabledKey) ?? true;
    final String? lastReminderDateString = _prefs.getString(
      _lastReminderDateKey,
    );
    if (lastReminderDateString != null) {
      _lastReminderDate = DateTime.tryParse(lastReminderDateString);
    }
    final String? themeModeString = _prefs.getString(_selectedThemeModeKey);
    _selectedThemeMode = ThemeMode.values.firstWhere(
      (ThemeMode e) => e.name == themeModeString,
      orElse: () => ThemeMode.light,
    );
    notifyListeners();
  }

  Future<void> _savePrefs() async {
    await _prefs.setBool(_dailyReminderEnabledKey, _dailyReminderEnabled);
    if (_lastReminderDate != null) {
      await _prefs.setString(
        _lastReminderDateKey,
        _lastReminderDate!.toIso8601String(),
      );
    } else {
      await _prefs.remove(_lastReminderDateKey);
    }
    await _prefs.setString(_selectedThemeModeKey, _selectedThemeMode.name);
  }

  /// Provides the formatted TextSpan for sharing the app information.
  TextSpan getShareMessageTextSpan() {
    return TextSpan(
      children: <TextSpan>[
        const TextSpan(text: 'Check out '),
        TextSpan(
          text: _appName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const TextSpan(
          text:
              ' – your ultimate attendance management app! Download it today!',
        ),
      ],
    );
  }
}