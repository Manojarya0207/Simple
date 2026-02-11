import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/attendance/attendance_data.dart';

/// Widget to display attendance records in a calendar-like view
class AttendanceCalendar extends StatelessWidget {
  final List<AttendanceRecord> records;

  const AttendanceCalendar({
    super.key,
    required this.records,
  });

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return const SizedBox.shrink();
    }

    // Group records by month
    final Map<String, List<AttendanceRecord>> recordsByMonth =
        <String, List<AttendanceRecord>>{};

    for (final AttendanceRecord record in records) {
      final String monthKey = DateFormat('MMMM yyyy').format(record.date);
      recordsByMonth.putIfAbsent(monthKey, () => <AttendanceRecord>[]);
      recordsByMonth[monthKey]!.add(record);
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Monthly Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...recordsByMonth.entries.map((MapEntry<String, List<AttendanceRecord>> entry) {
              final int presentCount =
                  entry.value.where((AttendanceRecord r) => r.isPresent).length;
              final int totalCount = entry.value.length;
              final double percentage = (presentCount / totalCount) * 100;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          entry.key,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '$presentCount/$totalCount (${percentage.toStringAsFixed(0)}%)',
                          style: TextStyle(
                            fontSize: 14,
                            color: _getPercentageColor(percentage),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: presentCount / totalCount,
                      minHeight: 6,
                      backgroundColor: Colors.grey.shade300,
                      color: _getPercentageColor(percentage),
                    ),
                  ],
                ),
              );
            }),
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