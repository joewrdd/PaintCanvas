import 'package:get/get.dart';

enum CanvasMode { canvas2D, tshirt3D, model3D }

class NavigationController extends GetxController {
  static NavigationController get instance => Get.find();

  final Rx<CanvasMode> currentMode = CanvasMode.canvas2D.obs;

  void switchToCanvas2D() {
    currentMode.value = CanvasMode.canvas2D;
  }

  void switchToTshirt3D() {
    currentMode.value = CanvasMode.tshirt3D;
  }

  void switchTo3DModel() {
    currentMode.value = CanvasMode.model3D;
  }

  String get currentModeTitle {
    switch (currentMode.value) {
      case CanvasMode.canvas2D:
        return '2D Canvas';
      case CanvasMode.tshirt3D:
        return '3D T-Shirt Designer';
      case CanvasMode.model3D:
        return '3D Model';
    }
  }
}
