import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Represents a subject for teachers
class TeacherSubject {
  final String name;
  final String subjectCode;
  final String semester;
  final int totalClasses;

  const TeacherSubject({
    required this.name,
    required this.subjectCode,
    this.semester = '',
    this.totalClasses = 0,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TeacherSubject &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          subjectCode == other.subjectCode &&
          semester == other.semester;

  @override
  int get hashCode => Object.hash(name, subjectCode, semester);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'subjectCode': subjectCode,
        'semester': semester,
        'totalClasses': totalClasses,
      };

  factory TeacherSubject.fromJson(Map<String, dynamic> json) {
    return TeacherSubject(
      name: json['name'] as String,
      subjectCode: json['subjectCode'] as String,
      semester: json['semester'] as String? ?? '',
      totalClasses: json['totalClasses'] as int? ?? 0,
    );
  }

  TeacherSubject copyWith({
    String? name,
    String? subjectCode,
    String? semester,
    int? totalClasses,
  }) {
    return TeacherSubject(
      name: name ?? this.name,
      subjectCode: subjectCode ?? this.subjectCode,
      semester: semester ?? this.semester,
      totalClasses: totalClasses ?? this.totalClasses,
    );
  }
}

/// Data model for managing subjects for a teacher.
/// This model uses SharedPreferences for persistence.
class TeacherSubjectsData extends ChangeNotifier {
  List<TeacherSubject> _subjects;

  late SharedPreferences _prefs;
  static const String _subjectsKey = 'teacherSubjects';

  TeacherSubjectsData({List<TeacherSubject>? initialSubjects})
      : _subjects = initialSubjects ?? <TeacherSubject>[] {
    _initPrefsAndLoadData();
  }

  Future<void> _initPrefsAndLoadData() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadSubjects();
    notifyListeners();
  }

  List<TeacherSubject> get subjects =>
      List<TeacherSubject>.unmodifiable(_subjects);

  void addSubject(String name, String subjectCode, String semester) {
    final String trimmedName = name.trim();
    final String trimmedCode = subjectCode.trim();
    final String trimmedSemester = semester.trim();

    if (trimmedName.isNotEmpty && trimmedCode.isNotEmpty) {
      final TeacherSubject newSubject = TeacherSubject(
        name: trimmedName,
        subjectCode: trimmedCode,
        semester: trimmedSemester,
      );
      if (!_subjects.any(
        (TeacherSubject s) =>
            s.name == newSubject.name &&
            s.subjectCode == newSubject.subjectCode &&
            s.semester == newSubject.semester,
      )) {
        _subjects.add(newSubject);
        _subjects.sort(
          (TeacherSubject a, TeacherSubject b) =>
              a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
        _saveSubjects();
        notifyListeners();
      } else {
        debugPrint(
          'Teacher Subject "$trimmedName" with code "$trimmedCode" already exists.',
        );
      }
    }
  }

  void removeSubject(TeacherSubject subject) {
    if (_subjects.remove(subject)) {
      _saveSubjects();
      notifyListeners();
    }
  }

  void updateSubject(TeacherSubject oldSubject, TeacherSubject newSubject) {
    final int index = _subjects.indexOf(oldSubject);
    if (index != -1) {
      _subjects[index] = newSubject;
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
        .map<Map<String, dynamic>>((TeacherSubject s) => s.toJson())
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
            .map<TeacherSubject>(
              (dynamic item) =>
                  TeacherSubject.fromJson(item as Map<String, dynamic>),
            )
            .toList();
        _subjects.sort(
          (TeacherSubject a, TeacherSubject b) =>
              a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
      } catch (e) {
        debugPrint(
          'Error loading teacher subjects: $e. Clearing corrupted data.',
        );
        _subjects.clear();
      }
    }
  }
}