import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:absent_detector/Home/home_page.dart';
import 'dart:math' as math;

import 'login_panel.dart';
import 'package:absent_detector/Login/animations/face_detection_marker.dart';
import 'package:absent_detector/Login/animations/grid_painter.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> with SingleTickerProviderStateMixin {
  bool showLogin = false;
  late AnimationController _animationController;
  late Animation<double> _floatingAnimation;
  late Animation<double> _logoAnimation;
  
  // Animation controllers for the scanning effect
  final List<AnimatedFaceMarker> _faceMarkers = [];
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
    
    _floatingAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _logoAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    // Create animated face markers for background
    _createFaceMarkers();
    
    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  }
  
  void _createFaceMarkers() {
    final random = math.Random();
    for (int i = 0; i < 6; i++) {
      _faceMarkers.add(
        AnimatedFaceMarker(
          position: Offset(
            random.nextDouble() * 0.8 + 0.1, // x between 10% and 90%
            random.nextDouble() * 0.6 + 0.2, // y between 20% and 80%
          ),
          delay: Duration(milliseconds: random.nextInt(2000)),
          size: random.nextDouble() * 20 + 50, // size between 50-70
        ),
      );
    }
  }

  void toggleLogin(bool visible) {
    setState(() {
      showLogin = visible;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: GestureDetector(
        onTap: () {
          if (showLogin) toggleLogin(false);
        },
        child: Stack(
          children: [
            // Animated Background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0084FF), // WhatsApp iOS blue 
                    Color(0xFF0084FF).withOpacity(0.7),
                    Colors.indigo.shade700,
                  ],
                  stops: const [0.1, 0.5, 0.9],
                ),
              ),
            ),
            
            // Animated face detection markers in background
            ..._faceMarkers.map((marker) => AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Positioned(
                  left: width * marker.position.dx,
                  top: height * marker.position.dy,
                  child: Opacity(
                    opacity: 0.15,
                    child: FaceDetectionMarker(
                      size: marker.size,
                      progress: _animationController.value,
                      delay: marker.delay,
                    ),
                  ),
                );
              },
            )),
            
            // Animated grid pattern
            Opacity(
              opacity: 0.1,
              child: CustomPaint(
                painter: GridPainter(_animationController),
                size: Size(width, height),
              ),
            ),
            
            // Welcome Content
            AnimatedOpacity(
              duration: const Duration(milliseconds: 400),
              opacity: showLogin ? 0.2 : 1,
              child: AnimatedPadding(
                duration: const Duration(milliseconds: 400),
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.1, 
                  vertical: height * (showLogin ? 0.05 : 0.1)
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(flex: 1),
                    Center(
                      child: AnimatedBuilder(
                        animation: _logoAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _logoAnimation.value,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.face_retouching_natural,
                                  size: 70,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 30),
                    Center(
                      child: Text(
                        "Smart Attendance",
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 10,
                              color: Colors.black.withOpacity(0.3),
                              offset: const Offset(2, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: AnimatedBuilder(
                        animation: _floatingAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _floatingAnimation.value * 0.2),
                            child: Text(
                              "Facial recognition for accurate\nstudent attendance tracking",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white.withOpacity(0.95),
                                height: 1.5,
                                shadows: [
                                  Shadow(
                                    blurRadius: 5,
                                    color: Colors.black.withOpacity(0.2),
                                    offset: const Offset(1, 1),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const Spacer(flex: 2),
                    AnimatedBuilder(
                      animation: _floatingAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _floatingAnimation.value * 0.3),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => toggleLogin(true),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                backgroundColor: Colors.white,
                                foregroundColor: Color(0xFF0084FF),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 8,
                              ),
                              child: const Text(
                                'Get Started',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // Login Panel
            if (showLogin)
              LoginPanel(
                onClose: () => toggleLogin(false),
                animationController: _animationController,
              ),
          ],
        ),
      ),
    );
  }
}