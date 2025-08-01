import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signature/signature.dart';
import '../controllers/design_controller.dart';

class SketchCanvas extends StatelessWidget {
  final DesignController controller = Get.find<DesignController>();

  SketchCanvas({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentSide = controller.selectedSide.value;
      final sideName = controller.sideNames[currentSide];

      return Stack(
        children: [
          // Background T-shirt image
          _buildTShirtBackground(sideName),

          // Signature canvas with clipping
          _buildSignatureCanvas(),

          // Side label
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                sideName,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildTShirtBackground(String sideName) {
    String imagePath;
    switch (sideName) {
      case 'Front':
        imagePath = 'assets/images/front.png';
        break;
      case 'Back':
        imagePath = 'assets/images/back.png';
        break;
      case 'Left':
        imagePath = 'assets/images/side.png';
        break;
      case 'Right':
        imagePath = 'assets/images/full-side.png';
        break;
      default:
        imagePath = 'assets/images/front.png';
    }

    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Image.asset(
        imagePath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // Fallback to custom painter if images not found
          return CustomPaint(painter: TShirtPainter(sideName));
        },
      ),
    );
  }

  Widget _buildSignatureCanvas() {
    return Obx(() {
      final sideName = controller.sideNames[controller.selectedSide.value];
      return ClipPath(
        clipper: TShirtClipper(sideName),
        child: Signature(
          controller: controller.getCurrentController(),
          backgroundColor: Colors.transparent,
          width: double.infinity,
          height: double.infinity,
        ),
      );
    });
  }
}

// Custom painter for t-shirt background
class TShirtPainter extends CustomPainter {
  final String sideName;

  TShirtPainter(this.sideName);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw t-shirt shape based on side
    final path = _getTShirtPath(size, sideName);

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  Path _getTShirtPath(Size size, String sideName) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    switch (sideName) {
      case 'Front':
      case 'Back':
        return _getFrontBackPath(size, centerX, centerY);
      case 'Left':
      case 'Right':
        return _getSidePath(size, centerX, centerY);
      default:
        return _getFrontBackPath(size, centerX, centerY);
    }
  }

  Path _getFrontBackPath(Size size, double centerX, double centerY) {
    final path = Path();
    final width = size.width * 0.7;
    final height = size.height * 0.8;
    final startX = centerX - width / 2;
    final startY = centerY - height / 2;

    // T-shirt body
    path.moveTo(startX + width * 0.2, startY);
    path.lineTo(startX + width * 0.8, startY);
    path.lineTo(startX + width, startY + height * 0.15);
    path.lineTo(startX + width, startY + height);
    path.lineTo(startX, startY + height);
    path.lineTo(startX, startY + height * 0.15);
    path.close();

    // Neckline
    final neckPath = Path();
    neckPath.addOval(
      Rect.fromCenter(
        center: Offset(centerX, startY + height * 0.1),
        width: width * 0.3,
        height: height * 0.1,
      ),
    );

    return Path.combine(PathOperation.difference, path, neckPath);
  }

  Path _getSidePath(Size size, double centerX, double centerY) {
    final path = Path();
    final width = size.width * 0.5;
    final height = size.height * 0.8;
    final startX = centerX - width / 2;
    final startY = centerY - height / 2;

    // Side view - more rectangular
    path.moveTo(startX, startY + height * 0.1);
    path.lineTo(startX + width * 0.8, startY);
    path.lineTo(startX + width, startY + height * 0.15);
    path.lineTo(startX + width, startY + height);
    path.lineTo(startX, startY + height);
    path.close();

    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom clipper to restrict drawing to t-shirt area
class TShirtClipper extends CustomClipper<Path> {
  final String sideName;

  TShirtClipper(this.sideName);

  @override
  Path getClip(Size size) {
    switch (sideName) {
      case 'Right': // Image 1 - Side view (right)
        return _getSideViewClip(size);
      case 'Front': // Image 2 - Front view
        return _getFrontViewClip(size);
      case 'Back': // Image 3 - Back view
        return _getBackViewClip(size);
      case 'Left': // Image 4 - Front view (duplicate)
        return _getFrontViewClip(size);
      default:
        return _getFrontViewClip(size);
    }
  }

  Path _getFrontViewClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;

    // Based on your front/back t-shirt images
    // Start from top-left shoulder
    path.moveTo(w * 0.25, h * 0.15); // Left shoulder start

    // Neckline curve
    path.quadraticBezierTo(
      w * 0.35,
      h * 0.05,
      w * 0.5,
      h * 0.08,
    ); // Left neck curve
    path.quadraticBezierTo(
      w * 0.65,
      h * 0.05,
      w * 0.75,
      h * 0.15,
    ); // Right neck curve

    // Right shoulder to armpit
    path.lineTo(w * 0.85, h * 0.25); // Right armpit

    // Right side seam
    path.lineTo(w * 0.82, h * 0.9); // Right bottom

    // Bottom hem
    path.lineTo(w * 0.18, h * 0.9); // Left bottom

    // Left side seam
    path.lineTo(w * 0.15, h * 0.25); // Left armpit

    // Close path
    path.close();

    return path;
  }

  Path _getBackViewClip(Size size) {
    // Back view is very similar to front, just slightly different neckline
    final path = Path();
    final w = size.width;
    final h = size.height;

    // Start from top-left shoulder
    path.moveTo(w * 0.25, h * 0.12); // Left shoulder start

    // Back neckline (higher than front)
    path.quadraticBezierTo(w * 0.4, h * 0.05, w * 0.5, h * 0.05);
    path.quadraticBezierTo(w * 0.6, h * 0.05, w * 0.75, h * 0.12);

    // Right shoulder to armpit
    path.lineTo(w * 0.85, h * 0.25);

    // Right side seam
    path.lineTo(w * 0.82, h * 0.9);

    // Bottom hem
    path.lineTo(w * 0.18, h * 0.9);

    // Left side seam
    path.lineTo(w * 0.15, h * 0.25);

    path.close();
    return path;
  }

  Path _getSideViewClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;

    // Side view is narrower
    // Start from shoulder
    path.moveTo(w * 0.2, h * 0.15); // Left shoulder

    // Top of sleeve
    path.quadraticBezierTo(w * 0.4, h * 0.05, w * 0.6, h * 0.15);

    // Right side of shirt
    path.lineTo(w * 0.75, h * 0.25); // Armpit area
    path.lineTo(w * 0.7, h * 0.9); // Right bottom

    // Bottom
    path.lineTo(w * 0.3, h * 0.9); // Left bottom

    // Left side
    path.lineTo(w * 0.25, h * 0.25); // Left armpit

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
