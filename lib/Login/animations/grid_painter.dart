import 'package:flutter/material.dart';

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