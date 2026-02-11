import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/student/student_data.dart';
import '../../models/student/student.dart';
import '../../models/teacher/teacher_subjects_data.dart';
import '../../models/attendance/attendance_data.dart';

/// Screen for marking attendance for students
class MarkAttendanceScreen extends StatefulWidget {
  const MarkAttendanceScreen({super.key});

  @override
  State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  TeacherSubject? _selectedSubject;
  DateTime _selectedDate = DateTime.now();
  final Map<String, bool> _attendanceMap = <String, bool>{};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mark Attendance'),
      ),
      body: Consumer3<TeacherSubjectsData, StudentData, AttendanceData>(
        builder: (
          BuildContext context,
          TeacherSubjectsData subjectsData,
          StudentData studentData,
          AttendanceData attendanceData,
          Widget? child,
        ) {
          final List<TeacherSubject> subjects = subjectsData.subjects;
          final List<Student> students = studentData.students;

          if (subjects.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.book_outlined,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No subjects available',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  const Text('Please add subjects first'),
                ],
              ),
            );
          }

          if (students.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.people_outline,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No students available',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  const Text('Please add students first'),
                ],
              ),
            );
          }

          return Column(
            children: <Widget>[
              // Subject and Date Selection
              Container(
                padding: const EdgeInsets.all(16.0),
                color: Theme.of(context).colorScheme.surface,
                child: Column(
                  children: <Widget>[
                    // Subject Dropdown
                    DropdownButtonFormField<TeacherSubject>(
                      value: _selectedSubject,
                      decoration: const InputDecoration(
                        labelText: 'Select Subject',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.book),
                      ),
                      items: subjects.map((TeacherSubject subject) {
                        return DropdownMenuItem<TeacherSubject>(
                          value: subject,
                          child: Text(
                            '${subject.name} (${subject.subjectCode})',
                          ),
                        );
                      }).toList(),
                      onChanged: (TeacherSubject? value) {
                        setState(() {
                          _selectedSubject = value;
                          _attendanceMap.clear();
                          // Load existing attendance for selected date
                          if (_selectedSubject != null) {
                            _loadExistingAttendance(attendanceData, students);
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Date Selector
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          DateFormat('EEEE, MMMM d, y').format(_selectedDate),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Student List
              if (_selectedSubject != null)
                Expanded(
                  child: Column(
                    children: <Widget>[
                      // Quick Actions
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _markAllPresent(students),
                                icon: const Icon(Icons.check_circle_outline),
                                label: const Text('Mark All Present'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _markAllAbsent(students),
                                icon: const Icon(Icons.cancel_outlined),
                                label: const Text('Mark All Absent'),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Students List
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          itemCount: students.length,
                          itemBuilder: (BuildContext context, int index) {
                            final Student student = students[index];
                            final bool isPresent =
                                _attendanceMap[student.registerNumber] ?? true;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: CheckboxListTile(
                                secondary: CircleAvatar(
                                  backgroundColor: isPresent
                                      ? Colors.green
                                      : Colors.red,
                                  child: Text(
                                    student.name.isNotEmpty
                                        ? student.name[0].toUpperCase()
                                        : 'S',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  student.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  'Reg No: ${student.registerNumber}',
                                ),
                                value: isPresent,
                                activeColor: Colors.green,
                                onChanged: (bool? value) {
                                  setState(() {
                                    _attendanceMap[student.registerNumber] =
                                        value ?? true;
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

              // Save Button
              if (_selectedSubject != null)
                Container(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _saveAttendance(
                        context,
                        attendanceData,
                        students,
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Save Attendance',
                        style: TextStyle(fontSize: 16),
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

  void _loadExistingAttendance(
    AttendanceData attendanceData,
    List<Student> students,
  ) {
    if (_selectedSubject == null) return;

    final List<AttendanceRecord> existingRecords =
        attendanceData.getRecordsByDate(_selectedDate);

    for (final Student student in students) {
      final AttendanceRecord? record = existingRecords.firstWhere(
        (AttendanceRecord r) =>
            r.studentRegisterNumber == student.registerNumber &&
            r.subjectCode == _selectedSubject!.subjectCode,
        orElse: () => AttendanceRecord(
          studentName: '',
          studentRegisterNumber: '',
          subjectCode: '',
          subjectName: '',
          date: DateTime.now(),
          isPresent: true,
        ),
      );

      if (record.studentRegisterNumber.isNotEmpty) {
        _attendanceMap[student.registerNumber] = record.isPresent;
      } else {
        _attendanceMap[student.registerNumber] = true; // Default to present
      }
    }
  }

  void _markAllPresent(List<Student> students) {
    setState(() {
      for (final Student student in students) {
        _attendanceMap[student.registerNumber] = true;
      }
    });
  }

  void _markAllAbsent(List<Student> students) {
    setState(() {
      for (final Student student in students) {
        _attendanceMap[student.registerNumber] = false;
      }
    });
  }

  void _saveAttendance(
    BuildContext context,
    AttendanceData attendanceData,
    List<Student> students,
  ) {
    if (_selectedSubject == null) return;

    for (final Student student in students) {
      final bool isPresent = _attendanceMap[student.registerNumber] ?? true;

      attendanceData.markAttendance(
        studentName: student.name,
        studentRegisterNumber: student.registerNumber,
        subjectCode: _selectedSubject!.subjectCode,
        subjectName: _selectedSubject!.name,
        date: _selectedDate,
        isPresent: isPresent,
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Attendance saved successfully')),
    );

    Navigator.pop(context);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        if (_selectedSubject != null) {
          _loadExistingAttendance(
            context.read<AttendanceData>(),
            context.read<StudentData>().students,
          );
        }
      });
    }
  }
}