import 'dart:convert';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'package:flutter_drawing_board/paint_contents.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/custom_paint_tools.dart';

class HomeController extends GetxController {
  static HomeController get instance => Get.find();

  late final DrawingController drawingController;
  late final TransformationController transformationController;
  late final ImagePicker _imagePicker;

  final RxDouble strokeWidth = 4.0.obs;
  final RxDouble colorOpacity = 1.0.obs;
  final Rx<Color> selectedColor = Colors.blue.obs;
  final RxBool isEraserMode = false.obs;
  final RxString currentTool = 'SimpleLine'.obs;
  final RxList<String> drawingHistory = <String>[].obs;
  final RxBool canUndo = false.obs;
  final RxBool canRedo = false.obs;

  @override
  void onInit() {
    super.onInit();
    drawingController = DrawingController();
    transformationController = TransformationController();
    _imagePicker = ImagePicker();

    drawingController.addListener(_updateHistoryState);
  }

  @override
  void onClose() {
    drawingController.removeListener(_updateHistoryState);
    drawingController.dispose();
    transformationController.dispose();
    super.onClose();
  }

  void _updateHistoryState() {
    canUndo.value = drawingController.canUndo();
    canRedo.value = drawingController.canRedo();
  }

  void setStrokeWidth(double width) {
    strokeWidth.value = width;
    drawingController.setStyle(strokeWidth: width);
  }

  void setColor(Color color) {
    selectedColor.value = color;
    drawingController.setStyle(
      color: color.withValues(alpha: colorOpacity.value),
    );
  }

  void setColorOpacity(double opacity) {
    colorOpacity.value = opacity;
    drawingController.setStyle(
      color: selectedColor.value.withValues(alpha: opacity),
    );
  }

  void toggleEraser() {
    isEraserMode.toggle();
    if (isEraserMode.value) {
      drawingController.setPaintContent(Eraser());
      currentTool.value = 'Eraser';
    } else {
      drawingController.setPaintContent(SimpleLine());
      currentTool.value = 'SimpleLine';
    }
  }

  void setTool(String tool) {
    currentTool.value = tool;
    isEraserMode.value = false;

    switch (tool) {
      case 'SimpleLine':
        drawingController.setPaintContent(SimpleLine());
        break;
      case 'StraightLine':
        drawingController.setPaintContent(StraightLine());
        break;
      case 'Rectangle':
        drawingController.setPaintContent(Rectangle());
        break;
      case 'Circle':
        drawingController.setPaintContent(Circle());
        break;
      case 'Star':
        drawingController.setPaintContent(Star());
        break;
      case 'Arrow':
        drawingController.setPaintContent(Arrow());
        break;
      case 'TextContent':
        drawingController.setPaintContent(TextContent());
        break;
      case 'ImportedImageContent':
        // This will be set after image is selected
        break;
      case 'Eraser':
        drawingController.setPaintContent(Eraser());
        isEraserMode.value = true;
        break;
    }
  }

  void undo() {
    if (drawingController.canUndo()) {
      drawingController.undo();
    }
  }

  void redo() {
    if (drawingController.canRedo()) {
      drawingController.redo();
    }
  }

  void clearBoard() {
    drawingController.clear();
    transformationController.value = Matrix4.identity();
  }

  void resetTransform() {
    transformationController.value = Matrix4.identity();
  }

  Future<Uint8List?> exportAsImage() async {
    final imageData = await drawingController.getImageData();
    return imageData?.buffer.asUint8List();
  }

  String exportAsJson() {
    return const JsonEncoder.withIndent(
      '  ',
    ).convert(drawingController.getJsonList());
  }

  void loadFromJson(String jsonString) {
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final List<PaintContent> contents = [];

      for (final json in jsonList) {
        final Map<String, dynamic> data = json as Map<String, dynamic>;
        final String type = data['type'] as String;

        switch (type) {
          case 'SimpleLine':
            contents.add(SimpleLine.fromJson(data));
            break;
          case 'StraightLine':
            contents.add(StraightLine.fromJson(data));
            break;
          case 'Rectangle':
            contents.add(Rectangle.fromJson(data));
            break;
          case 'Circle':
            contents.add(Circle.fromJson(data));
            break;
          case 'Star':
            contents.add(Star.fromJson(data));
            break;
          case 'Arrow':
            contents.add(Arrow.fromJson(data));
            break;
          case 'TextContent':
            contents.add(TextContent.fromJson(data));
            break;
          case 'ImportedImageContent':
            final imageContent = ImportedImageContent.fromJson(data);
            if (imageContent.imageBytes != null) {
              _loadImageFromBytes(imageContent.imageBytes!).then((image) {
                imageContent.image = image;
              });
            }
            contents.add(imageContent);
            break;
          case 'Eraser':
            contents.add(Eraser.fromJson(data));
            break;
        }
      }

      drawingController.clear();
      drawingController.addContents(contents);
    } catch (e) {
      debugPrint('Error loading drawing: $e');
    }
  }

  void addTestContent() {
    final redPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final greenPaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final purplePaint = Paint()
      ..color = Colors.purple
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final testContents = [
      StraightLine.data(
        startPoint: const Offset(50, 50),
        endPoint: const Offset(200, 150),
        paint: redPaint,
      ),
      Rectangle.data(
        startPoint: const Offset(100, 200),
        endPoint: const Offset(250, 300),
        paint: greenPaint,
      ),
      Circle.data(
        startPoint: const Offset(300, 100),
        endPoint: const Offset(400, 200),
        paint: purplePaint,
        center: const Offset(350, 150),
        radius: 50.0,
      ),
    ];

    drawingController.addContents(testContents);
  }

  Future<void> importImage({ImageSource source = ImageSource.gallery}) async {
    try {
      debugPrint('Starting image import from: $source');
      
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 2048,
        maxHeight: 2048,
      );

      debugPrint('Picked file: ${pickedFile?.path}');

      if (pickedFile != null) {
        debugPrint('Loading image bytes...');
        final Uint8List imageBytes = await pickedFile.readAsBytes();
        debugPrint('Image bytes length: ${imageBytes.length}');
        
        debugPrint('Converting to UI image...');
        final ui.Image image = await _loadImageFromBytes(imageBytes);
        debugPrint('Image loaded: ${image.width}x${image.height}');
        
        final imageContent = ImportedImageContent(
          image: image,
          imageBytes: imageBytes,
        );
        
        drawingController.setPaintContent(imageContent);
        currentTool.value = 'ImportedImageContent';
        isEraserMode.value = false;
        debugPrint('Image import completed successfully');
      } else {
        debugPrint('No image was selected');
      }
    } catch (e) {
      debugPrint('Error importing image: $e');
    }
  }

  Future<ui.Image> _loadImageFromBytes(Uint8List bytes) async {
    final ui.Codec codec = await ui.instantiateImageCodec(bytes);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    return frameInfo.image;
  }

}
