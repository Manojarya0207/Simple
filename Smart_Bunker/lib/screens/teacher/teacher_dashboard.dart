import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/teacher/teacher_subjects_data.dart';
import '../../models/student/student_data.dart';
import '../../models/user/user_session.dart';
import '../../models/user/user_role.dart';
import 'manage_students_screen.dart';
import 'manage_subjects_screen.dart';
import 'mark_attendance_screen.dart';
import '../settings/settings_screen.dart';

/// Teacher dashboard with main functionality access
class TeacherDashboard extends StatelessWidget {
  const TeacherDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Dashboard'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => const SettingsScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: Consumer2<TeacherSubjectsData, StudentData>(
        builder: (
          BuildContext context,
          TeacherSubjectsData subjectsData,
          StudentData studentData,
          Widget? child,
        ) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: <Widget>[
              // Welcome Card
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          CircleAvatar(
                            radius: 30,
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            child: const Icon(
                              Icons.person,
                              size: 35,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'Welcome Back!',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Manage your classes efficiently',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Statistics Cards
              Row(
                children: <Widget>[
                  Expanded(
                    child: _StatCard(
                      title: 'Subjects',
                      count: subjectsData.subjects.length,
                      icon: Icons.book,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatCard(
                      title: 'Students',
                      count: studentData.students.length,
                      icon: Icons.people,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Quick Actions
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              _ActionCard(
                title: 'Mark Attendance',
                subtitle: 'Record student attendance for today',
                icon: Icons.check_circle_outline,
                color: Colors.orange,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) =>
                          const MarkAttendanceScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),

              _ActionCard(
                title: 'Manage Students',
                subtitle: 'Add, edit, or remove students',
                icon: Icons.people_outline,
                color: Colors.green,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) =>
                          const ManageStudentsScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),

              _ActionCard(
                title: 'Manage Subjects',
                subtitle: 'Add, edit, or remove subjects',
                icon: Icons.book_outlined,
                color: Colors.blue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) =>
                          const ManageSubjectsScreen(),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      context.read<UserSession>().userRole = UserRole.unselected;
    }
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: color),
            ],
          ),
        ),
      ),
    );
  }
}