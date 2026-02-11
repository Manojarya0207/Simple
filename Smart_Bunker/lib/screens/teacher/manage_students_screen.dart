import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/student/student_data.dart';
import '../../models/student/student.dart';

/// Screen for managing students (add, edit, remove)
class ManageStudentsScreen extends StatefulWidget {
  const ManageStudentsScreen({super.key});

  @override
  State<ManageStudentsScreen> createState() => _ManageStudentsScreenState();
}

class _ManageStudentsScreenState extends State<ManageStudentsScreen> {
  void _showAddStudentDialog() {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController registerController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Add Student'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Student Name',
                  border: OutlineInputBorder(),
                ),
                validator: (String? value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter student name';
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: registerController,
                decoration: const InputDecoration(
                  labelText: 'Register Number',
                  border: OutlineInputBorder(),
                ),
                validator: (String? value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter register number';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                context.read<StudentData>().addStudent(
                      nameController.text.trim(),
                      registerController.text.trim(),
                    );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Student added successfully')),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Student student) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Delete Student'),
        content: Text('Are you sure you want to delete ${student.name}?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<StudentData>().removeStudent(student);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Student deleted')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Students'),
      ),
      body: Consumer<StudentData>(
        builder: (
          BuildContext context,
          StudentData studentData,
          Widget? child,
        ) {
          final List<Student> students = studentData.students;

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
                  Text(
                    'No students added yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _showAddStudentDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add First Student'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: students.length,
            itemBuilder: (BuildContext context, int index) {
              final Student student = students[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
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
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Reg No: ${student.registerNumber}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _showDeleteConfirmation(student),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddStudentDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Student'),
      ),
    );
  }
}