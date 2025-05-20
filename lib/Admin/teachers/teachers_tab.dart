import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TeachersTab extends StatefulWidget {
  final String token;
  final String adminApiKey;

  const TeachersTab({
    super.key, 
    required this.token,
    required this.adminApiKey,
  });

  @override
  State<TeachersTab> createState() => _TeachersTabState();
}

class _TeachersTabState extends State<TeachersTab> {
  bool isLoading = true;
  List<Map<String, dynamic>> teachers = [];
  final String baseUrl = 'http://172.20.10.6:5000';

  @override
  void initState() {
    super.initState();
    _fetchTeachers();
  }

  Future<void> _fetchTeachers() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/professors'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'API-Key': widget.adminApiKey,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          teachers = List<Map<String, dynamic>>.from(data);
          isLoading = false;
        });
      } else {
        _showError('Failed to fetch teachers: ${response.statusCode}');
        setState(() => isLoading = false);
      }
    } catch (e) {
      _showError('Network error: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _showAddTeacherDialog() async {
    final controllers = {
      'firstName': TextEditingController(),
      'lastName': TextEditingController(),
      'email': TextEditingController(),
      'password': TextEditingController(),
      'matiere': TextEditingController(),
      'classes': TextEditingController(),
    };

    await showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Add New Teacher'),
        message: SingleChildScrollView(
          child: Column(
            children: [
              _buildTextField(controllers['firstName']!, 'First Name'),
              _buildTextField(controllers['lastName']!, 'Last Name'),
              _buildTextField(controllers['email']!, 'Academic Email', 
                keyboardType: TextInputType.emailAddress),
              _buildTextField(controllers['password']!, 'Password', 
                obscureText: true),
              _buildTextField(controllers['matiere']!, 'Subject'),
              _buildTextField(controllers['classes']!, 'Classes (comma separated)'),
            ],
          ),
        ),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => _addTeacher(controllers, context),
            child: const Text('Add'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String placeholder, {
    TextInputType? keyboardType,
    bool obscureText = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: CupertinoTextField(
        controller: controller,
        placeholder: placeholder,
        padding: const EdgeInsets.all(12),
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: BoxDecoration(
          border: Border.all(color: CupertinoColors.systemGrey3),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Future<void> _addTeacher(
    Map<String, TextEditingController> controllers, 
    BuildContext context,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/professors'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
          'API-Key': widget.adminApiKey,
        },
        body: json.encode({
          'firstName': controllers['firstName']!.text,
          'lastName': controllers['lastName']!.text,
          'gmailAcademique': controllers['email']!.text,
          'password': controllers['password']!.text,
          'matiere': controllers['matiere']!.text,
          'classes': controllers['classes']!.text,
          'role': 'professor',
        }),
      );

      if (response.statusCode == 201) {
        Navigator.pop(context);
        _fetchTeachers();
      } else {
        _showError('Failed to add teacher: ${response.body}');
      }
    } catch (e) {
      _showError('Error: $e');
    }
  }

  Future<void> _showEditTeacherDialog(Map<String, dynamic> teacher) async {
    final controllers = {
      'firstName': TextEditingController(text: teacher['firstName']),
      'lastName': TextEditingController(text: teacher['lastName']),
      'email': TextEditingController(text: teacher['gmailAcademique']),
      'password': TextEditingController(),
      'matiere': TextEditingController(text: teacher['matiere']),
      'classes': TextEditingController(text: teacher['classes']),
    };

    await showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Edit Teacher'),
        message: SingleChildScrollView(
          child: Column(
            children: [
              _buildTextField(controllers['firstName']!, 'First Name'),
              _buildTextField(controllers['lastName']!, 'Last Name'),
              _buildTextField(controllers['email']!, 'Academic Email',
                keyboardType: TextInputType.emailAddress),
              _buildTextField(controllers['password']!, 'New Password (leave empty to keep current)',
                obscureText: true),
              _buildTextField(controllers['matiere']!, 'Subject'),
              _buildTextField(controllers['classes']!, 'Classes (comma separated)'),
            ],
          ),
        ),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => _updateTeacher(teacher['id'], controllers, context),
            child: const Text('Update'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  Future<void> _updateTeacher(
    int id,
    Map<String, TextEditingController> controllers,
    BuildContext context,
  ) async {
    try {
      final updateData = {
        'firstName': controllers['firstName']!.text,
        'lastName': controllers['lastName']!.text,
        'gmailAcademique': controllers['email']!.text,
        'matiere': controllers['matiere']!.text,
        'classes': controllers['classes']!.text,
      };

      if (controllers['password']!.text.isNotEmpty) {
        updateData['password'] = controllers['password']!.text;
      }

      final response = await http.put(
        Uri.parse('$baseUrl/professors/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
          'API-Key': widget.adminApiKey,
        },
        body: json.encode(updateData),
      );

      if (response.statusCode == 200) {
        Navigator.pop(context);
        _fetchTeachers();
      } else {
        _showError('Failed to update teacher: ${response.body}');
      }
    } catch (e) {
      _showError('Error: $e');
    }
  }

  Future<void> _deleteTeacher(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/professors/$id'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'API-Key': widget.adminApiKey,
        },
      );

      if (response.statusCode == 200) {
        _fetchTeachers();
      } else {
        _showError('Failed to delete teacher: ${response.body}');
      }
    } catch (e) {
      _showError('Error: $e');
    }
  }

  void _showError(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Teachers'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.add),
          onPressed: _showAddTeacherDialog,
        ),
      ),
      child: SafeArea(
        child: isLoading
            ? const Center(child: CupertinoActivityIndicator())
            : ListView.builder(
                itemCount: teachers.length,
                itemBuilder: (context, index) {
                  final teacher = teachers[index];
                  return CupertinoListTile(
                    title: Text('${teacher['firstName']} ${teacher['lastName']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(teacher['gmailAcademique']),
                        Text('Subject: ${teacher['matiere']}'),
                        Text('Classes: ${teacher['classes']}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          child: const Icon(CupertinoIcons.pencil),
                          onPressed: () => _showEditTeacherDialog(teacher),
                        ),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          child: const Icon(CupertinoIcons.delete, color: CupertinoColors.destructiveRed),
                          onPressed: () => _confirmDelete(teacher['id']),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  void _confirmDelete(int id) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Delete Teacher'),
        content: const Text('Are you sure you want to delete this teacher?'),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              _deleteTeacher(id);
            },
            child: const Text('Delete'),
          ),
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}