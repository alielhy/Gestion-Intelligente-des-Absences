import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'classes/classes_tab.dart';
import 'reports/reports_tab.dart';
import 'scan/scan_tab.dart';
import 'profile/profile_tab.dart';
import 'package:absent_detector/Login/screens/welcome_screen.dart';

class HomePage extends StatefulWidget {
  final List<CameraDescription> cameras;
  final String token; // Add token for authenticated requests

  const HomePage({super.key, required this.cameras, required this.token});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late List<Widget> _pages;
  late TabController _tabController;
  
  String teacherName = '';
  String teacherEmail = '';
  String teacherRole = '';
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

    // Fetch profile data
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:5000/signin'), // Replace with your API URL
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        teacherName = data['professor']['firstName'];
        teacherEmail = data['professor']['gmailAcademique'];
        teacherRole = data['professor']['role'];
        isLoading = false;
      });
    } else {
      // Handle error if the profile cannot be fetched
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
            icon: Icon(CupertinoIcons.chat_bubble_2_fill),
            label: 'Classes',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.clock_fill),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.camera_fill),
            label: 'Scan',
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
          ClassesTab(cameras: widget.cameras),
          const ReportsTab(),
          ScanTab(
            cameras: widget.cameras,
            studentList: [], // Add empty list or fetch from backend
          ),
          ProfileTab(
            token: widget.token,
            teacherName: teacherName,
            teacherEmail: teacherEmail,
            teacherRole: teacherRole,
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
