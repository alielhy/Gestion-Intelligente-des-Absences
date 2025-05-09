import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;
import 'package:provider/provider.dart';
import '../../utils/attendance_log.dart';


class ScanTab extends StatefulWidget {
  final List<CameraDescription> cameras;
  final List<String> studentList;

  const ScanTab({
    super.key, 
    required this.cameras,
    required this.studentList,
  });

  @override
  State<ScanTab> createState() => _ScanTabState();
}

class _ScanTabState extends State<ScanTab> {
  late CameraController _controller;
  bool _isCameraInitialized = false;
  bool _isDetecting = false;
  bool _isFrontCamera = true;
  Timer? _detectionTimer;
  int _faceCount = 0;
  List<Face> _currentFaces = [];
  List<String> _recognizedNames = [];
  bool _isProcessing = false;
  final Set<String> _sessionRecognizedNames = {}; // To avoid duplicates


  @override
  void initState() {
    super.initState();
    _initializeCamera(_isFrontCamera);
  }

  Future<void> _initializeCamera(bool useFrontCamera) async {
    try {
      final camera = widget.cameras.firstWhere(
        (camera) => camera.lensDirection ==
            (useFrontCamera ? CameraLensDirection.front : CameraLensDirection.back),
      );

      if (_isCameraInitialized) {
        _detectionTimer?.cancel();
        await _controller.dispose();
      }

      _controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _controller.initialize();
      await _controller.setFlashMode(FlashMode.off);

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
          _faceCount = 0;
          _currentFaces = [];
          _recognizedNames = [];
          _isDetecting = false;
        });
        _startLiveDetection();
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
      if (mounted) {
        setState(() => _isCameraInitialized = false);
      }
    }
  }

  Future<void> _switchCamera() async {
    setState(() {
      _isCameraInitialized = false;
      _isFrontCamera = !_isFrontCamera;
    });
    await _initializeCamera(_isFrontCamera);
  }

  Future<List<String>> _sendImageToBackend(String imagePath) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.100.66:5000/recognize_multiple'),
      );

      request.files.add(await http.MultipartFile.fromPath(
        'image',
        imagePath,
      ));

      var response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final data = json.decode(responseBody);
        return List<String>.from(data['recognized_students']);
      } else {
        debugPrint('Recognition failed: ${response.statusCode}');
        return ['Error'];
      }
    } catch (e) {
      debugPrint('Error sending to backend: $e');
      return ['Error'];
    }
  }

  Future<File> _cropFaceFromImage(File originalImage, Face face) async {
    final originalImageData = await originalImage.readAsBytes();
    final image = img.decodeImage(originalImageData)!;

    final rect = face.boundingBox;
    final x = rect.left.toInt();
    final y = rect.top.toInt();
    final width = (rect.right - rect.left).toInt();
    final height = (rect.bottom - rect.top).toInt();

    final croppedImage = img.copyCrop(
      image,
      x: x,
      y: y,
      width: width,
      height: height,
    );

    final croppedFile = File('${originalImage.path}_cropped.jpg');
    await croppedFile.writeAsBytes(img.encodeJpg(croppedImage));

    return croppedFile;
  }

  void _startLiveDetection() {
    _detectionTimer?.cancel();
    _detectionTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (!_controller.value.isInitialized || _isDetecting || _isProcessing) return;

      _isDetecting = true;
      try {
        final image = await _controller.takePicture();
        final faceDetector = FaceDetector(options: FaceDetectorOptions());
        final faces = await faceDetector.processImage(InputImage.fromFilePath(image.path));

        if (faces.isNotEmpty && mounted) {
          setState(() {
            _faceCount = faces.length;
            _currentFaces = faces;
          });

          setState(() => _isProcessing = true);
          try {
            List<String> recognizedNames = [];
            for (final face in faces) {
              final croppedFile = await _cropFaceFromImage(File(image.path), face);
              final names = await _sendImageToBackend(croppedFile.path);
              recognizedNames.addAll(names);
              await croppedFile.delete();
            }

            if (mounted) {
              setState(() {
                _recognizedNames = recognizedNames;
              });
              await _handleRecognizedNames(recognizedNames);
            }
          } finally {
            setState(() => _isProcessing = false);
          }
        }

        await File(image.path).delete();
      } catch (e) {
        debugPrint('Detection error: $e');
      } finally {
        _isDetecting = false;
      }
    });
  }

  Future<void> _handleRecognizedNames(List<String> names) async {
    final newNames = <String>[];

    for (final name in names) {
      if (!_sessionRecognizedNames.contains(name)) {
        _sessionRecognizedNames.add(name);
        newNames.add(name);
      }
    }

    if (newNames.isNotEmpty) {
      await Provider.of<AttendanceLog>(context, listen: false)
          .addRecognitionResult(newNames);
      debugPrint("Added to attendance log: $newNames");
    }

    setState(() {
      _recognizedNames = names;
    });
  }

  Widget _buildFaceBoxes() {
    if (_currentFaces.isEmpty) return Container();

    final screen = MediaQuery.of(context).size;
    final previewSize = _controller.value.previewSize!;
    final scaleX = screen.width / previewSize.height;
    final scaleY = screen.height / previewSize.width;

    return Stack(
      children: _currentFaces.asMap().entries.map((entry) {
        final index = entry.key;
        final face = entry.value;
        final rect = face.boundingBox;
        
        String name = 'Unknown';
        if (index < _recognizedNames.length) {
          name = _recognizedNames[index];
        }

        return Positioned(
          left: (previewSize.width - rect.bottom) * scaleX,
          top: rect.left * scaleY,
          width: (rect.top - rect.bottom).abs() * scaleX,
          height: (rect.right - rect.left).abs() * scaleY,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red, width: 2),
                ),
              ),
              Container(
                color: Colors.black.withOpacity(0.5),
                padding: const EdgeInsets.all(4),
                child: Text(
                  name,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildControls() {
    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: Column(
        children: [
          Text(
            'Detected Faces: $_faceCount',
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
          if (_isProcessing)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _detectionTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (_isCameraInitialized) CameraPreview(_controller),
          if (_isCameraInitialized) _buildFaceBoxes(),
          if (!_isCameraInitialized) const Center(child: CircularProgressIndicator()),
          _buildControls(),
          Positioned(
            top: 60,
            right: 20,
            child: GestureDetector(
              onTap: _switchCamera,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.cameraswitch, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}