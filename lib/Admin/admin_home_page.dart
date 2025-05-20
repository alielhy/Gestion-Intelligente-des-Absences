import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'dashboard/dashboard_tab.dart';
import 'teachers/teachers_tab.dart';
import 'profile/admin_profile_tab.dart';
import '../Home/classes/classes_tab.dart';
import '../Home/scan/scan_tab.dart';
import '../Home/reports/reports_tab.dart';
import '../Login/screens/welcome_screen.dart';

class AdminHomePage extends StatefulWidget {
  final String token;
  final int userId;
  final String initialName;
  final String initialEmail;
  final String initialRole;

  const AdminHomePage({
    super.key,
    required this.token,
    required this.userId,
    required this.initialName,
    required this.initialEmail,
    required this.initialRole,
  });

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _selectedIndex = 0;
  late List<Widget> _pages;

  String adminName = '';
  String adminEmail = '';
  String adminRole = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Initialize with provided values
    adminName = widget.initialName;
    adminEmail = widget.initialEmail;
    adminRole = widget.initialRole;
    isLoading = false;

    // Fetch admin profile data
    _fetchAdminProfileData();
  }

  Future<void> _fetchAdminProfileData() async {
    final response = await http.get(
      Uri.parse('http://172.20.10.6:5000/signin'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        adminName = data['admin']['firstName'];
        adminEmail = data['admin']['email'];
        adminRole = data['admin']['role'];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _pages = [
      ClassesTab(cameras: []),
      ReportsTab(),
      ScanTab(cameras: [],),
      DashboardTab(token: widget.token),
      TeachersTab(token: widget.token, adminApiKey: widget.token),
      AdminProfileTab(
        token: widget.token,
        adminName: adminName,
        adminEmail: adminEmail,
        adminRole: adminRole,
        onLogout: () {
          Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
            CupertinoPageRoute(builder: (_) => WelcomePage()),
            (route) => false,
          );
        },
      ),
    ];

    return CupertinoPageScaffold(
      child: isLoading
          ? Center(child: CupertinoActivityIndicator())
          : Column(
              children: [
                Expanded(
                  child: _pages[_selectedIndex],
                ),
                CupertinoTabBar(
                  currentIndex: _selectedIndex,
                  onTap: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  items: const [
                    
                    BottomNavigationBarItem(
                      icon: Icon(CupertinoIcons.book_fill),
                      label: 'Classes',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(CupertinoIcons.doc_text),
                      label: 'Reports',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(CupertinoIcons.camera_fill),
                      label: 'Scan',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(CupertinoIcons.chart_bar_fill),
                      label: 'Dashboard',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(CupertinoIcons.person_2_fill),
                      label: 'Teachers',
                    ),
                    
                    BottomNavigationBarItem(
                      icon: Icon(CupertinoIcons.person_fill),
                      label: 'Profile',
                    ),
                    
                  ],
                ),
              ],
            ),
    );
  }
} 