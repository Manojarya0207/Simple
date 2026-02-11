import 'package:flutter/material.dart';
import '../../models/attendance/attendance_data.dart';

/// Widget to display overall attendance summary
class AttendanceSummaryCard extends StatelessWidget {
  final AttendanceStats stats;

  const AttendanceSummaryCard({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final Color percentageColor = _getPercentageColor(stats.attendancePercentage);

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Overall Attendance',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: SizedBox(
                width: 140,
                height: 140,
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    CircularProgressIndicator(
                      value: stats.totalClasses > 0
                          ? stats.attendedClasses / stats.totalClasses
                          : 0,
                      strokeWidth: 12,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(percentageColor),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            '${stats.attendancePercentage.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: percentageColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${stats.attendedClasses}/${stats.totalClasses}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _StatItem(
                  label: 'Present',
                  value: stats.attendedClasses.toString(),
                  color: Colors.green,
                  icon: Icons.check_circle,
                ),
                _StatItem(
                  label: 'Absent',
                  value: stats.absentClasses.toString(),
                  color: Colors.red,
                  icon: Icons.cancel,
                ),
                _StatItem(
                  label: 'Total',
                  value: stats.totalClasses.toString(),
                  color: Colors.blue,
                  icon: Icons.calendar_today,
                ),
              ],
            ),
          ],
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

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}