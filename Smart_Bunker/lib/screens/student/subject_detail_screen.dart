import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/student/student_subject.dart';
import '../../models/attendance/attendance_data.dart';
import '../../models/user/current_student_profile.dart';
import '../../widgets/student/attendance_calendar.dart';

/// Screen showing detailed attendance for a specific subject
class SubjectDetailScreen extends StatelessWidget {
  final StudentSubject subject;

  const SubjectDetailScreen({
    super.key,
    required this.subject,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(subject.name),
      ),
      body: Consumer2<AttendanceData, CurrentStudentProfile>(
        builder: (
          BuildContext context,
          AttendanceData attendanceData,
          CurrentStudentProfile profileModel,
          Widget? child,
        ) {
          final String registerNumber =
              profileModel.profile?.registerNumber ?? '';

          if (registerNumber.isEmpty) {
            return const Center(
              child: Text('Profile not found'),
            );
          }

          final AttendanceStats stats = attendanceData.getAttendanceStats(
            registerNumber,
            subject.subjectCode,
          );

          final List<AttendanceRecord> records = attendanceData
              .getSubjectRecords(subject.subjectCode)
              .where((AttendanceRecord r) =>
                  r.studentRegisterNumber == registerNumber)
              .toList();

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: <Widget>[
              // Subject Info Card
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        subject.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Code: ${subject.subjectCode}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Attendance Statistics Card
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'Attendance Statistics',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildStatRow(
                        'Total Classes',
                        stats.totalClasses.toString(),
                        Icons.calendar_today,
                      ),
                      _buildStatRow(
                        'Classes Attended',
                        stats.attendedClasses.toString(),
                        Icons.check_circle,
                        color: Colors.green,
                      ),
                      _buildStatRow(
                        'Classes Missed',
                        stats.absentClasses.toString(),
                        Icons.cancel,
                        color: Colors.red,
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          const Text(
                            'Attendance Percentage',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${stats.attendancePercentage.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: _getPercentageColor(
                                stats.attendancePercentage,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: stats.totalClasses > 0
                            ? stats.attendedClasses / stats.totalClasses
                            : 0,
                        minHeight: 8,
                        backgroundColor: Colors.grey.shade300,
                        color: _getPercentageColor(stats.attendancePercentage),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Attendance Calendar
              AttendanceCalendar(
                records: records,
              ),
              const SizedBox(height: 16),

              // Attendance History Header
              const Text(
                'Attendance History',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Attendance Records List
              if (records.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: <Widget>[
                        Icon(
                          Icons.history,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No attendance records yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...records.map(
                  (AttendanceRecord record) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: record.isPresent
                            ? Colors.green.shade100
                            : Colors.red.shade100,
                        child: Icon(
                          record.isPresent
                              ? Icons.check
                              : Icons.close,
                          color: record.isPresent
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                        ),
                      ),
                      title: Text(
                        DateFormat('EEEE, MMMM d, y').format(record.date),
                      ),
                      subtitle: record.remarks != null
                          ? Text(record.remarks!)
                          : null,
                      trailing: Text(
                        record.isPresent ? 'Present' : 'Absent',
                        style: TextStyle(
                          color: record.isPresent
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon,
      {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, size: 20, color: color ?? Colors.grey.shade700),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getPercentageColor(double percentage) {
    if (percentage >= 75) {
      return Colors.green;
    } else if (percentage >= 60) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}