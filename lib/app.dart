import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'Home/home_page.dart';
import 'Login/screens/welcome_screen.dart';
import 'utils/attendance_log.dart';

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;
  
  const MyApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AttendanceLog()),
        Provider.value(value: cameras),
      ],
      child: CupertinoApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey, // Attach navigatorKey
        theme: const CupertinoThemeData(
          primaryColor: Color(0xFF0084FF),
          barBackgroundColor: CupertinoColors.white,
          scaffoldBackgroundColor: CupertinoColors.systemGroupedBackground,
          primaryContrastingColor: CupertinoColors.white,
        ),
        home: FutureBuilder(
          future: _initializeApp(context),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return const WelcomePage();
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Future<void> _initializeApp(BuildContext context) async {
    // Initialize services safely
    try {
      await Provider.of<AttendanceLog>(context, listen: false).initialize();
    } catch (e) {
      print("Error initializing AttendanceLog: $e");
    }
  }
}

// Global key for navigation access
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();