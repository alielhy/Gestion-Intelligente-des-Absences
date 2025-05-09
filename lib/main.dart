import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'app.dart';

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    cameras = await availableCameras();
    runApp(MyApp(cameras: cameras));
  } catch (e) {
    // Handle camera initialization errors
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Failed to initialize camera: $e'),
          ),
        ),
      ),
    );
  }
}