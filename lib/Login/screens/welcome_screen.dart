import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:absent_detector/Home/home_page.dart';
import 'dart:math' as math;

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> with SingleTickerProviderStateMixin {
  bool showLogin = false;
  bool _obscurePassword = true;
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

  void _navigateToHomePage(BuildContext context) {
    // Add a loading animation
    setState(() {
      _isLoading = true;
    });
    
    // Simulate a loading delay
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => 
              HomePage(cameras: const []),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(0.0, 1.0);
              const end = Offset.zero;
              const curve = Curves.easeOutQuint;
              
              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);
              
              return SlideTransition(
                position: offsetAnimation,
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }
  
  bool _isLoading = false;

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
            AnimatedPositioned(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutBack,
              bottom: showLogin ? 0 : -height * 0.7,
              left: 0,
              right: 0,
              height: height * 0.7,
              child: GestureDetector(
                onTap: () {}, // Prevent taps from closing the panel
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 30,
                        offset: const Offset(0, -10),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 60,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Color(0xFF0084FF).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.lock_open_rounded,
                                color: Color(0xFF0084FF),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Welcome Back!",
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black.withOpacity(0.8),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Sign in to continue",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        
                        // Email Field
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 500),
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(0, 20 * (1 - value)),
                                child: child,
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: TextField(
                              decoration: InputDecoration(
                                labelText: 'Email',
                                labelStyle: TextStyle(color: Colors.grey.shade600),
                                hintText: 'Enter your email',
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                prefixIcon: Icon(Icons.email, color: Color(0xFF0084FF)),
                                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Password Field with Visibility Toggle
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 700),
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(0, 20 * (1 - value)),
                                child: child,
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: TextField(
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                labelStyle: TextStyle(color: Colors.grey.shade600),
                                hintText: 'Enter your password',
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                prefixIcon: Icon(Icons.lock, color: Color(0xFF0084FF)),
                                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                    color: Colors.grey.shade600,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: Text(
                              "Forgot Password?",
                              style: TextStyle(
                                color: Color(0xFF0084FF),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Sign In Button
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 900),
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(0, 20 * (1 - value)),
                                child: child,
                              ),
                            );
                          },
                          child: SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : () => _navigateToHomePage(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF0084FF),
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: Color(0xFF0084FF).withOpacity(0.6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 8,
                              ),
                              child: _isLoading
                                ? SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'Sign In',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 30),
                        Center(
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                              children: [
                                TextSpan(text: "Don't have an account? "),
                                TextSpan(
                                  text: "Contact Admin",
                                  style: TextStyle(
                                    color: Color(0xFF0084FF),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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

// Grid painter for tech background effect
class GridPainter extends CustomPainter {
  final Animation<double> animation;
  
  GridPainter(this.animation) : super(repaint: animation);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;
      
    const cellSize = 40.0;
    final widthCount = size.width ~/ cellSize;
    final heightCount = size.height ~/ cellSize;
    
    // Draw horizontal lines
    for (int i = 0; i <= heightCount; i++) {
      final y = i * cellSize;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    
    // Draw vertical lines
    for (int i = 0; i <= widthCount; i++) {
      final x = i * cellSize;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    
    // Draw animated dot
    final dotPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.fill;
      
    final dotSize = 3.0;
    final xPos = (animation.value * widthCount) % widthCount * cellSize;
    final yPos = (animation.value * heightCount) % heightCount * cellSize;
    
    canvas.drawCircle(Offset(xPos, yPos), dotSize, dotPaint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}