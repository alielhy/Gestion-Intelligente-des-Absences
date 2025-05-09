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
        theme: const CupertinoThemeData(
          primaryColor: Color(0xFF0084FF),
          barBackgroundColor: CupertinoColors.white,
          scaffoldBackgroundColor: CupertinoColors.systemGroupedBackground,
          primaryContrastingColor: CupertinoColors.white,
        ),
        home: FutureBuilder(
          future: _initializeApp(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return const WelcomePage();
            }
            return const CupertinoPageScaffold(
              child: Center(child: CupertinoActivityIndicator()),
            );
          },
        ),
      ),
    );
  }

  Future<void> _initializeApp() async {
    // Initialize any necessary services here
    await Provider.of<AttendanceLog>(navigatorKey.currentContext!, listen: false)
        .initialize();
  }
}

// Global key for navigation access
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();