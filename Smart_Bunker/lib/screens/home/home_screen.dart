import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user/user_session.dart';
import '../../models/user/user_role.dart';
import '../../models/settings/app_settings.dart';
import '../student/student_dashboard.dart';
import '../teacher/teacher_dashboard.dart';
import '../role_selection/role_selection_screen.dart';

/// Home screen that routes to appropriate dashboard based on user role
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserSession>(
      builder: (BuildContext context, UserSession userSession, Widget? child) {
        // If user hasn't selected a role, show role selection screen
        if (userSession.userRole == UserRole.unselected) {
          return const RoleSelectionScreen();
        }

        // Route to appropriate dashboard based on role
        switch (userSession.userRole) {
          case UserRole.student:
            return const StudentDashboard();
          case UserRole.teacher:
            return const TeacherDashboard();
          default:
            return const RoleSelectionScreen();
        }
      },
    );
  }
}