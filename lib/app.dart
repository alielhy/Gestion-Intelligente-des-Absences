import 'package:flutter/cupertino.dart';
import 'package:camera/camera.dart';
import 'Home/home_page.dart';
import 'Login/screens/welcome_screen.dart';

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;
  
  const MyApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      theme: const CupertinoThemeData(
        primaryColor: Color(0xFF0084FF), // WhatsApp iOS blue
        barBackgroundColor: CupertinoColors.white,
        scaffoldBackgroundColor: CupertinoColors.systemGroupedBackground,
        primaryContrastingColor: CupertinoColors.white,
      ),
      home: WelcomePage(),
    );
  }
}