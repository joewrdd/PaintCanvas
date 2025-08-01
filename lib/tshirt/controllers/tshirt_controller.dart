import 'dart:convert';
import 'dart:ui' as ui;
import 'package:canvaz/home/widgets/custom_paint_tools.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'package:flutter_drawing_board/paint_contents.dart';

class TshirtController extends GetxController {
  static TshirtController get instance => Get.find();

  late final ImagePicker _imagePicker;

  // Drawing controllers for each T-shirt side
  late final DrawingController frontController;
  late final DrawingController backController;
  late final DrawingController leftController;
  late final DrawingController rightController;

  // Current state
  final RxDouble strokeWidth = 4.0.obs;
  final RxDouble colorOpacity = 1.0.obs;
  final Rx<Color> selectedColor = Colors.blue.obs;
  final RxBool isEraserMode = false.obs;
  final RxString currentTool = 'SimpleLine'.obs;
  final RxBool isDrawingMode = false.obs;

  // 3D T-shirt properties
  final RxString tshirtColor = 'white'.obs;
  final RxString currentSide = 'front'.obs;
  final RxDouble rotationX = 0.0.obs;
  final RxDouble rotationY = 0.0.obs;
  final RxDouble rotationZ = 0.0.obs;
  final RxDouble scale = 1.0.obs;

  // Auto-rotation for preview
  final RxBool isAutoRotating = true.obs;

  @override
  void onInit() {
    super.onInit();
    _imagePicker = ImagePicker();
    _initializeDrawingControllers();
    _startAutoRotation();
  }

  void _initializeDrawingControllers() {
    frontController = DrawingController();
    backController = DrawingController();
    leftController = DrawingController();
    rightController = DrawingController();

    // Set initial drawing properties
    _updateAllControllersStyle();
  }

  void _updateAllControllersStyle() {
    final controllers = [
      frontController,
      backController,
      leftController,
      rightController,
    ];
    for (final controller in controllers) {
      controller.setStyle(
        strokeWidth: strokeWidth.value,
        color: selectedColor.value.withValues(alpha: colorOpacity.value),
      );
    }
  }

  void _startAutoRotation() {
    // Subtle auto-rotation when not in drawing mode
    ever(isDrawingMode, (isDrawing) {
      isAutoRotating.value = !isDrawing;
    });
  }

  DrawingController get currentDrawingController {
    switch (currentSide.value) {
      case 'front':
        return frontController;
      case 'back':
        return backController;
      case 'left':
        return leftController;
      case 'right':
        return rightController;
      default:
        return frontController;
    }
  }

  void setStrokeWidth(double width) {
    strokeWidth.value = width;
    _updateAllControllersStyle();
  }

  void setColor(Color color) {
    selectedColor.value = color;
    _updateAllControllersStyle();
  }

  void setColorOpacity(double opacity) {
    colorOpacity.value = opacity;
    _updateAllControllersStyle();
  }

  void setTool(String tool) {
    currentTool.value = tool;
    isEraserMode.value = false;

    PaintContent paintContent;
    switch (tool) {
      case 'SimpleLine':
        paintContent = SimpleLine();
        break;
      case 'StraightLine':
        paintContent = StraightLine();
        break;
      case 'Rectangle':
        paintContent = Rectangle();
        break;
      case 'Circle':
        paintContent = Circle();
        break;
      case 'Star':
        paintContent = Star();
        break;
      case 'Arrow':
        paintContent = Arrow();
        break;
      case 'TextContent':
        paintContent = TextContent();
        break;
      case 'Eraser':
        paintContent = Eraser();
        isEraserMode.value = true;
        break;
      default:
        paintContent = SimpleLine();
    }

    // Set tool for all controllers
    final controllers = [
      frontController,
      backController,
      leftController,
      rightController,
    ];
    for (final controller in controllers) {
      controller.setPaintContent(paintContent);
    }
  }

  void toggleEraser() {
    isEraserMode.toggle();
    if (isEraserMode.value) {
      setTool('Eraser');
    } else {
      setTool('SimpleLine');
    }
  }

  void toggleDrawingMode() {
    isDrawingMode.toggle();
    // Stop auto-rotation when drawing
    isAutoRotating.value = !isDrawingMode.value;
  }

  void switchToSide(String side) {
    currentSide.value = side;

    // Automatically rotate T-shirt to show the selected side
    switch (side) {
      case 'front':
        rotationY.value = 0;
        break;
      case 'back':
        rotationY.value = 180;
        break;
      case 'left':
        rotationY.value = -90;
        break;
      case 'right':
        rotationY.value = 90;
        break;
    }
  }

  void rotateTshirt(double deltaX, double deltaY) {
    if (!isDrawingMode.value) {
      rotationY.value += deltaX * 0.5;
      rotationX.value = (rotationX.value - deltaY * 0.5).clamp(-30.0, 30.0);

      // Update current side based on rotation
      _updateCurrentSideFromRotation();
    }
  }

  void _updateCurrentSideFromRotation() {
    final normalizedY = (rotationY.value % 360 + 360) % 360;

    if (normalizedY >= 315 || normalizedY < 45) {
      currentSide.value = 'front';
    } else if (normalizedY >= 45 && normalizedY < 135) {
      currentSide.value = 'right';
    } else if (normalizedY >= 135 && normalizedY < 225) {
      currentSide.value = 'back';
    } else {
      currentSide.value = 'left';
    }
  }

  void resetRotation() {
    rotationX.value = 0;
    rotationY.value = 0;
    rotationZ.value = 0;
    scale.value = 1.0;
    currentSide.value = 'front';
  }

  void changeTshirtColor(String color) {
    tshirtColor.value = color;
  }

  Future<void> importImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (pickedFile != null) {
        final Uint8List imageBytes = await pickedFile.readAsBytes();
        final ui.Image image = await _loadImageFromBytes(imageBytes);

        final imageContent = ImportedImageContent(
          image: image,
          imageBytes: imageBytes,
        );

        currentDrawingController.setPaintContent(imageContent);
        currentTool.value = 'ImportedImageContent';
        isEraserMode.value = false;
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

  void clearCurrentSide() {
    currentDrawingController.clear();
  }

  void clearAllSides() {
    frontController.clear();
    backController.clear();
    leftController.clear();
    rightController.clear();
  }

  void undo() {
    if (currentDrawingController.canUndo()) {
      currentDrawingController.undo();
    }
  }

  void redo() {
    if (currentDrawingController.canRedo()) {
      currentDrawingController.redo();
    }
  }

  bool get canUndo => currentDrawingController.canUndo();
  bool get canRedo => currentDrawingController.canRedo();

  String exportAsJson() {
    final data = {
      'tshirtColor': tshirtColor.value,
      'frontDesign': frontController.getJsonList(),
      'backDesign': backController.getJsonList(),
      'leftDesign': leftController.getJsonList(),
      'rightDesign': rightController.getJsonList(),
      'metadata': {
        'exportedAt': DateTime.now().toIso8601String(),
        'version': '2.0',
        'type': 'flutter_native_tshirt',
      },
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  void loadFromJson(String jsonString) {
    try {
      final Map<String, dynamic> data = jsonDecode(jsonString);

      if (data['tshirtColor'] != null) {
        changeTshirtColor(data['tshirtColor']);
      }

      // Load designs for each side
      _loadSideFromJson('front', frontController, data['frontDesign']);
      _loadSideFromJson('back', backController, data['backDesign']);
      _loadSideFromJson('left', leftController, data['leftDesign']);
      _loadSideFromJson('right', rightController, data['rightDesign']);
    } catch (e) {
      debugPrint('Error loading T-shirt design: $e');
    }
  }

  void _loadSideFromJson(
    String side,
    DrawingController controller,
    dynamic jsonData,
  ) {
    if (jsonData == null) return;

    try {
      final List<dynamic> jsonList = jsonData as List<dynamic>;
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

      controller.clear();
      controller.addContents(contents);
    } catch (e) {
      debugPrint('Error loading $side side: $e');
    }
  }

  Future<Uint8List?> exportCurrentSideAsImage() async {
    final imageData = await currentDrawingController.getImageData();
    return imageData?.buffer.asUint8List();
  }

  @override
  void onClose() {
    frontController.dispose();
    backController.dispose();
    leftController.dispose();
    rightController.dispose();
    super.onClose();
  }
}
