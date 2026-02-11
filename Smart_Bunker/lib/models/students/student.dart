/// Represents a student with a name and a register number.
/// This model is shared between Teacher and Student roles.
class Student {
  final String name;
  final String registerNumber;

  const Student({required this.name, this.registerNumber = ''});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Student &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          registerNumber == other.registerNumber;

  @override
  int get hashCode => Object.hash(name, registerNumber);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'registerNumber': registerNumber,
      };

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      name: json['name'] as String,
      registerNumber: json['registerNumber'] as String? ?? '',
    );
  }
}