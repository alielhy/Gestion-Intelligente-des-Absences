import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'dashboard/dashboard_tab.dart';
import 'teachers/teachers_tab.dart';
import 'profile/admin_profile_tab.dart';
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

class _AdminHomePageState extends State<AdminHomePage> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late List<Widget> _pages;
  late TabController _tabController;
  
  String adminName = '';
  String adminEmail = '';
  String adminRole = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _selectedIndex = _tabController.index);
      }
    });

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
      Uri.parse('http://192.168.100.66:5000/signin'),
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
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          _tabController.animateTo(index, 
            duration: const Duration(milliseconds: 300), 
            curve: Curves.easeInOut);
        },
        activeColor: const Color(0xFF0084FF),
        inactiveColor: CupertinoColors.systemGrey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.chart_bar_fill),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person_2_fill),
            label: 'Teachers',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.doc_chart_fill),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person_fill),
            label: 'Profile',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        if (isLoading) {
          return CupertinoTabView(
            builder: (context) => const Center(child: CupertinoActivityIndicator()),
          );
        }

        _pages = [
          DashboardTab(token: widget.token),
          TeachersTab(token: widget.token, userId: widget.userId),
          AdminProfileTab(
            token: widget.token,
            userId: widget.userId,
            adminName: adminName,
            adminEmail: adminEmail,
            adminRole: adminRole,
            onLogout: () {
              Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => WelcomePage()),
                (route) => false,
              );
            },
          ),
        ];

        return CupertinoTabView(
          builder: (context) => _pages[index],
        );
      },
    );
  }
} 