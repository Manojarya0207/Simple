import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/student/student_subjects_model.dart';

/// Screen for adding a new subject
class AddSubjectScreen extends StatefulWidget {
  const AddSubjectScreen({super.key});

  @override
  State<AddSubjectScreen> createState() => _AddSubjectScreenState();
}

class _AddSubjectScreenState extends State<AddSubjectScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _addSubject() {
    if (_formKey.currentState!.validate()) {
      context.read<StudentSubjectsModel>().addSubject(
            _nameController.text.trim(),
            _codeController.text.trim(),
          );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Subject added successfully')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Subject'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Subject Name',
                prefixIcon: Icon(Icons.book),
                border: OutlineInputBorder(),
                hintText: 'e.g., Mathematics',
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
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: 'Subject Code',
                prefixIcon: Icon(Icons.code),
                border: OutlineInputBorder(),
                hintText: 'e.g., MATH101',
              ),
              validator: (String? value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter subject code';
                }
                return null;
              },
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _addSubject,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Add Subject',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}