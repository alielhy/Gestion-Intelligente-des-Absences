import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:camera/camera.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  runApp(MyApp(cameras: cameras));
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;
  
  const MyApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      theme: const CupertinoThemeData(
        primaryColor: Color(0xFF0084FF), // WhatsApp iOS blue
        barBackgroundColor: CupertinoColors.white,
        scaffoldBackgroundColor: CupertinoColors.systemGroupedBackground,
        primaryContrastingColor: CupertinoColors.white,
      ),
      home: HomePage(cameras: cameras),
    );
  }
}

class HomePage extends StatefulWidget {
  final List<CameraDescription> cameras;
  
  const HomePage({super.key, required this.cameras});

  @override
  State<HomePage> createState() => _MainPageState();
}

class _MainPageState extends State<HomePage> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late List<Widget> _pages;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _selectedIndex = _tabController.index);
      }
    });
    
    _pages = [
      const ClassesTab(),
      const ReportsTab(),
      ScanTab(cameras: widget.cameras),
      const ProfileTab(),
    ];
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
          _tabController.animateTo(index, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
        },
        activeColor: const Color(0xFF0084FF), // WhatsApp iOS blue
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
        return CupertinoTabView(
          builder: (context) => _pages[index],
        );
      },
    );
  }
}

// TAB 1: Classes (Like WhatsApp Chats)
class ClassesTab extends StatelessWidget {
  const ClassesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.white,
        middle: const Text('Classes', style: TextStyle(fontWeight: FontWeight.bold)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.search, color: Color(0xFF0084FF)),
              onPressed: () {},
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.ellipsis, color: Color(0xFF0084FF)),
              onPressed: () {},
            ),
          ],
        ),
      ),
      child: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return Hero(
            tag: 'class_${index + 1}',
            child: Material(
              color: Colors.transparent,
              child: CupertinoListTile(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Color(0xFF0084FF).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Center(
                    child: Icon(CupertinoIcons.book_fill, color: Color(0xFF0084FF)),
                  ),
                ),
                title: Text(
                  'Class ${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Last attendance: ${index % 2 == 0 ? 'All present' : '2 absent'}',
                  style: const TextStyle(color: CupertinoColors.systemGrey),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${9 + index}:00 AM',
                      style: const TextStyle(
                        color: Color(0xFF0084FF),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (index % 2 == 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0084FF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'New',
                          style: TextStyle(color: CupertinoColors.white, fontSize: 11),
                        ),
                      ),
                  ],
                ),
                onTap: () {
                  // Animation when tapping on a class
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (context) => ClassDetailPage(classIndex: index + 1),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class ClassDetailPage extends StatelessWidget {
  final int classIndex;
  
  const ClassDetailPage({super.key, required this.classIndex});
  
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.white,
        middle: Row(
          children: [
            Hero(
              tag: 'class_$classIndex',
              child: Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: Color(0xFF0084FF).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(17.5),
                ),
                child: const Center(
                  child: Icon(CupertinoIcons.book_fill, color: Color(0xFF0084FF), size: 18),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Class $classIndex',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.video_camera_solid, color: Color(0xFF0084FF)),
              onPressed: () {},
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.phone, color: Color(0xFF0084FF)),
              onPressed: () {},
            ),
          ],
        ),
      ),
      child: Center(
        child: Text('Class $classIndex Details'),
      ),
    );
  }
}

// TAB 2: Reports (Like WhatsApp Status)
class ReportsTab extends StatelessWidget {
  const ReportsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.white,
        middle: const Text('Reports', style: TextStyle(fontWeight: FontWeight.bold)),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.ellipsis, color: Color(0xFF0084FF)),
          onPressed: () {},
        ),
      ),
      child: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Attendance Reports',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Icon(CupertinoIcons.refresh, color: Color(0xFF0084FF)),
              ],
            ),
          ),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemBuilder: (context, index) {
                return TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 300 + (index * 100)),
                  builder: (context, double value, child) {
                    return Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: Opacity(
                        opacity: value,
                        child: child,
                      ),
                    );
                  },
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 70,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: index == 0 
                                    ? const Color(0xFF0084FF) 
                                    : CupertinoColors.systemGrey4,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Container(
                              margin: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Color(0xFF0084FF).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(28),
                              ),
                              child: const Center(
                                child: Icon(CupertinoIcons.doc_chart_fill, color: Color(0xFF0084FF)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            index == 0 ? 'Your Report' : 'Class ${index}',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: index == 0 
                                  ? const Color(0xFF0084FF) 
                                  : CupertinoColors.systemGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(),
          ...List.generate(3, (index) {
            return TweenAnimationBuilder(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 500 + (index * 100)),
              builder: (context, double value, child) {
                return Transform.translate(
                  offset: Offset(50 * (1 - value), 0),
                  child: Opacity(
                    opacity: value,
                    child: child,
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.systemGrey6,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: CupertinoListTile(
                  padding: const EdgeInsets.all(12),
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0084FF).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Icon(CupertinoIcons.chart_bar_fill, color: Color(0xFF0084FF)),
                  ),
                  title: Text(
                    'Monthly Report ${index + 1}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Oct ${index + 10}, 2023 • ${95 - index}% attendance',
                    style: const TextStyle(color: CupertinoColors.systemGrey),
                  ),
                  trailing: const Icon(
                    CupertinoIcons.chevron_right,
                    color: Color(0xFF0084FF),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// TAB 3: Scan Feature (Camera Tab)
class ScanTab extends StatefulWidget {
  final List<CameraDescription> cameras;
  
  const ScanTab({super.key, required this.cameras});

  @override
  State<ScanTab> createState() => _ScanTabState();
}

class _ScanTabState extends State<ScanTab> with SingleTickerProviderStateMixin {
  late CameraController _controller;
  bool _isReady = false;
  bool _isScanning = false;
  List<String> _presentStudents = [];
  List<String> _absentStudents = [];
  late AnimationController _animationController;
  late Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    
    // Setup animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
  }

  Future<void> _initializeCamera() async {
    _controller = CameraController(
      widget.cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.front),
      ResolutionPreset.medium,
    );
    
    await _controller.initialize();
    if (!mounted) return;
    
    setState(() => _isReady = true);
  }

  void _toggleScan() {
    setState(() {
      _isScanning = !_isScanning;
      
      if (_isScanning) {
        _animationController.repeat(reverse: true);
        // Simulate face detection with animated appearance
        Future.delayed(const Duration(seconds: 2), () {
          if (!mounted) return;
          setState(() {
            _presentStudents = ['John Doe', 'Sarah Smith', 'Alex Johnson'];
          });
          
          Future.delayed(const Duration(seconds: 1), () {
            if (!mounted) return;
            setState(() {
              _absentStudents = ['Mike Brown', 'Emma Wilson'];
            });
          });
        });
      } else {
        _animationController.stop();
        _presentStudents.clear();
        _absentStudents.clear();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.black.withOpacity(0.5),
        border: null,
        middle: const Text(
          'Scan Attendance',
          style: TextStyle(color: CupertinoColors.white),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Text(
            'Done',
            style: TextStyle(color: Color(0xFF0084FF)),
          ),
          onPressed: () {
            // Save attendance
          },
        ),
      ),
      child: Stack(
        children: [
          if (_isReady)
            CameraPreview(_controller)
          else
            const Center(child: CupertinoActivityIndicator()),
          
          // Scanning overlay animation
          if (_isScanning)
            AnimatedBuilder(
              animation: _scanAnimation,
              builder: (context, child) {
                return Positioned(
                  top: MediaQuery.of(context).size.height * _scanAnimation.value - 100,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 2,
                    color: const Color(0xFF0084FF),
                  ),
                );
              },
            ),
          
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: CupertinoColors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: CupertinoColors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      if (_presentStudents.isNotEmpty) ...[
                        _buildStudentList(
                          'Present (${_presentStudents.length})',
                          _presentStudents,
                          const Color(0xFF0084FF),
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (_absentStudents.isNotEmpty) ...[
                        _buildStudentList(
                          'Absent (${_absentStudents.length})',
                          _absentStudents,
                          CupertinoColors.systemRed,
                        ),
                      ],
                      if (_presentStudents.isEmpty && _absentStudents.isEmpty)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              CupertinoIcons.camera_viewfinder,
                              color: Color(0xFF0084FF),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isScanning ? 'Scanning for students...' : 'Point camera at students',
                              style: const TextStyle(
                                color: CupertinoColors.systemGrey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                CupertinoButton(
                  color: _isScanning
                      ? CupertinoColors.systemRed
                      : const Color(0xFF0084FF),
                  borderRadius: BorderRadius.circular(30),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_isScanning ? 'STOP' : 'START SCANNING'),
                        if (_isScanning) ...[
                          const SizedBox(width: 8),
                          const Icon(CupertinoIcons.square_fill, size: 12),
                        ] else ...[
                          const SizedBox(width: 8),
                          const Icon(CupertinoIcons.camera_fill, size: 18),
                        ],
                      ],
                    ),
                  ),
                  onPressed: _toggleScan,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentList(String title, List<String> students, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        ...students.asMap().entries.map((entry) {
          int index = entry.key;
          String student = entry.value;
          
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 300 + (index * 100)),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(20 * (1 - value), 0),
                child: Opacity(
                  opacity: value,
                  child: child,
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(student),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}

// TAB 4: Profile (Like WhatsApp Settings)
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: const CupertinoNavigationBar(
        backgroundColor: CupertinoColors.white,
        middle: Text('Profile', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      child: ListView(
        children: [
          Container(
            color: CupertinoColors.white,
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.5, end: 1.0),
                  duration: const Duration(milliseconds: 500),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: child,
                    );
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
                const Text(
                  'Teacher Name',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'math@school.edu',
                  style: TextStyle(color: CupertinoColors.systemGrey),
                ),
                const SizedBox(height: 16),
                CupertinoButton(
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(CupertinoIcons.pencil),
                      SizedBox(width: 8),
                      Text('Edit Profile'),
                    ],
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildProfileSection(
            [
              _buildProfileTile(
                icon: CupertinoIcons.bell_fill,
                iconColor: Color(0xFF0084FF),
                title: 'Notifications',
                showBadge: true,
              ),
              _buildProfileTile(
                icon: CupertinoIcons.lock_fill,
                iconColor: Color(0xFF0084FF),
                title: 'Privacy',
              ),
              _buildProfileTile(
                icon: CupertinoIcons.chat_bubble_fill,
                iconColor: Color(0xFF0084FF),
                title: 'Chats',
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildProfileSection(
            [
              _buildProfileTile(
                icon: CupertinoIcons.info_circle_fill,
                iconColor: Color(0xFF0084FF),
                title: 'About',
              ),
              _buildProfileTile(
                icon: CupertinoIcons.question_circle_fill,
                iconColor: Color(0xFF0084FF),
                title: 'Help',
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildProfileSection(
            [
              _buildProfileTile(
                icon: CupertinoIcons.power,
                iconColor: CupertinoColors.systemRed,
                title: 'Log Out',
                showChevron: false,
              ),
            ],
          ),
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

  Widget _buildProfileTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    bool showChevron = true,
    bool showBadge = false,
  }) {
    return CupertinoListTile(
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
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showBadge)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF0084FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'New',
                style: TextStyle(color: CupertinoColors.white, fontSize: 11),
              ),
            ),
          if (showChevron) const SizedBox(width: 8),
          if (showChevron)
            const Icon(
              CupertinoIcons.chevron_right,
              color: CupertinoColors.systemGrey3,
            ),
        ],
      ),
    );
  }
}