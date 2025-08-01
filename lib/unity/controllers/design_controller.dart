import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signature/signature.dart';

class DesignController extends GetxController {
  // Current selected side (0: Front, 1: Back, 2: Left, 3: Right)
  final RxInt selectedSide = 0.obs;

  // Drawing properties
  final RxDouble brushThickness = 3.0.obs;
  final Rx<Color> selectedColor = Colors.black.obs;
  final RxBool isErasing = false.obs;

  // Signature controllers for each side
  late SignatureController frontController;
  late SignatureController backController;
  late SignatureController leftController;
  late SignatureController rightController;

  // T-shirt side names
  final List<String> sideNames = ['Front', 'Back', 'Left', 'Right'];

  // Color palette
  final List<Color> colorPalette = [
    Colors.black,
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
    Colors.pink,
    Colors.brown,
    Colors.grey,
  ];

  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
  }

  void _initializeControllers() {
    frontController = SignatureController(
      penStrokeWidth: brushThickness.value,
      penColor: selectedColor.value,
      exportBackgroundColor: Colors.transparent,
    );

    backController = SignatureController(
      penStrokeWidth: brushThickness.value,
      penColor: selectedColor.value,
      exportBackgroundColor: Colors.transparent,
    );

    leftController = SignatureController(
      penStrokeWidth: brushThickness.value,
      penColor: selectedColor.value,
      exportBackgroundColor: Colors.transparent,
    );

    rightController = SignatureController(
      penStrokeWidth: brushThickness.value,
      penColor: selectedColor.value,
      exportBackgroundColor: Colors.transparent,
    );
  }

  SignatureController getCurrentController() {
    switch (selectedSide.value) {
      case 0:
        return frontController;
      case 1:
        return backController;
      case 2:
        return leftController;
      case 3:
        return rightController;
      default:
        return frontController;
    }
  }

  void changeSide(int index) {
    selectedSide.value = index;
  }

  void changeColor(Color color) {
    selectedColor.value = color;
    isErasing.value = false;
    // Update current controller immediately
    _updateCurrentController();
  }

  void changeBrushThickness(double thickness) {
    brushThickness.value = thickness;
    // Update current controller immediately
    _updateCurrentController();
  }

  void toggleEraser() {
    isErasing.toggle();
    if (isErasing.value) {
      selectedColor.value = Colors.white;
    } else {
      selectedColor.value = Colors.black;
    }
    // Update current controller immediately
    _updateCurrentController();
  }

  void _updateCurrentController() {
    // Update only the current controller's properties
    final currentController = getCurrentController();
    final color = isErasing.value ? Colors.white : selectedColor.value;

    // Create a temporary controller with new settings
    final tempController = SignatureController(
      penColor: color,
      penStrokeWidth: brushThickness.value,
      exportBackgroundColor: Colors.transparent,
      points: currentController.points,
    );

    // Replace the current controller
    switch (selectedSide.value) {
      case 0:
        frontController.dispose();
        frontController = tempController;
        break;
      case 1:
        backController.dispose();
        backController = tempController;
        break;
      case 2:
        leftController.dispose();
        leftController = tempController;
        break;
      case 3:
        rightController.dispose();
        rightController = tempController;
        break;
    }
  }

  void clearCurrentCanvas() {
    getCurrentController().clear();
  }

  void clearAllCanvases() {
    frontController.clear();
    backController.clear();
    leftController.clear();
    rightController.clear();
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
