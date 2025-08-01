import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/home_controller.dart';
import '../../navigation/navigation_controller.dart';
import '../../tshirt/screens/tshirt_screen.dart';
import '../../unity/screens/home_page.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NavigationController>(
      init: NavigationController(),
      builder: (navController) {
        return Obx(() {
          switch (navController.currentMode.value) {
            case CanvasMode.canvas2D:
              return _buildCanvas2D(context);
            case CanvasMode.tshirt3D:
              return _buildTshirt3D(context);
            case CanvasMode.model3D:
              return _build3DModel(context);
          }
        });
      },
    );
  }

  Widget _buildCanvas2D(BuildContext context) {
    return GetBuilder<HomeController>(
      init: HomeController(),
      builder: (controller) {
        return Scaffold(
          drawer: _buildNavigationDrawer(context),
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            title: Text(
              '2D Canvas',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            elevation: 2,
            systemOverlayStyle: SystemUiOverlayStyle.dark,
            actions: [
              IconButton(
                icon: const Icon(Icons.palette),
                onPressed: () => _showColorPicker(context, controller),
              ),
              IconButton(
                icon: const Icon(Icons.line_weight),
                onPressed: () => _showStrokeWidthPicker(context, controller),
              ),
              IconButton(
                icon: const Icon(Icons.add_chart),
                onPressed: controller.addTestContent,
              ),
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: () => _showExportOptions(context, controller),
              ),
              IconButton(
                icon: const Icon(Icons.folder_open),
                onPressed: () => _showImportDialog(context, controller),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  switch (value) {
                    case 'clear':
                      controller.clearBoard();
                      break;
                    case 'reset':
                      controller.resetTransform();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'clear', child: Text('Clear All')),
                  const PopupMenuItem(
                    value: 'reset',
                    child: Text('Reset Zoom'),
                  ),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              _buildToolbar(context, controller),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return DrawingBoard(
                          controller: controller.drawingController,
                          transformationController:
                              controller.transformationController,
                          background: Container(
                            width: constraints.maxWidth,
                            height: constraints.maxHeight,
                            color: Colors.white,
                            child: CustomPaint(
                              painter: GridPainter(),
                              size: Size(
                                constraints.maxWidth,
                                constraints.maxHeight,
                              ),
                            ),
                          ),
                          showDefaultActions: false,
                          showDefaultTools: false,
                        );
                      },
                    ),
                  ),
                ),
              ),
              _buildBottomControls(controller),
            ],
          ),
        );
      },
    );
  }

  Widget _buildToolbar(BuildContext context, HomeController controller) {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Obx(
        () => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              const SizedBox(width: 16),
              _buildToolButton(
                icon: Icons.edit,
                label: 'Draw',
                isSelected: controller.currentTool.value == 'SimpleLine',
                onTap: () => controller.setTool('SimpleLine'),
              ),
              const SizedBox(width: 12),
              _buildToolButton(
                icon: Icons.straight,
                label: 'Line',
                isSelected: controller.currentTool.value == 'StraightLine',
                onTap: () => controller.setTool('StraightLine'),
              ),
              const SizedBox(width: 12),
              _buildToolButton(
                icon: Icons.rectangle_outlined,
                label: 'Rect',
                isSelected: controller.currentTool.value == 'Rectangle',
                onTap: () => controller.setTool('Rectangle'),
              ),
              const SizedBox(width: 12),
              _buildToolButton(
                icon: Icons.circle_outlined,
                label: 'Circle',
                isSelected: controller.currentTool.value == 'Circle',
                onTap: () => controller.setTool('Circle'),
              ),
              const SizedBox(width: 12),
              _buildToolButton(
                icon: Icons.star_outline,
                label: 'Star',
                isSelected: controller.currentTool.value == 'Star',
                onTap: () => controller.setTool('Star'),
              ),
              const SizedBox(width: 12),
              _buildToolButton(
                icon: Icons.arrow_right_alt,
                label: 'Arrow',
                isSelected: controller.currentTool.value == 'Arrow',
                onTap: () => controller.setTool('Arrow'),
              ),
              const SizedBox(width: 12),
              _buildToolButton(
                icon: Icons.text_fields,
                label: 'Text',
                isSelected: controller.currentTool.value == 'TextContent',
                onTap: () => controller.setTool('TextContent'),
              ),
              const SizedBox(width: 12),
              _buildToolButton(
                icon: Icons.image,
                label: 'Image',
                isSelected:
                    controller.currentTool.value == 'ImportedImageContent',
                onTap: () => _showImageSourceDialog(context, controller),
              ),
              const SizedBox(width: 12),
              _buildToolButton(
                icon: Icons.cleaning_services,
                label: 'Eraser',
                isSelected: controller.isEraserMode.value,
                onTap: controller.toggleEraser,
              ),
              const SizedBox(width: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[700],
              size: 20,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[700],
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls(HomeController controller) {
    return Container(
      height: 70,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Obx(
        () => Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: Icon(
                Icons.undo,
                color: controller.canUndo.value ? Colors.blue : Colors.grey,
              ),
              onPressed: controller.canUndo.value ? controller.undo : null,
            ),
            IconButton(
              icon: Icon(
                Icons.redo,
                color: controller.canRedo.value ? Colors.blue : Colors.grey,
              ),
              onPressed: controller.canRedo.value ? controller.redo : null,
            ),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: controller.selectedColor.value,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey[300]!, width: 2),
              ),
            ),
            Text(
              'Stroke: ${controller.strokeWidth.value.toInt()}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            Text(
              'Opacity: ${(controller.colorOpacity.value * 100).toInt()}%',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  void _showColorPicker(BuildContext context, HomeController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Color'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(
                () => Slider(
                  value: controller.colorOpacity.value,
                  onChanged: controller.setColorOpacity,
                  label:
                      'Opacity: ${(controller.colorOpacity.value * 100).toInt()}%',
                  divisions: 10,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    [
                          Colors.red,
                          Colors.blue,
                          Colors.green,
                          Colors.yellow,
                          Colors.purple,
                          Colors.orange,
                          Colors.pink,
                          Colors.cyan,
                          Colors.brown,
                          Colors.black,
                        ]
                        .map(
                          (color) => GestureDetector(
                            onTap: () {
                              controller.setColor(color);
                              Navigator.pop(context);
                            },
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.grey[300]!,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStrokeWidthPicker(BuildContext context, HomeController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Stroke Width'),
        content: Obx(
          () => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Slider(
                value: controller.strokeWidth.value,
                min: 1,
                max: 20,
                divisions: 19,
                label: controller.strokeWidth.value.toInt().toString(),
                onChanged: controller.setStrokeWidth,
              ),
              Container(
                height: 60,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Container(
                    height: controller.strokeWidth.value,
                    width: 100,
                    color: controller.selectedColor.value,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showExportOptions(BuildContext context, HomeController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Options'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Export as Image'),
              onTap: () async {
                Navigator.pop(context);
                final imageData = await controller.exportAsImage();
                if (imageData != null) {
                  Get.snackbar('Success', 'Image exported successfully');
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.code),
              title: const Text('Export as JSON'),
              onTap: () {
                Navigator.pop(context);
                final jsonData = controller.exportAsJson();
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('JSON Export'),
                    content: SingleChildScrollView(
                      child: SelectableText(jsonData),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: jsonData));
                          Navigator.pop(context);
                          Get.snackbar('Success', 'JSON copied to clipboard');
                        },
                        child: const Text('Copy'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showImportDialog(BuildContext context, HomeController controller) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import JSON'),
        content: TextField(
          controller: textController,
          maxLines: 10,
          decoration: const InputDecoration(
            hintText: 'Paste your JSON data here...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (textController.text.isNotEmpty) {
                controller.loadFromJson(textController.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }

  void _showImageSourceDialog(BuildContext context, HomeController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                await controller.importImage(source: ImageSource.gallery);
                if (controller.currentTool.value == 'ImportedImageContent') {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Image imported! Tap on canvas to place it.',
                      ),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () async {
                Navigator.pop(context);
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                await controller.importImage(source: ImageSource.camera);
                if (controller.currentTool.value == 'ImportedImageContent') {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Image imported! Tap on canvas to place it.',
                      ),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _build3DModel(BuildContext context) {
    return Scaffold(drawer: _buildNavigationDrawer(context), body: HomePage());
  }

  Widget _buildTshirt3D(BuildContext context) {
    return Scaffold(
      drawer: _buildNavigationDrawer(context),
      body: const TshirtScreen(),
    );
  }

  Widget _buildNavigationDrawer(BuildContext context) {
    final navController = Get.find<NavigationController>();

    return Drawer(
      child: Column(
        children: [
          Container(
            height: 255,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue[800]!, Colors.blue[600]!],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Icon(
                        Icons.palette,
                        size: 30,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Canvaz Studio',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Obx(
                      () => Text(
                        navController.currentModeTitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 16),
                Obx(
                  () => ListTile(
                    leading: Icon(
                      Icons.draw,
                      color:
                          navController.currentMode.value == CanvasMode.canvas2D
                          ? Colors.blue
                          : Colors.grey[600],
                    ),
                    title: const Text('2D Canvas'),
                    subtitle: const Text('Free drawing and sketching'),
                    selected:
                        navController.currentMode.value == CanvasMode.canvas2D,
                    selectedTileColor: Colors.blue.withValues(alpha: 0.1),
                    onTap: () {
                      navController.switchToCanvas2D();
                      Navigator.pop(context);
                    },
                  ),
                ),
                Obx(
                  () => ListTile(
                    leading: Icon(
                      Icons.checkroom,
                      color:
                          navController.currentMode.value == CanvasMode.tshirt3D
                          ? Colors.blue
                          : Colors.grey[600],
                    ),
                    title: const Text('3D T-Shirt Designer'),
                    subtitle: const Text('Design on 3D clothing models'),
                    selected:
                        navController.currentMode.value == CanvasMode.tshirt3D,
                    selectedTileColor: Colors.blue.withValues(alpha: 0.1),
                    onTap: () {
                      navController.switchToTshirt3D();
                      Navigator.pop(context);
                    },
                  ),
                ),
                Obx(
                  () => ListTile(
                    leading: Icon(
                      Icons.abc,
                      color:
                          navController.currentMode.value == CanvasMode.canvas2D
                          ? Colors.blue
                          : Colors.grey[600],
                    ),
                    title: const Text('3D Model '),
                    subtitle: const Text('Shirt Model 3Ding'),
                    selected:
                        navController.currentMode.value == CanvasMode.model3D,
                    selectedTileColor: Colors.blue.withValues(alpha: 0.1),
                    onTap: () {
                      navController.switchTo3DModel();
                      Navigator.pop(context);
                    },
                  ),
                ),
                const Divider(height: 32),
                ListTile(
                  leading: Icon(Icons.info_outline, color: Colors.grey[600]),
                  title: const Text('About'),
                  onTap: () {
                    Navigator.pop(context);
                    _showAboutDialog(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.help_outline, color: Colors.grey[600]),
                  title: const Text('Help'),
                  onTap: () {
                    Navigator.pop(context);
                    _showHelpDialog(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Canvaz Studio'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Canvaz Studio is a powerful drawing and design application that offers both 2D canvas drawing and 3D T-shirt design capabilities.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text('Features:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('• 2D Canvas with multiple drawing tools'),
            Text('• 3D T-shirt design with real-time preview'),
            Text('• Import/Export capabilities'),
            Text('• Professional design tools'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quick Help'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '2D Canvas Mode:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• Use toolbar to select drawing tools'),
            Text('• Tap color circle to change colors'),
            Text('• Pinch to zoom, drag to pan'),
            SizedBox(height: 16),
            Text(
              '3D T-shirt Mode:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• Toggle "Draw" mode to start designing'),
            Text('• Rotate T-shirt to access different sides'),
            Text('• Switch between Front/Back/Left/Right'),
            Text('• Use same tools as 2D mode'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[200]!
      ..strokeWidth = 0.5;

    const gridSize = 20.0;

    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
