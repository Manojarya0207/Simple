import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'student.dart';

/// Data model for managing students for a teacher.
/// This data persists using SharedPreferences.
class StudentData extends ChangeNotifier {
  List<Student> _students;

  late SharedPreferences _prefs;
  static const String _studentsKey = 'studentList';

  StudentData({List<Student>? initialStudents})
      : _students = initialStudents ?? <Student>[] {
    _initPrefsAndLoadData();
  }

  Future<void> _initPrefsAndLoadData() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadStudents();
    if (_students.isEmpty) {
      _students.addAll(<Student>[]);
      await _saveStudents();
    }
    notifyListeners();
  }

  List<Student> get students => List<Student>.unmodifiable(_students);

  void addStudent(String name, String registerNumber) {
    final String trimmedName = name.trim();
    final String trimmedRegNum = registerNumber.trim();
    if (trimmedName.isNotEmpty) {
      final Student newStudent = Student(
        name: trimmedName,
        registerNumber: trimmedRegNum,
      );
      if (!_students.any(
        (Student s) =>
            s.name == newStudent.name &&
            s.registerNumber == newStudent.registerNumber,
      )) {
        _students.add(newStudent);
        _sortStudents();
        _saveStudents();
        notifyListeners();
      } else {
        debugPrint(
          'Student "$trimmedName" with register number "$trimmedRegNum" already exists.',
        );
      }
    }
  }

  void removeStudent(Student student) {
    if (_students.remove(student)) {
      _saveStudents();
      notifyListeners();
    }
  }

  Future<void> _saveStudents() async {
    final List<Map<String, dynamic>> studentsJson = _students
        .map<Map<String, dynamic>>((Student s) => s.toJson())
        .toList();
    await _prefs.setString(_studentsKey, jsonEncode(studentsJson));
  }

  Future<void> _loadStudents() async {
    final String? studentsString = _prefs.getString(_studentsKey);
    if (studentsString != null) {
      try {
        final List<dynamic> studentsJson =
            jsonDecode(studentsString) as List<dynamic>;
        _students = studentsJson
            .map<Student>(
              (dynamic item) => Student.fromJson(item as Map<String, dynamic>),
            )
            .toList();
        _sortStudents();
      } catch (e) {
        debugPrint('Error loading students: $e. Clearing corrupted data.');
        _students.clear();
      }
    }
  }

  void _sortStudents() {
    _students.sort((Student a, Student b) {
      final bool aHasRegNum = a.registerNumber.isNotEmpty;
      final bool bHasRegNum = b.registerNumber.isNotEmpty;

      if (!aHasRegNum && !bHasRegNum) {
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      }
      if (!aHasRegNum) return 1;
      if (!bHasRegNum) return -1;

      final int? aNum = int.tryParse(a.registerNumber);
      final int? bNum = int.tryParse(b.registerNumber);

      if (aNum != null && bNum != null) {
        return aNum.compareTo(bNum);
      } else if (aNum != null) {
        return -1;
      } else if (bNum != null) {
        return 1;
      } else {
        return a.registerNumber
            .toLowerCase()
            .compareTo(b.registerNumber.toLowerCase());
      }
    });
  }
}