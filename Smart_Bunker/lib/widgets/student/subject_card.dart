import 'package:flutter/material.dart';
import '../../models/student/student_subject.dart';
import '../../models/attendance/attendance_data.dart';

/// Widget to display a subject card with attendance info
class SubjectCard extends StatelessWidget {
  final StudentSubject subject;
  final AttendanceStats stats;
  final VoidCallback onTap;

  const SubjectCard({
    super.key,
    required this.subject,
    required this.stats,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color percentageColor = _getPercentageColor(stats.attendancePercentage);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          subject.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subject.subjectCode,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: percentageColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${stats.attendancePercentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: percentageColor,
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
                minHeight: 6,
                backgroundColor: Colors.grey.shade300,
                color: percentageColor,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    '${stats.attendedClasses}/${stats.totalClasses} classes',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
            ],
          ),
        ),
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