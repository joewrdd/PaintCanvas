import 'dart:math' as math;
import 'package:flutter/material.dart';

extension DoubleExtensions on double {
  double get cos => math.cos(this);
  double get sin => math.sin(this);
  double atan2(double x) => math.atan2(this, x);
}

class TShirt3DPainter extends CustomPainter {
  final String tshirtColor;
  final double rotationX;
  final double rotationY;
  final String currentSide;
  final bool showWireframe;

  TShirt3DPainter({
    required this.tshirtColor,
    required this.rotationX,
    required this.rotationY,
    required this.currentSide,
    this.showWireframe = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Apply 3D perspective transformation
    canvas.save();
    canvas.translate(center.dx, center.dy);

    // Create perspective effect
    final perspective = Matrix4.identity()
      ..setEntry(3, 2, 0.001) // Perspective
      ..rotateX(rotationX * math.pi / 180)
      ..rotateY(rotationY * math.pi / 180);

    canvas.transform(perspective.storage);
    canvas.translate(-center.dx, -center.dy);

    // Draw T-shirt based on current side visibility
    _drawTShirt(canvas, size, center);

    canvas.restore();
  }

  void _drawTShirt(Canvas canvas, Size size, Offset center) {
    final paint = Paint()
      ..color = _getTShirtColor()
      ..style = PaintingStyle.fill;

    final outlinePaint = Paint()
      ..color = Colors.grey[400]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // T-shirt dimensions
    final tshirtWidth = size.width * 0.6;
    final tshirtHeight = size.height * 0.7;
    final neckWidth = tshirtWidth * 0.3;
    final sleeveLength = tshirtWidth * 0.4;

    // Calculate T-shirt bounds
    final left = center.dx - tshirtWidth / 2;
    final right = center.dx + tshirtWidth / 2;
    final top = center.dy - tshirtHeight / 2;
    final bottom = center.dy + tshirtHeight / 2;

    // Create T-shirt shape path
    final path = Path();

    // Start from top-left of body
    path.moveTo(left, top + tshirtHeight * 0.2);

    // Left sleeve
    path.lineTo(left - sleeveLength * 0.7, top + tshirtHeight * 0.15);
    path.lineTo(left - sleeveLength, top + tshirtHeight * 0.4);
    path.lineTo(left - sleeveLength * 0.5, top + tshirtHeight * 0.5);
    path.lineTo(left, top + tshirtHeight * 0.45);

    // Left side of body
    path.lineTo(left, bottom);

    // Bottom
    path.lineTo(right, bottom);

    // Right side of body
    path.lineTo(right, top + tshirtHeight * 0.45);

    // Right sleeve
    path.lineTo(right + sleeveLength * 0.5, top + tshirtHeight * 0.5);
    path.lineTo(right + sleeveLength, top + tshirtHeight * 0.4);
    path.lineTo(right + sleeveLength * 0.7, top + tshirtHeight * 0.15);
    path.lineTo(right, top + tshirtHeight * 0.2);

    // Neckline
    path.lineTo(center.dx + neckWidth / 2, top + tshirtHeight * 0.2);
    path.quadraticBezierTo(
      center.dx + neckWidth / 4,
      top + tshirtHeight * 0.1,
      center.dx,
      top + tshirtHeight * 0.15,
    );
    path.quadraticBezierTo(
      center.dx - neckWidth / 4,
      top + tshirtHeight * 0.1,
      center.dx - neckWidth / 2,
      top + tshirtHeight * 0.2,
    );

    path.close();

    // Draw T-shirt with shadow effect
    _drawWithShadow(canvas, path, paint);

    // Draw outline
    canvas.drawPath(path, outlinePaint);

    // Add some 3D depth lines for realism
    if (showWireframe || currentSide != 'front') {
      _drawDepthLines(canvas, size, center, tshirtWidth, tshirtHeight);
    }

    // Draw side indicator
    _drawSideIndicator(canvas, center, tshirtWidth, tshirtHeight);
  }

  void _drawWithShadow(Canvas canvas, Path path, Paint paint) {
    // Draw shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.save();
    canvas.translate(4, 4);
    canvas.drawPath(path, shadowPaint);
    canvas.restore();

    // Draw main T-shirt
    canvas.drawPath(path, paint);
  }

  void _drawDepthLines(
    Canvas canvas,
    Size size,
    Offset center,
    double width,
    double height,
  ) {
    final depthPaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Add some perspective lines to show 3D depth
    final left = center.dx - width / 2;
    final right = center.dx + width / 2;
    final top = center.dy - height / 2;
    final bottom = center.dy + height / 2;

    // Vertical center line
    canvas.drawLine(
      Offset(center.dx, top + height * 0.2),
      Offset(center.dx, bottom),
      depthPaint,
    );

    // Horizontal chest line
    canvas.drawLine(
      Offset(left, center.dy - height * 0.1),
      Offset(right, center.dy - height * 0.1),
      depthPaint,
    );
  }

  void _drawSideIndicator(
    Canvas canvas,
    Offset center,
    double width,
    double height,
  ) {
    // Small indicator showing which side we're viewing
    final indicatorPaint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    final textPainter = TextPainter(
      text: TextSpan(
        text: currentSide.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    final indicatorRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + height * 0.4),
        width: textPainter.width + 16,
        height: textPainter.height + 8,
      ),
      const Radius.circular(8),
    );

    canvas.drawRRect(indicatorRect, indicatorPaint);

    textPainter.paint(
      canvas,
      Offset(
        indicatorRect.center.dx - textPainter.width / 2,
        indicatorRect.center.dy - textPainter.height / 2,
      ),
    );
  }

  Color _getTShirtColor() {
    switch (tshirtColor.toLowerCase()) {
      case 'white':
        return Colors.white;
      case 'black':
        return Colors.grey[900]!;
      case 'gray':
        return Colors.grey[600]!;
      case 'red':
        return Colors.red[400]!;
      case 'blue':
        return Colors.blue[400]!;
      case 'green':
        return Colors.green[400]!;
      case 'yellow':
        return Colors.yellow[400]!;
      case 'purple':
        return Colors.purple[400]!;
      default:
        return Colors.white;
    }
  }

  @override
  bool shouldRepaint(TShirt3DPainter oldDelegate) {
    return oldDelegate.tshirtColor != tshirtColor ||
        oldDelegate.rotationX != rotationX ||
        oldDelegate.rotationY != rotationY ||
        oldDelegate.currentSide != currentSide ||
        oldDelegate.showWireframe != showWireframe;
  }
}

class TShirt3DWidget extends StatelessWidget {
  final String tshirtColor;
  final double rotationX;
  final double rotationY;
  final String currentSide;
  final bool showWireframe;
  final Widget? child;

  const TShirt3DWidget({
    super.key,
    required this.tshirtColor,
    required this.rotationX,
    required this.rotationY,
    required this.currentSide,
    this.showWireframe = false,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateX(rotationX * math.pi / 180)
        ..rotateY(rotationY * math.pi / 180),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // T-shirt background
            CustomPaint(
              painter: TShirt3DPainter(
                tshirtColor: tshirtColor,
                rotationX: rotationX,
                rotationY: rotationY,
                currentSide: currentSide,
                showWireframe: showWireframe,
              ),
              size: Size.infinite,
            ),
            // Drawing surface overlay
            if (child != null) child!,
          ],
        ),
      ),
    );
  }
}

// Helper widget for the drawing surface that follows T-shirt shape
class TShirtDrawingSurface extends StatelessWidget {
  final Widget child;
  final String currentSide;

  const TShirtDrawingSurface({
    super.key,
    required this.child,
    required this.currentSide,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        final center = Offset(size.width / 2, size.height / 2);

        // T-shirt drawing area dimensions
        final drawingWidth = size.width * 0.4;
        final drawingHeight = size.height * 0.5;

        return Positioned(
          left: center.dx - drawingWidth / 2,
          top: center.dy - drawingHeight / 2 + size.height * 0.05,
          width: drawingWidth,
          height: drawingHeight,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: child,
          ),
        );
      },
    );
  }
}
