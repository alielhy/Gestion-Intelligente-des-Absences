import 'package:flutter/cupertino.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('About'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: const [
              Text(
                'About Smart Attendance',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text(
                'Smart Attendance is a facial recognition-based attendance tracking app designed for educational institutions.\n\n'
                'It allows teachers to automate attendance by simply scanning the classroom. The app uses advanced machine learning algorithms to detect and identify students based on pre-registered photos.\n\n'
                'This solution saves time, reduces errors, and improves classroom management efficiency.',
              ),
              SizedBox(height: 24),
              Text(
                'Key Features',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text(
                '• Facial recognition attendance\n'
                '• Real-time detection\n'
                '• Import/export class lists\n'
                '• Detailed attendance reports\n'
                '• Role-based access (Teacher/Admin)',
              ),
              SizedBox(height: 24),
              Text(
                'Version',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text('Smart Attendance v1.0'),
            ],
          ),
        ),
      ),
    );
  }
}
