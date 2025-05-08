import 'package:flutter/material.dart';

// Helper class for face detection animation
class AnimatedFaceMarker {
  final Offset position;
  final Duration delay;
  final double size;
  
  AnimatedFaceMarker({
    required this.position,
    required this.delay,
    required this.size,
  });
}

// Face detection marker widget
class FaceDetectionMarker extends StatelessWidget {
  final double size;
  final double progress;
  final Duration delay;
  
  const FaceDetectionMarker({
    super.key,
    required this.size,
    required this.progress,
    required this.delay,
  });
  
  @override
  Widget build(BuildContext context) {
    // Calculate a delayed progress based on the delay
    final delayedProgress = (progress + delay.inMilliseconds / 3000) % 1.0;
    
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Outer circle
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.6),
                width: 1.5,
              ),
            ),
          ),
          
          // Face outline
          Center(
            child: Container(
              width: size * 0.7,
              height: size * 0.7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.8),
                  width: 1,
                  strokeAlign: BorderSide.strokeAlignOutside,
                ),
              ),
            ),
          ),
          
          // Scanning effect
          Positioned.fill(
            child: Center(
              child: Container(
                width: size * delayedProgress,
                height: 1.5,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ),
          
          // Face features
          Center(
            child: Container(
              width: size * 0.35,
              height: size * 0.15,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withOpacity(0.8),
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
          
          // Eye points
          Positioned(
            top: size * 0.3,
            left: size * 0.3,
            child: Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                shape: BoxShape.circle,
              ),
            ),
          ),
          
          Positioned(
            top: size * 0.3,
            right: size * 0.3,
            child: Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                shape: BoxShape.circle,
              ),
            ),
          ),
          
          // Scan line indicator
          Positioned(
            left: -5,
            top: size * delayedProgress,
            child: Container(
              width: 5,
              height: 2,
              color: Colors.white,
            ),
          ),
          
          Positioned(
            right: -5,
            top: size * delayedProgress,
            child: Container(
              width: 5,
              height: 2,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}