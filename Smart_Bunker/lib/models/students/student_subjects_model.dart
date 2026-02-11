import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'student_subject.dart';

/// Data model for managing subjects for a student.
/// This model uses SharedPreferences for persistence.
class StudentSubjectsModel extends ChangeNotifier {
  List<StudentSubject> _subjects;

  late SharedPreferences _prefs;
  static const String _subjectsKey = 'studentSubjects';

  StudentSubjectsModel({List<StudentSubject>? initialSubjects})
      : _subjects = initialSubjects ?? <StudentSubject>[] {
    _initPrefsAndLoadData();
  }

  Future<void> _initPrefsAndLoadData() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadSubjects();
    if (_subjects.isEmpty) {
      _subjects.addAll(<StudentSubject>[]);
      await _saveSubjects();
    }
    notifyListeners();
  }

  List<StudentSubject> get subjects =>
      List<StudentSubject>.unmodifiable(_subjects);

  void addSubject(String name, String subjectCode) {
    final String trimmedName = name.trim();
    final String trimmedCode = subjectCode.trim();

    if (trimmedName.isNotEmpty && trimmedCode.isNotEmpty) {
      final StudentSubject newSubject = StudentSubject(
        name: trimmedName,
        subjectCode: trimmedCode,
      );
      if (!_subjects.any(
        (StudentSubject s) =>
            s.name == newSubject.name &&
            s.subjectCode == newSubject.subjectCode,
      )) {
        _subjects.add(newSubject);
        _subjects.sort(
          (StudentSubject a, StudentSubject b) =>
              a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
        _saveSubjects();
        notifyListeners();
      } else {
        debugPrint(
          'Student Subject "$trimmedName" with code "$trimmedCode" already exists.',
        );
      }
    }
  }

  void removeSubject(StudentSubject subject) {
    if (_subjects.remove(subject)) {
      _saveSubjects();
      notifyListeners();
    }
  }

  Future<void> clearAllSubjects() async {
    _subjects.clear();
    await _saveSubjects();
    notifyListeners();
  }

  Future<void> _saveSubjects() async {
    final List<Map<String, dynamic>> subjectsJson = _subjects
        .map<Map<String, dynamic>>((StudentSubject s) => s.toJson())
        .toList();
    await _prefs.setString(_subjectsKey, jsonEncode(subjectsJson));
  }

  Future<void> _loadSubjects() async {
    final String? subjectsString = _prefs.getString(_subjectsKey);
    if (subjectsString != null) {
      try {
        final List<dynamic> subjectsJson =
            jsonDecode(subjectsString) as List<dynamic>;
        _subjects = subjectsJson
            .map<StudentSubject>(
              (dynamic item) =>
                  StudentSubject.fromJson(item as Map<String, dynamic>),
            )
            .toList();
        _subjects.sort(
          (StudentSubject a, StudentSubject b) =>
              a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
      } catch (e) {
        debugPrint(
          'Error loading student subjects: $e. Clearing corrupted data.',
        );
        _subjects.clear();
      }
    }
  }
}