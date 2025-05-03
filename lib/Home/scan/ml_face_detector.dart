import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;

class MLFaceDetector {
  final FaceDetector _faceDetector;

  MLFaceDetector()
      : _faceDetector = FaceDetector(
          options: FaceDetectorOptions(
            enableClassification: true,
            enableTracking: true,
            performanceMode: FaceDetectorMode.accurate,
          ),
        );

  // Detect faces in a given image
  Future<List<Face>> detectFaces(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      return await _faceDetector.processImage(inputImage);
    } catch (e) {
      debugPrint('Error detecting faces: $e');
      return [];
    }
  }

  // Optional: Draw face bounding boxes on image
  Future<ui.Image> drawFaceBoundingBoxes(String imagePath, List<Face> faces) async {
    final File imageFile = File(imagePath);
    final Uint8List imageBytes = await imageFile.readAsBytes();
    final img.Image? baseSizeImage = img.decodeImage(imageBytes);

    if (baseSizeImage == null) {
      throw Exception('Unable to decode image');
    }

    for (Face face in faces) {
      final rect = face.boundingBox;
      img.drawRect(
        baseSizeImage,
        x1: rect.left.toInt(),
        y1: rect.top.toInt(),
        x2: rect.right.toInt(),
        y2: rect.bottom.toInt(),
        color: img.ColorRgb8(255, 0, 0),
        thickness: 3,
      );
    }

    return await _convertImage(baseSizeImage);
  }

  // Helper to convert image package image to Flutter ui.Image
  Future<ui.Image> _convertImage(img.Image image) async {
    final completer = Completer<ui.Image>();
    final Uint8List bytes = Uint8List.fromList(img.encodePng(image));
    ui.decodeImageFromList(bytes, (ui.Image img) {
      completer.complete(img);
    });
    return completer.future;
  }
}
