import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/teacher/teacher_subjects_data.dart';

/// Screen for managing subjects (add, edit, remove)
class ManageSubjectsScreen extends StatefulWidget {
  const ManageSubjectsScreen({super.key});

  @override
  State<ManageSubjectsScreen> createState() => _ManageSubjectsScreenState();
}

class _ManageSubjectsScreenState extends State<ManageSubjectsScreen> {
  void _showAddSubjectDialog() {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController codeController = TextEditingController();
    final TextEditingController semesterController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Add Subject'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Subject Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (String? value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter subject name';
                    }
                    return null;
                  },
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: codeController,
                  decoration: const InputDecoration(
                    labelText: 'Subject Code',
                    border: OutlineInputBorder(),
                  ),
                  validator: (String? value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter subject code';
                    }
                    return null;
                  },
                  textCapitalization: TextCapitalization.characters,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: semesterController,
                  decoration: const InputDecoration(
                    labelText: 'Semester (Optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
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
                context.read<TeacherSubjectsData>().addSubject(
                      nameController.text.trim(),
                      codeController.text.trim(),
                      semesterController.text.trim(),
                    );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Subject added successfully')),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(TeacherSubject subject) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Delete Subject'),
        content: Text('Are you sure you want to delete ${subject.name}?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<TeacherSubjectsData>().removeSubject(subject);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Subject deleted')),
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
        title: const Text('Manage Subjects'),
      ),
      body: Consumer<TeacherSubjectsData>(
        builder: (
          BuildContext context,
          TeacherSubjectsData subjectsData,
          Widget? child,
        ) {
          final List<TeacherSubject> subjects = subjectsData.subjects;

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
                  Text(
                    'No subjects added yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _showAddSubjectDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add First Subject'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: subjects.length,
            itemBuilder: (BuildContext context, int index) {
              final TeacherSubject subject = subjects[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: const Icon(Icons.book, color: Colors.white),
                  ),
                  title: Text(
                    subject.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Code: ${subject.subjectCode}'),
                      if (subject.semester.isNotEmpty)
                        Text('Semester: ${subject.semester}'),
                    ],
                  ),
                  isThreeLine: subject.semester.isNotEmpty,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _showDeleteConfirmation(subject),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSubjectDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Subject'),
      ),
    );
  }
}