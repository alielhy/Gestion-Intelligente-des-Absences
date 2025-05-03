import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import './ml_face_detector.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class ScanTab extends StatefulWidget {
  final List<CameraDescription> cameras;
  const ScanTab({super.key, required this.cameras});

  @override
  State<ScanTab> createState() => _ScanTabState();
}

class _ScanTabState extends State<ScanTab> {
  late CameraController _controller;
  bool _isCameraInitialized = false;
  bool _isDetecting = false;
  bool _isRecording = false;
  bool _isFrontCamera = true;
  Timer? _detectionTimer;
  int _faceCount = 0;
  List<Face> _currentFaces = [];
  final MLFaceDetector _faceDetector = MLFaceDetector();

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

    // Stop any ongoing detection and dispose controller if initialized
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

    // Set the flash mode to off
    await _controller.setFlashMode(FlashMode.off);

    if (mounted) {
      setState(() {
        _isCameraInitialized = true;
        _faceCount = 0;
        _currentFaces.clear();
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

  void _startLiveDetection() {
    _detectionTimer?.cancel();
    _detectionTimer = Timer.periodic(const Duration(milliseconds: 600), (timer) async {
      if (!_controller.value.isInitialized || _isDetecting) return;

      _isDetecting = true;
      try {
        final image = await _controller.takePicture();
        final faces = await _faceDetector.detectFaces(image.path);

        if (mounted) {
          setState(() {
            _faceCount = faces.length;
            _currentFaces = faces;
          });
        }

        await File(image.path).delete();
      } catch (e) {
        debugPrint('Detection error: $e');
      } finally {
        _isDetecting = false;
      }
    });
  }

  Future<void> _capturePhoto() async {
    try {
      final image = await _controller.takePicture();
      final faces = await _faceDetector.detectFaces(image.path);
      if (mounted) {
        setState(() {
          _faceCount = faces.length;
          _currentFaces = faces;
        });
      }
    } catch (e) {
      debugPrint('Capture failed: $e');
    }
  }

  Future<void> _toggleRecording() async {
    try {
      if (_isRecording) {
        await _controller.stopVideoRecording();
      } else {
        await _controller.prepareForVideoRecording();
        await _controller.startVideoRecording();
      }

      if (mounted) {
        setState(() => _isRecording = !_isRecording);
      }
    } catch (e) {
      debugPrint('Video error: $e');
    }
  }

  @override
  void dispose() {
    _detectionTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Widget _buildFaceBoxes() {
    if (_currentFaces.isEmpty) return Container();

    final screen = MediaQuery.of(context).size;
    final previewSize = _controller.value.previewSize!;
    final scaleX = screen.width / previewSize.height;
    final scaleY = screen.height / previewSize.width;

    return Stack(
      children: _currentFaces.map((face) {
        final rect = face.boundingBox;
        return Positioned(
          left: (previewSize.width - rect.bottom) * scaleX,
          top: rect.left * scaleY,
          width: (rect.top - rect.bottom).abs() * scaleX,
          height: (rect.right - rect.left).abs() * scaleY,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.red, width: 2),
            ),
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
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: _capturePhoto,
                icon: const Icon(Icons.camera_alt),
                label: const Text("Capture"),
              ),
              ElevatedButton.icon(
                onPressed: _toggleRecording,
                icon: Icon(_isRecording ? Icons.stop : Icons.videocam),
                label: Text(_isRecording ? "Stop" : "Record"),
              ),
            ],
          ),
        ],
      ),
    );
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
