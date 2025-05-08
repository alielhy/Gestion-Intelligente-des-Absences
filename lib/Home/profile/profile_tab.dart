import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:absent_detector/Home/About/about_page.dart';
import 'package:absent_detector/Home/About/help_page.dart';
import 'package:absent_detector/Login/screens/login_panel.dart';

class ProfileTab extends StatefulWidget {
  final String token; // Pass the token that identifies the logged-in user
  final String teacherName;
  final String teacherEmail;
  final String teacherRole;
  final VoidCallback onLogout;

  const ProfileTab({
    super.key,
    required this.token,
    required this.teacherName,
    required this.teacherEmail,
    required this.teacherRole,
    required this.onLogout,
  });

  @override
  _ProfileTabState createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  String firstName = '';
  String gmailAcademique = '';
  String role = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:5000/signin'), // Your API URL
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        firstName = data['professor']['firstName'];
        gmailAcademique = data['professor']['gmailAcademique'];
        role = data['professor']['role'];
        isLoading = false;
      });
    } else {
      // Handle error
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: const CupertinoNavigationBar(
        backgroundColor: CupertinoColors.white,
        middle: Text('Profile', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      child: isLoading
          ? const Center(child: CupertinoActivityIndicator())
          : ListView(
              children: [
                Container(
                  color: CupertinoColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          // TODO: Implement change profile picture functionality
                        },
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0084FF).withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            CupertinoIcons.person_fill,
                            size: 50,
                            color: Color(0xFF0084FF),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.teacherName,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        widget.teacherEmail,
                        style: const TextStyle(color: CupertinoColors.systemGrey),
                      ),
                      Text(
                        role,
                        style: const TextStyle(color: CupertinoColors.systemGrey2, fontSize: 13),
                      ),
                      const SizedBox(height: 16),
                      CupertinoButton(
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(CupertinoIcons.pencil),
                            SizedBox(width: 8),
                            Text('Edit Profile Picture'),
                          ],
                        ),
                        onPressed: () {
                          // TODO: Add image picker for profile picture
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildProfileSection([
                  _buildProfileTile(
                    context,
                    icon: CupertinoIcons.info_circle_fill,
                    iconColor: const Color(0xFF0084FF),
                    title: 'About',
                    onTap: () => Navigator.push(
                      context,
                      CupertinoPageRoute(builder: (_) => const AboutPage()),
                    ),
                  ),
                  _buildProfileTile(
                    context,
                    icon: CupertinoIcons.question_circle_fill,
                    iconColor: const Color(0xFF0084FF),
                    title: 'Help',
                    onTap: () => Navigator.push(
                      context,
                      CupertinoPageRoute(builder: (_) => const HelpPage()),
                    ),
                  ),
                ]),
                const SizedBox(height: 20),
                _buildProfileSection([
                  _buildProfileTile(
                    context,
                    icon: CupertinoIcons.power,
                    iconColor: CupertinoColors.systemRed,
                    title: 'Log Out',
                    showChevron: false,
                    onTap: () {
                      showCupertinoDialog(
                        context: context,
                        builder: (_) => CupertinoAlertDialog(
                          title: Text('Log Out'),
                          content: Text('Are you sure you want to log out?'),
                          actions: [
                            CupertinoDialogAction(
                              child: Text('Cancel'),
                              onPressed: () => Navigator.pop(context),
                            ),
                            CupertinoDialogAction(
                              isDestructiveAction: true,
                              child: Text('Log Out'),
                              onPressed: () {
                                Navigator.pop(context); // Close dialog
                                widget.onLogout();
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ]),
                const SizedBox(height: 30),
                const Center(
                  child: Text(
                    'Attendance App v1.0',
                    style: TextStyle(color: CupertinoColors.systemGrey, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
    );
  }

  Widget _buildProfileSection(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(children: children),
    );
  }

  Widget _buildProfileTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    bool showChevron = true,
    VoidCallback? onTap,
  }) {
    return CupertinoListTile(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      trailing: showChevron
          ? const Icon(
              CupertinoIcons.chevron_right,
              color: CupertinoColors.systemGrey3,
            )
          : null,
    );
  }
}
