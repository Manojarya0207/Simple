import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user/current_student_profile.dart';
import '../../models/user/user_session.dart';
import '../../models/user/user_role.dart';
import '../../models/student/student.dart';

/// Screen for creating/editing student profile
class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _registerNumberController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load existing profile if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final Student? profile =
          context.read<CurrentStudentProfile>().profile;
      if (profile != null) {
        _nameController.text = profile.name;
        _registerNumberController.text = profile.registerNumber;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _registerNumberController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final Student newProfile = Student(
        name: _nameController.text.trim(),
        registerNumber: _registerNumberController.text.trim(),
      );

      await context.read<CurrentStudentProfile>().setProfile(newProfile);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile saved successfully')),
        );
        Navigator.pop(context);
      }
    }
  }

  Future<void> _logout() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      context.read<UserSession>().userRole = UserRole.unselected;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasExistingProfile =
        context.watch<CurrentStudentProfile>().profile != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(hasExistingProfile ? 'Edit Profile' : 'Create Profile'),
        actions: <Widget>[
          if (hasExistingProfile)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
              tooltip: 'Logout',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            const SizedBox(height: 16),
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
              validator: (String? value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _registerNumberController,
              decoration: const InputDecoration(
                labelText: 'Register Number',
                prefixIcon: Icon(Icons.badge_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (String? value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your register number';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Save Profile',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}