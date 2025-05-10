import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TeachersTab extends StatefulWidget {
  final String token;
  final int userId;

  const TeachersTab({super.key, required this.token, required this.userId});

  @override
  State<TeachersTab> createState() => _TeachersTabState();
}

class _TeachersTabState extends State<TeachersTab> {
  bool isLoading = true;
  List<Map<String, dynamic>> teachers = [];

  @override
  void initState() {
    super.initState();
    _fetchTeachers();
  }

  Future<void> _fetchTeachers() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.100.66:5000/professors'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          teachers = List<Map<String, dynamic>>.from(data);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _showAddTeacherDialog() async {
    final TextEditingController firstNameController = TextEditingController();
    final TextEditingController lastNameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController matiereController = TextEditingController();
    final TextEditingController classesController = TextEditingController();

    await showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Add New Teacher'),
        message: SingleChildScrollView(
          child: Column(
            children: [
              CupertinoTextField(
                controller: firstNameController,
                placeholder: 'First Name',
                padding: const EdgeInsets.all(12),
              ),
              const SizedBox(height: 8),
              CupertinoTextField(
                controller: lastNameController,
                placeholder: 'Last Name',
                padding: const EdgeInsets.all(12),
              ),
              const SizedBox(height: 8),
              CupertinoTextField(
                controller: emailController,
                placeholder: 'Academic Email',
                keyboardType: TextInputType.emailAddress,
                padding: const EdgeInsets.all(12),
              ),
              const SizedBox(height: 8),
              CupertinoTextField(
                controller: passwordController,
                placeholder: 'Password',
                obscureText: true,
                padding: const EdgeInsets.all(12),
              ),
              const SizedBox(height: 8),
              CupertinoTextField(
                controller: matiereController,
                placeholder: 'Subject',
                padding: const EdgeInsets.all(12),
              ),
              const SizedBox(height: 8),
              CupertinoTextField(
                controller: classesController,
                placeholder: 'Classes (comma-separated)',
                padding: const EdgeInsets.all(12),
              ),
            ],
          ),
        ),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () async {
              try {
                final response = await http.post(
                  Uri.parse('http://192.168.100.66:5000/professors/signup'),
                  headers: {
                    'Content-Type': 'application/json',
                  },
                  body: json.encode({
                    'firstName': firstNameController.text,
                    'lastName': lastNameController.text,
                    'gmailAcademique': emailController.text,
                    'password': passwordController.text,
                    'matiere': matiereController.text,
                    'classes': classesController.text,
                    'role': 'professor'
                  }),
                );

                if (response.statusCode == 201) {
                  Navigator.pop(context);
                  _fetchTeachers();
                } else {
                  showCupertinoDialog(
                    context: context,
                    builder: (context) => CupertinoAlertDialog(
                      title: const Text('Error'),
                      content: const Text('Failed to add teacher'),
                      actions: [
                        CupertinoDialogAction(
                          child: const Text('OK'),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  );
                }
              } catch (e) {
                showCupertinoDialog(
                  context: context,
                  builder: (context) => CupertinoAlertDialog(
                    title: const Text('Error'),
                    content: const Text('An error occurred'),
                    actions: [
                      CupertinoDialogAction(
                        child: const Text('OK'),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                );
              }
            },
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

  Future<void> _showEditTeacherDialog(Map<String, dynamic> teacher) async {
    final TextEditingController firstNameController = TextEditingController(text: teacher['firstName']);
    final TextEditingController lastNameController = TextEditingController(text: teacher['lastName']);
    final TextEditingController emailController = TextEditingController(text: teacher['gmailAcademique']);
    final TextEditingController matiereController = TextEditingController(text: teacher['matiere']);
    final TextEditingController classesController = TextEditingController(text: teacher['classes']);
    final TextEditingController passwordController = TextEditingController();

    await showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Edit Teacher'),
        message: SingleChildScrollView(
          child: Column(
            children: [
              CupertinoTextField(
                controller: firstNameController,
                placeholder: 'First Name',
                padding: const EdgeInsets.all(12),
              ),
              const SizedBox(height: 8),
              CupertinoTextField(
                controller: lastNameController,
                placeholder: 'Last Name',
                padding: const EdgeInsets.all(12),
              ),
              const SizedBox(height: 8),
              CupertinoTextField(
                controller: emailController,
                placeholder: 'Academic Email',
                keyboardType: TextInputType.emailAddress,
                padding: const EdgeInsets.all(12),
              ),
              const SizedBox(height: 8),
              CupertinoTextField(
                controller: passwordController,
                placeholder: 'New Password (leave empty to keep current)',
                obscureText: true,
                padding: const EdgeInsets.all(12),
              ),
              const SizedBox(height: 8),
              CupertinoTextField(
                controller: matiereController,
                placeholder: 'Subject',
                padding: const EdgeInsets.all(12),
              ),
              const SizedBox(height: 8),
              CupertinoTextField(
                controller: classesController,
                placeholder: 'Classes (comma-separated)',
                padding: const EdgeInsets.all(12),
              ),
            ],
          ),
        ),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () async {
              try {
                final Map<String, dynamic> updateData = {
                  'firstName': firstNameController.text,
                  'lastName': lastNameController.text,
                  'gmailAcademique': emailController.text,
                  'matiere': matiereController.text,
                  'classes': classesController.text,
                  'role': 'professor'
                };

                if (passwordController.text.isNotEmpty) {
                  updateData['password'] = passwordController.text;
                }

                final response = await http.put(
                  Uri.parse('http://192.168.100.66:5000/professors/${widget.userId}'),
                  headers: {
                    'Authorization': 'Bearer ${widget.token}',
                    'Content-Type': 'application/json',
                  },
                  body: json.encode(updateData),
                );

                if (response.statusCode == 200) {
                  Navigator.pop(context);
                  _fetchTeachers();
                } else {
                  showCupertinoDialog(
                    context: context,
                    builder: (context) => CupertinoAlertDialog(
                      title: const Text('Error'),
                      content: const Text('Failed to update teacher'),
                      actions: [
                        CupertinoDialogAction(
                          child: const Text('OK'),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  );
                }
              } catch (e) {
                showCupertinoDialog(
                  context: context,
                  builder: (context) => CupertinoAlertDialog(
                    title: const Text('Error'),
                    content: const Text('An error occurred'),
                    actions: [
                      CupertinoDialogAction(
                        child: const Text('OK'),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                );
              }
            },
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

  Future<void> _deleteTeacher(String teacherId) async {
    try {
      final response = await http.delete(
        Uri.parse('http://192.168.100.66:5000/professors/$teacherId'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        _fetchTeachers();
      } else {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Error'),
            content: const Text('Failed to delete teacher'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Error'),
          content: const Text('An error occurred'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
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
                          child: const Icon(CupertinoIcons.delete),
                          onPressed: () => showCupertinoDialog(
                            context: context,
                            builder: (context) => CupertinoAlertDialog(
                              title: const Text('Delete Teacher'),
                              content: const Text('Are you sure you want to delete this teacher?'),
                              actions: [
                                CupertinoDialogAction(
                                  isDestructiveAction: true,
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _deleteTeacher(teacher['id'].toString());
                                  },
                                  child: const Text('Delete'),
                                ),
                                CupertinoDialogAction(
                                  child: const Text('Cancel'),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
} 