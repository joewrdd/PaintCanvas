import 'dart:math' as math;
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_drawing_board/paint_contents.dart';
import 'package:flutter_drawing_board/paint_extension.dart';

class Star extends PaintContent {
  Star();

  Star.data({
    required this.startPoint,
    required this.endPoint,
    required Paint paint,
  }) : super.paint(paint);

  factory Star.fromJson(Map<String, dynamic> data) {
    return Star.data(
      startPoint: jsonToOffset(data['startPoint'] as Map<String, dynamic>),
      endPoint: jsonToOffset(data['endPoint'] as Map<String, dynamic>),
      paint: jsonToPaint(data['paint'] as Map<String, dynamic>),
    );
  }

  Offset startPoint = Offset.zero;
  Offset endPoint = Offset.zero;

  @override
  String get contentType => 'Star';

  @override
  void startDraw(Offset startPoint) => this.startPoint = startPoint;

  @override
  void drawing(Offset nowPoint) => endPoint = nowPoint;

  @override
  void draw(Canvas canvas, Size size, bool deeper) {
    final center = Offset(
      (startPoint.dx + endPoint.dx) / 2,
      (startPoint.dy + endPoint.dy) / 2,
    );

    final radius = (endPoint - startPoint).distance / 2;
    final innerRadius = radius * 0.4;

    final path = Path();
    const numPoints = 5;

    for (int i = 0; i < numPoints * 2; i++) {
      final angle = (i * math.pi) / numPoints - math.pi / 2;
      final r = i.isEven ? radius : innerRadius;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  Star copy() => Star();

  @override
  Map<String, dynamic> toContentJson() {
    return <String, dynamic>{
      'startPoint': startPoint.toJson(),
      'endPoint': endPoint.toJson(),
      'paint': paint.toJson(),
    };
  }
}

class Arrow extends PaintContent {
  Arrow();

  Arrow.data({
    required this.startPoint,
    required this.endPoint,
    required Paint paint,
  }) : super.paint(paint);

  factory Arrow.fromJson(Map<String, dynamic> data) {
    return Arrow.data(
      startPoint: jsonToOffset(data['startPoint'] as Map<String, dynamic>),
      endPoint: jsonToOffset(data['endPoint'] as Map<String, dynamic>),
      paint: jsonToPaint(data['paint'] as Map<String, dynamic>),
    );
  }

  Offset startPoint = Offset.zero;
  Offset endPoint = Offset.zero;

  @override
  String get contentType => 'Arrow';

  @override
  void startDraw(Offset startPoint) => this.startPoint = startPoint;

  @override
  void drawing(Offset nowPoint) => endPoint = nowPoint;

  @override
  void draw(Canvas canvas, Size size, bool deeper) {
    final path = Path();

    final dx = endPoint.dx - startPoint.dx;
    final dy = endPoint.dy - startPoint.dy;
    final angle = math.atan2(dy, dx);

    const arrowLength = 20.0;
    const arrowAngle = 0.5;

    path.moveTo(startPoint.dx, startPoint.dy);
    path.lineTo(endPoint.dx, endPoint.dy);

    final arrowX1 = endPoint.dx - arrowLength * math.cos(angle - arrowAngle);
    final arrowY1 = endPoint.dy - arrowLength * math.sin(angle - arrowAngle);
    final arrowX2 = endPoint.dx - arrowLength * math.cos(angle + arrowAngle);
    final arrowY2 = endPoint.dy - arrowLength * math.sin(angle + arrowAngle);

    path.moveTo(endPoint.dx, endPoint.dy);
    path.lineTo(arrowX1, arrowY1);
    path.moveTo(endPoint.dx, endPoint.dy);
    path.lineTo(arrowX2, arrowY2);

    canvas.drawPath(path, paint);
  }

  @override
  Arrow copy() => Arrow();

  @override
  Map<String, dynamic> toContentJson() {
    return <String, dynamic>{
      'startPoint': startPoint.toJson(),
      'endPoint': endPoint.toJson(),
      'paint': paint.toJson(),
    };
  }
}

class TextContent extends PaintContent {
  TextContent({this.text = 'Sample Text'});

  TextContent.data({
    required this.startPoint,
    required this.text,
    required Paint paint,
  }) : super.paint(paint);

  factory TextContent.fromJson(Map<String, dynamic> data) {
    return TextContent.data(
      startPoint: jsonToOffset(data['startPoint'] as Map<String, dynamic>),
      text: data['text'] as String,
      paint: jsonToPaint(data['paint'] as Map<String, dynamic>),
    );
  }

  Offset startPoint = Offset.zero;
  String text = 'Sample Text';

  @override
  String get contentType => 'TextContent';

  @override
  void startDraw(Offset startPoint) => this.startPoint = startPoint;

  @override
  void drawing(Offset nowPoint) {}

  @override
  void draw(Canvas canvas, Size size, bool deeper) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: paint.color,
          fontSize: paint.strokeWidth * 4,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(canvas, startPoint);
  }

  @override
  TextContent copy() => TextContent(text: text);

  @override
  Map<String, dynamic> toContentJson() {
    return <String, dynamic>{
      'startPoint': startPoint.toJson(),
      'text': text,
      'paint': paint.toJson(),
    };
  }
}

class ImportedImageContent extends PaintContent {
  ImportedImageContent({this.image, this.imageBytes});

  ImportedImageContent.data({
    required this.startPoint,
    required this.endPoint,
    required this.image,
    required this.imageBytes,
    required Paint paint,
  }) : super.paint(paint);

  factory ImportedImageContent.fromJson(Map<String, dynamic> data) {
    final imageBytes = data['imageBytes'] != null
        ? Uint8List.fromList((data['imageBytes'] as List).cast<int>())
        : null;

    return ImportedImageContent.data(
      startPoint: jsonToOffset(data['startPoint'] as Map<String, dynamic>),
      endPoint: jsonToOffset(data['endPoint'] as Map<String, dynamic>),
      image: null, // Will be loaded from bytes
      imageBytes: imageBytes,
      paint: jsonToPaint(data['paint'] as Map<String, dynamic>),
    );
  }

  Offset startPoint = Offset.zero;
  Offset endPoint = Offset.zero;
  ui.Image? image;
  Uint8List? imageBytes;

  @override
  String get contentType => 'ImportedImageContent';

  @override
  void startDraw(Offset startPoint) => this.startPoint = startPoint;

  @override
  void drawing(Offset nowPoint) => endPoint = nowPoint;

  @override
  void draw(Canvas canvas, Size size, bool deeper) {
    if (image == null) return;

    final rect = Rect.fromPoints(startPoint, endPoint);
    if (rect.width.abs() < 10 || rect.height.abs() < 10) {
      // Default size if user hasn't dragged much
      final defaultSize = Size(
        image!.width.toDouble(),
        image!.height.toDouble(),
      );
      final scaledSize = _getScaledSize(defaultSize, const Size(200, 200));
      final adjustedRect = Rect.fromLTWH(
        startPoint.dx,
        startPoint.dy,
        scaledSize.width,
        scaledSize.height,
      );
      paintImage(
        canvas: canvas,
        rect: adjustedRect,
        image: image!,
        fit: BoxFit.contain,
      );
    } else {
      paintImage(
        canvas: canvas,
        rect: rect,
        image: image!,
        fit: BoxFit.contain,
      );
    }
  }

  Size _getScaledSize(Size originalSize, Size maxSize) {
    final double scaleX = maxSize.width / originalSize.width;
    final double scaleY = maxSize.height / originalSize.height;
    final double scale = math.min(scaleX, scaleY);

    return Size(originalSize.width * scale, originalSize.height * scale);
  }

  @override
  ImportedImageContent copy() =>
      ImportedImageContent(image: image, imageBytes: imageBytes);

  @override
  Map<String, dynamic> toContentJson() {
    return <String, dynamic>{
      'startPoint': startPoint.toJson(),
      'endPoint': endPoint.toJson(),
      'imageBytes': imageBytes?.toList(),
      'paint': paint.toJson(),
    };
  }
}
