import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user/current_student_profile.dart';
import '../../models/student/student_subjects_model.dart';
import '../../models/attendance/attendance_data.dart';
import '../../models/student/student.dart';
import '../../widgets/student/attendance_summary_card.dart';
import '../../widgets/student/subject_card.dart';
import 'student_profile_screen.dart';
import 'add_subject_screen.dart';
import 'subject_detail_screen.dart';
import '../settings/settings_screen.dart';

/// Student dashboard showing profile, subjects, and attendance summary
class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Dashboard'),
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
        ],
      ),
      body: Consumer3<CurrentStudentProfile, StudentSubjectsModel,
          AttendanceData>(
        builder: (
          BuildContext context,
          CurrentStudentProfile profileModel,
          StudentSubjectsModel subjectsModel,
          AttendanceData attendanceData,
          Widget? child,
        ) {
          final Student? profile = profileModel.profile;

          // If profile is not set, show profile creation prompt
          if (profile == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.person_add,
                      size: 80,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Create Your Profile',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Set up your profile to start tracking attendance',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) =>
                                const StudentProfileScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Create Profile'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // Get overall attendance stats
          final AttendanceStats stats =
              attendanceData.getOverallAttendanceStats(profile.registerNumber);

          return RefreshIndicator(
            onRefresh: () async {
              // Refresh data if needed
            },
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: <Widget>[
                // Profile Card
                Card(
                  elevation: 4,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (BuildContext context) =>
                              const StudentProfileScreen(),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: <Widget>[
                          CircleAvatar(
                            radius: 30,
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            child: Text(
                              profile.name.isNotEmpty
                                  ? profile.name[0].toUpperCase()
                                  : 'S',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  profile.name,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (profile.registerNumber.isNotEmpty)
                                  Text(
                                    'Reg No: ${profile.registerNumber}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Overall Attendance Summary
                AttendanceSummaryCard(stats: stats),
                const SizedBox(height: 24),

                // Subjects Section Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Text(
                      'My Subjects',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) =>
                                const AddSubjectScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add Subject'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Subjects List
                if (subjectsModel.subjects.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children: <Widget>[
                          Icon(
                            Icons.book_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No subjects added yet',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (BuildContext context) =>
                                      const AddSubjectScreen(),
                                ),
                              );
                            },
                            child: const Text('Add your first subject'),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...subjectsModel.subjects.map(
                    (subject) {
                      final AttendanceStats subjectStats =
                          attendanceData.getAttendanceStats(
                        profile.registerNumber,
                        subject.subjectCode,
                      );

                      return SubjectCard(
                        subject: subject,
                        stats: subjectStats,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (BuildContext context) =>
                                  SubjectDetailScreen(subject: subject),
                            ),
                          );
                        },
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}