/// Represents a subject for a student with a name and code.
class StudentSubject {
  final String name;
  final String subjectCode;

  const StudentSubject({
    required this.name,
    required this.subjectCode,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudentSubject &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          subjectCode == other.subjectCode;

  @override
  int get hashCode => Object.hash(name, subjectCode);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'subjectCode': subjectCode,
      };

  factory StudentSubject.fromJson(Map<String, dynamic> json) {
    return StudentSubject(
      name: json['name'] as String,
      subjectCode: json['subjectCode'] as String,
    );
  }
}