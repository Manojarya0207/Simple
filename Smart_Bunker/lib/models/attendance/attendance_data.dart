import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Represents a single attendance record
class AttendanceRecord {
  final String studentName;
  final String studentRegisterNumber;
  final String subjectCode;
  final String subjectName;
  final DateTime date;
  final bool isPresent;
  final String? remarks;

  const AttendanceRecord({
    required this.studentName,
    required this.studentRegisterNumber,
    required this.subjectCode,
    required this.subjectName,
    required this.date,
    required this.isPresent,
    this.remarks,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttendanceRecord &&
          runtimeType == other.runtimeType &&
          studentName == other.studentName &&
          studentRegisterNumber == other.studentRegisterNumber &&
          subjectCode == other.subjectCode &&
          date == other.date;

  @override
  int get hashCode => Object.hash(
        studentName,
        studentRegisterNumber,
        subjectCode,
        date,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'studentName': studentName,
        'studentRegisterNumber': studentRegisterNumber,
        'subjectCode': subjectCode,
        'subjectName': subjectName,
        'date': date.toIso8601String(),
        'isPresent': isPresent,
        'remarks': remarks,
      };

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      studentName: json['studentName'] as String,
      studentRegisterNumber: json['studentRegisterNumber'] as String,
      subjectCode: json['subjectCode'] as String,
      subjectName: json['subjectName'] as String,
      date: DateTime.parse(json['date'] as String),
      isPresent: json['isPresent'] as bool,
      remarks: json['remarks'] as String?,
    );
  }

  AttendanceRecord copyWith({
    String? studentName,
    String? studentRegisterNumber,
    String? subjectCode,
    String? subjectName,
    DateTime? date,
    bool? isPresent,
    String? remarks,
  }) {
    return AttendanceRecord(
      studentName: studentName ?? this.studentName,
      studentRegisterNumber:
          studentRegisterNumber ?? this.studentRegisterNumber,
      subjectCode: subjectCode ?? this.subjectCode,
      subjectName: subjectName ?? this.subjectName,
      date: date ?? this.date,
      isPresent: isPresent ?? this.isPresent,
      remarks: remarks ?? this.remarks,
    );
  }
}

/// Attendance statistics for a student in a subject
class AttendanceStats {
  final int totalClasses;
  final int attendedClasses;

  const AttendanceStats({
    required this.totalClasses,
    required this.attendedClasses,
  });

  double get attendancePercentage =>
      totalClasses > 0 ? (attendedClasses / totalClasses) * 100 : 0.0;

  int get absentClasses => totalClasses - attendedClasses;
}

/// Data model for managing attendance records.
/// This model uses SharedPreferences for persistence.
class AttendanceData extends ChangeNotifier {
  List<AttendanceRecord> _records;

  late SharedPreferences _prefs;
  static const String _recordsKey = 'attendanceRecords';

  AttendanceData({List<AttendanceRecord>? initialRecords})
      : _records = initialRecords ?? <AttendanceRecord>[] {
    _initPrefsAndLoadData();
  }

  Future<void> _initPrefsAndLoadData() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadRecords();
    notifyListeners();
  }

  List<AttendanceRecord> get records =>
      List<AttendanceRecord>.unmodifiable(_records);

  /// Add or update an attendance record
  void markAttendance({
    required String studentName,
    required String studentRegisterNumber,
    required String subjectCode,
    required String subjectName,
    required DateTime date,
    required bool isPresent,
    String? remarks,
  }) {
    // Remove existing record for same student, subject, and date if exists
    _records.removeWhere(
      (AttendanceRecord r) =>
          r.studentRegisterNumber == studentRegisterNumber &&
          r.subjectCode == subjectCode &&
          r.date.year == date.year &&
          r.date.month == date.month &&
          r.date.day == date.day,
    );

    // Add new record
    final AttendanceRecord newRecord = AttendanceRecord(
      studentName: studentName,
      studentRegisterNumber: studentRegisterNumber,
      subjectCode: subjectCode,
      subjectName: subjectName,
      date: date,
      isPresent: isPresent,
      remarks: remarks,
    );

    _records.add(newRecord);
    _saveRecords();
    notifyListeners();
  }

  /// Get attendance records for a specific student
  List<AttendanceRecord> getStudentRecords(String studentRegisterNumber) {
    return _records
        .where((AttendanceRecord r) =>
            r.studentRegisterNumber == studentRegisterNumber)
        .toList()
      ..sort((AttendanceRecord a, AttendanceRecord b) => b.date.compareTo(a.date));
  }

  /// Get attendance records for a specific subject
  List<AttendanceRecord> getSubjectRecords(String subjectCode) {
    return _records
        .where((AttendanceRecord r) => r.subjectCode == subjectCode)
        .toList()
      ..sort((AttendanceRecord a, AttendanceRecord b) => b.date.compareTo(a.date));
  }

  /// Get attendance statistics for a student in a specific subject
  AttendanceStats getAttendanceStats(
    String studentRegisterNumber,
    String subjectCode,
  ) {
    final List<AttendanceRecord> studentSubjectRecords = _records
        .where(
          (AttendanceRecord r) =>
              r.studentRegisterNumber == studentRegisterNumber &&
              r.subjectCode == subjectCode,
        )
        .toList();

    final int totalClasses = studentSubjectRecords.length;
    final int attendedClasses = studentSubjectRecords
        .where((AttendanceRecord r) => r.isPresent)
        .length;

    return AttendanceStats(
      totalClasses: totalClasses,
      attendedClasses: attendedClasses,
    );
  }

  /// Get overall attendance statistics for a student across all subjects
  AttendanceStats getOverallAttendanceStats(String studentRegisterNumber) {
    final List<AttendanceRecord> studentRecords = _records
        .where(
          (AttendanceRecord r) =>
              r.studentRegisterNumber == studentRegisterNumber,
        )
        .toList();

    final int totalClasses = studentRecords.length;
    final int attendedClasses =
        studentRecords.where((AttendanceRecord r) => r.isPresent).length;

    return AttendanceStats(
      totalClasses: totalClasses,
      attendedClasses: attendedClasses,
    );
  }

  /// Get attendance records for a specific date
  List<AttendanceRecord> getRecordsByDate(DateTime date) {
    return _records
        .where(
          (AttendanceRecord r) =>
              r.date.year == date.year &&
              r.date.month == date.month &&
              r.date.day == date.day,
        )
        .toList();
  }

  /// Remove a specific attendance record
  void removeRecord(AttendanceRecord record) {
    if (_records.remove(record)) {
      _saveRecords();
      notifyListeners();
    }
  }

  /// Clear all attendance records
  Future<void> clearAllRecords() async {
    _records.clear();
    await _saveRecords();
    notifyListeners();
  }

  /// Clear attendance records for a specific student
  Future<void> clearStudentRecords(String studentRegisterNumber) async {
    _records.removeWhere(
      (AttendanceRecord r) => r.studentRegisterNumber == studentRegisterNumber,
    );
    await _saveRecords();
    notifyListeners();
  }

  Future<void> _saveRecords() async {
    final List<Map<String, dynamic>> recordsJson = _records
        .map<Map<String, dynamic>>((AttendanceRecord r) => r.toJson())
        .toList();
    await _prefs.setString(_recordsKey, jsonEncode(recordsJson));
  }

  Future<void> _loadRecords() async {
    final String? recordsString = _prefs.getString(_recordsKey);
    if (recordsString != null) {
      try {
        final List<dynamic> recordsJson =
            jsonDecode(recordsString) as List<dynamic>;
        _records = recordsJson
            .map<AttendanceRecord>(
              (dynamic item) =>
                  AttendanceRecord.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      } catch (e) {
        debugPrint(
          'Error loading attendance records: $e. Clearing corrupted data.',
        );
        _records.clear();
      }
    }
  }
}