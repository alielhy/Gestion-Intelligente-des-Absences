import 'package:flutter/cupertino.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Help'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: const [
              Text(
                'How to Use the Smart Attendance App',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text(
                '1. Navigate to the "Classes" tab and import your student list.\n'
                '2. After importing, you will be redirected to the Scan tab.\n'
                '3. Use your camera to scan student faces for attendance.\n'
                '4. The system will automatically match faces with registered data and mark attendance.\n'
                '5. Review attendance records under each class detail page.',
              ),
              SizedBox(height: 24),
              Text(
                'Troubleshooting',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text(
                '• Ensure camera permissions are enabled.\n'
                '• Make sure students are registered with clear facial images.\n'
                '• If scan doesn’t detect a student, try better lighting or adjust camera angle.',
              ),
              SizedBox(height: 24),
              Text(
                'Contact Support',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text(
                'For technical support or feedback, contact: support@smartattendance.app',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
