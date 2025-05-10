import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminProfileTab extends StatefulWidget {
  final String token;
  final int userId;
  final String adminName;
  final String adminEmail;
  final String adminRole;
  final VoidCallback onLogout;

  const AdminProfileTab({
    super.key,
    required this.token,
    required this.userId,
    required this.adminName,
    required this.adminEmail,
    required this.adminRole,
    required this.onLogout,
  });

  @override
  State<AdminProfileTab> createState() => _AdminProfileTabState();
}

class _AdminProfileTabState extends State<AdminProfileTab> {
  bool isLoading = false;
  Map<String, dynamic> profileData = {};
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController emailController;
  late TextEditingController currentPasswordController;
  late TextEditingController newPasswordController;

  @override
  void initState() {
    super.initState();
    currentPasswordController = TextEditingController();
    newPasswordController = TextEditingController();
    _fetchProfileData();
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _fetchProfileData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('http://192.168.100.66:5000/professors/${widget.userId}'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          profileData = data;
          firstNameController = TextEditingController(text: data['firstName'] ?? '');
          lastNameController = TextEditingController(text: data['lastName'] ?? '');
          emailController = TextEditingController(text: data['gmailAcademique'] ?? '');
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

  Future<void> _updateProfile() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.put(
        Uri.parse('http://192.168.100.66:5000/professors/${widget.userId}'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'firstName': firstNameController.text,
          'lastName': lastNameController.text,
          'gmailAcademique': emailController.text,
        }),
      );

      if (response.statusCode == 200) {
        await _fetchProfileData();
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Success'),
            content: const Text('Profile updated successfully'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      } else {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Error'),
            content: const Text('Failed to update profile'),
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
          content: Text('An error occurred: $e'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Profile'),
      ),
      child: SafeArea(
        child: isLoading
            ? const Center(child: CupertinoActivityIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Profile Information',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
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
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: CupertinoButton.filled(
                        child: const Text('Update Profile'),
                        onPressed: _updateProfile,
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Change Password',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    CupertinoTextField(
                      controller: currentPasswordController,
                      placeholder: 'Current Password',
                      obscureText: true,
                      padding: const EdgeInsets.all(12),
                    ),
                    const SizedBox(height: 8),
                    CupertinoTextField(
                      controller: newPasswordController,
                      placeholder: 'New Password',
                      obscureText: true,
                      padding: const EdgeInsets.all(12),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: CupertinoButton(
                        color: CupertinoColors.destructiveRed,
                        child: const Text('Logout'),
                        onPressed: () {
                          showCupertinoDialog(
                            context: context,
                            builder: (_) => CupertinoAlertDialog(
                              title: const Text('Log Out'),
                              content: const Text('Are you sure you want to log out?'),
                              actions: [
                                CupertinoDialogAction(
                                  child: const Text('Cancel'),
                                  onPressed: () => Navigator.pop(context),
                                ),
                                CupertinoDialogAction(
                                  isDestructiveAction: true,
                                  child: const Text('Log Out'),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    widget.onLogout();
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
} 