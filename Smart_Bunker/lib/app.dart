import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider_lib;
import 'models/settings/app_settings.dart';
import 'models/user/user_session.dart';
import 'models/teacher/teacher_subjects_data.dart';
import 'models/student/student_data.dart';
import 'models/user/current_student_profile.dart';
import 'models/student/student_subjects_model.dart';
import 'models/attendance/attendance_data.dart';
import 'screens/home/home_screen.dart';

/// The root widget of the application.
/// Sets up the MaterialApp and provides AppSettings and other shared models.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return provider_lib.ChangeNotifierProvider<AppSettings>(
      create: (BuildContext context) => AppSettings(),
      builder: (BuildContext providerContext, Widget? child) {
        return provider_lib.ChangeNotifierProvider<UserSession>(
          create: (BuildContext userSessionContext) => UserSession(),
          builder: (
            BuildContext userSessionProviderContext,
            Widget? userSessionChild,
          ) {
            return provider_lib.MultiProvider(
              providers: <provider_lib.ChangeNotifierProvider<ChangeNotifier>>[
                provider_lib.ChangeNotifierProvider<TeacherSubjectsData>(
                  create: (BuildContext multiProviderCreateContext) =>
                      TeacherSubjectsData(),
                ),
                provider_lib.ChangeNotifierProvider<StudentData>(
                  create: (BuildContext multiProviderCreateContext) =>
                      StudentData(),
                ),
                provider_lib.ChangeNotifierProvider<CurrentStudentProfile>(
                  create: (BuildContext multiProviderCreateContext) =>
                      CurrentStudentProfile(),
                ),
                provider_lib.ChangeNotifierProvider<StudentSubjectsModel>(
                  create: (BuildContext multiProviderCreateContext) =>
                      StudentSubjectsModel(),
                ),
                provider_lib.ChangeNotifierProvider<AttendanceData>(
                  create: (BuildContext multiProviderCreateContext) =>
                      AttendanceData(),
                ),
              ],
              builder: (
                BuildContext multiProviderBuilderContext,
                Widget? multiProviderBuilderChild,
              ) {
                return provider_lib.Consumer<AppSettings>(
                  builder: (
                    BuildContext appSettingsConsumerContext,
                    AppSettings appSettings,
                    Widget? appSettingsConsumerChild,
                  ) {
                    return MaterialApp(
                      debugShowCheckedModeBanner: false,
                      title: appSettings.appName,
                      theme: _buildLightTheme(),
                      darkTheme: _buildDarkTheme(),
                      themeMode: appSettings.selectedThemeMode,
                      home: const HomeScreen(),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      primarySwatch: Colors.blue,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: Colors.blue,
      ).copyWith(
        primary: Colors.blue.shade700,
        secondary: Colors.lightBlue.shade600,
        surface: Colors.white,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.black,
        error: Colors.red.shade700,
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      brightness: Brightness.light,
      cardColor: Colors.white,
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      primarySwatch: Colors.blue,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ).copyWith(
        primary: Colors.blue.shade400,
        secondary: Colors.lightBlue.shade300,
        surface: Colors.grey.shade900,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
        error: Colors.red.shade400,
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.grey.shade900,
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      brightness: Brightness.dark,
      cardColor: Colors.grey.shade800,
    );
  }
}