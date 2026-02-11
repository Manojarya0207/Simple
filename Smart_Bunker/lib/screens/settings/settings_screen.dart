import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/settings/app_settings.dart';
import '../../models/user/user_session.dart';
import '../../models/user/user_role.dart';
import '../../models/student/student_data.dart';
import '../../models/student/student_subjects_model.dart';
import '../../models/teacher/teacher_subjects_data.dart';
import '../../models/attendance/attendance_data.dart';

/// Settings screen for app configuration
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer2<AppSettings, UserSession>(
        builder: (
          BuildContext context,
          AppSettings appSettings,
          UserSession userSession,
          Widget? child,
        ) {
          return ListView(
            children: <Widget>[
              // App Section
              const _SectionHeader(title: 'Appearance'),
              ListTile(
                leading: const Icon(Icons.brightness_6),
                title: const Text('Theme Mode'),
                subtitle: Text(_getThemeModeText(appSettings.selectedThemeMode)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showThemeDialog(context, appSettings),
              ),
              const Divider(),

              // Notifications Section
              const _SectionHeader(title: 'Notifications'),
              SwitchListTile(
                secondary: const Icon(Icons.notifications),
                title: const Text('Daily Reminder'),
                subtitle: const Text('Get daily attendance reminders'),
                value: appSettings.dailyReminderEnabled,
                onChanged: (bool value) {
                  appSettings.dailyReminderEnabled = value;
                },
              ),
              const Divider(),

              // Data Management Section
              const _SectionHeader(title: 'Data Management'),
              ListTile(
                leading: const Icon(Icons.delete_sweep, color: Colors.orange),
                title: const Text('Clear All Data'),
                subtitle: const Text('Remove all stored data'),
                onTap: () => _showClearDataDialog(context),
              ),
              const Divider(),

              // About Section
              const _SectionHeader(title: 'About'),
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('App Version'),
                subtitle: const Text('1.0.0'),
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Share App'),
                onTap: () => _shareApp(context, appSettings),
              ),
              const Divider(),

              // Account Section
              const _SectionHeader(title: 'Account'),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Current Role'),
                subtitle: Text(_getRoleText(userSession.userRole)),
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () => _showLogoutDialog(context),
              ),
            ],
          );
        },
      ),
    );
  }

  String _getThemeModeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System Default';
    }
  }

  String _getRoleText(UserRole role) {
    switch (role) {
      case UserRole.student:
        return 'Student';
      case UserRole.teacher:
        return 'Teacher';
      case UserRole.unselected:
        return 'Not selected';
    }
  }

  void _showThemeDialog(BuildContext context, AppSettings appSettings) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Select Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            RadioListTile<ThemeMode>(
              title: const Text('Light'),
              value: ThemeMode.light,
              groupValue: appSettings.selectedThemeMode,
              onChanged: (ThemeMode? value) {
                if (value != null) {
                  appSettings.selectedThemeMode = value;
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Dark'),
              value: ThemeMode.dark,
              groupValue: appSettings.selectedThemeMode,
              onChanged: (ThemeMode? value) {
                if (value != null) {
                  appSettings.selectedThemeMode = value;
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('System Default'),
              value: ThemeMode.system,
              groupValue: appSettings.selectedThemeMode,
              onChanged: (ThemeMode? value) {
                if (value != null) {
                  appSettings.selectedThemeMode = value;
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will delete all students, subjects, and attendance records. This action cannot be undone.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Clear all data
              await context.read<StudentData>().clearAllStudents();
              await context.read<StudentSubjectsModel>().clearAllSubjects();
              await context.read<TeacherSubjectsData>().clearAllSubjects();
              await context.read<AttendanceData>().clearAllRecords();

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All data cleared')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<UserSession>().userRole = UserRole.unselected;
              Navigator.pop(context);
              Navigator.pop(context); // Go back to home
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _shareApp(BuildContext context, AppSettings appSettings) {
    // In a real app, you would use share_plus package
    final String message = appSettings.getShareMessageTextSpan().toPlainText();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

extension on TextSpan {
  String toPlainText() {
    final StringBuffer buffer = StringBuffer();
    visitChildren((InlineSpan span) {
      if (span is TextSpan) {
        buffer.write(span.text);
      }
      return true;
    });
    return buffer.toString();
  }
}