import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'app.dart'; // <- this is your correct app entry with camera support

late List<CameraDescription> cameras;


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras(); // ✅ get cameras before runApp
  runApp(MyApp(cameras: cameras)); // ✅ pass cameras to your main app
}
