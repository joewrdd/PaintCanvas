import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/tshirt_controller.dart';
import '../widgets/tshirt_3d_painter.dart';

class TshirtScreen extends StatelessWidget {
  const TshirtScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TshirtController>(
      init: TshirtController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.grey[100],
          body: Stack(
            children: [
              // Background gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.blue[50]!, Colors.purple[50]!],
                  ),
                ),
              ),

              // Main 3D T-shirt area
              Positioned.fill(child: _build3DTshirtArea(controller)),

              // Top toolbar
              Positioned(
                top: MediaQuery.of(context).padding.top,
                left: 0,
                right: 0,
                child: _buildTopToolbar(context, controller),
              ),

              // Drawing tools toolbar (when in drawing mode)
              Obx(
                () => controller.isDrawingMode.value
                    ? Positioned(
                        top: MediaQuery.of(context).padding.top + 70,
                        left: 0,
                        right: 0,
                        child: _buildDrawingToolbar(context, controller),
                      )
                    : const SizedBox.shrink(),
              ),

              // Bottom controls
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildBottomControls(controller),
              ),

              // Side selector (floating)
              Positioned(
                left: 20,
                top: MediaQuery.of(context).size.height * 0.3,
                child: _buildSideSelector(controller),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _build3DTshirtArea(TshirtController controller) {
    return Obx(() {
      return GestureDetector(
        onPanUpdate: controller.isDrawingMode.value
            ? null
            : (details) {
                controller.rotateTshirt(details.delta.dx, details.delta.dy);
              },
        child: Center(
          child: Container(
            width: 350,
            height: 450,
            child: TShirt3DWidget(
              tshirtColor: controller.tshirtColor.value,
              rotationX: controller.rotationX.value,
              rotationY: controller.rotationY.value,
              currentSide: controller.currentSide.value,
              child: TShirtDrawingSurface(
                currentSide: controller.currentSide.value,
                child: Obx(() {
                  return Opacity(
                    opacity: controller.isDrawingMode.value ? 1.0 : 0.7,
                    child: DrawingBoard(
                      controller: controller.currentDrawingController,
                      background: Container(color: Colors.transparent),
                      showDefaultActions: false,
                      showDefaultTools: false,
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildTopToolbar(BuildContext context, TshirtController controller) {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
          const Expanded(
            child: Text(
              '3D T-Shirt Designer',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'clear_side':
                  controller.clearCurrentSide();
                  break;
                case 'clear_all':
                  controller.clearAllSides();
                  break;
                case 'reset_rotation':
                  controller.resetRotation();
                  break;
                case 'export_json':
                  _showExportJson(context, controller);
                  break;
                case 'import_json':
                  _showImportDialog(context, controller);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear_side',
                child: Text('Clear Current Side'),
              ),
              const PopupMenuItem(
                value: 'clear_all',
                child: Text('Clear All Sides'),
              ),
              const PopupMenuItem(
                value: 'reset_rotation',
                child: Text('Reset Rotation'),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'export_json',
                child: Text('Export Design'),
              ),
              const PopupMenuItem(
                value: 'import_json',
                child: Text('Import Design'),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildDrawingToolbar(
    BuildContext context,
    TshirtController controller,
  ) {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
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

  Widget _buildBottomControls(TshirtController controller) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
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
        () => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 70,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Drawing mode toggle
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(
                          controller.isDrawingMode.value
                              ? Icons.pan_tool
                              : Icons.edit,
                          color: controller.isDrawingMode.value
                              ? Colors.green
                              : Colors.blue,
                        ),
                        onPressed: controller.toggleDrawingMode,
                      ),
                      Text(
                        controller.isDrawingMode.value ? 'View' : 'Draw',
                        style: const TextStyle(fontSize: 10),
                      ),
                    ],
                  ),

                  // Undo/Redo
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.undo,
                              color: controller.canUndo
                                  ? Colors.blue
                                  : Colors.grey,
                            ),
                            onPressed: controller.canUndo
                                ? controller.undo
                                : null,
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.redo,
                              color: controller.canRedo
                                  ? Colors.blue
                                  : Colors.grey,
                            ),
                            onPressed: controller.canRedo
                                ? controller.redo
                                : null,
                          ),
                        ],
                      ),
                      const Text('History', style: TextStyle(fontSize: 10)),
                    ],
                  ),

                  // Color picker
                  GestureDetector(
                    onTap: () => _showColorPicker(Get.context!, controller),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: controller.selectedColor.value,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.grey[300]!,
                              width: 2,
                            ),
                          ),
                        ),
                        const Text('Color', style: TextStyle(fontSize: 10)),
                      ],
                    ),
                  ),

                  // Stroke width
                  GestureDetector(
                    onTap: () =>
                        _showStrokeWidthPicker(Get.context!, controller),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 30,
                          height: controller.strokeWidth.value.clamp(2.0, 15.0),
                          decoration: BoxDecoration(
                            color: controller.selectedColor.value,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${controller.strokeWidth.value.toInt()}',
                          style: const TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  ),

                  // T-shirt color
                  GestureDetector(
                    onTap: () =>
                        _showTshirtColorPicker(Get.context!, controller),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 40,
                          height: 30,
                          decoration: BoxDecoration(
                            color: _getColorFromName(
                              controller.tshirtColor.value,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.grey[300]!,
                              width: 2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          controller.tshirtColor.value.toUpperCase(),
                          style: const TextStyle(fontSize: 8),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSideSelector(TshirtController controller) {
    return Obx(
      () => Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            'front',
            'right',
            'back',
            'left',
          ].map((side) => _buildSideButton(side, controller)).toList(),
        ),
      ),
    );
  }

  Widget _buildSideButton(String side, TshirtController controller) {
    final isSelected = controller.currentSide.value == side;

    return GestureDetector(
      onTap: () => controller.switchToSide(side),
      child: Container(
        width: 50,
        height: 50,
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getSideIcon(side),
              color: isSelected ? Colors.white : Colors.grey[600],
              size: 20,
            ),
            Text(
              side[0].toUpperCase(),
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[600],
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getSideIcon(String side) {
    switch (side) {
      case 'front':
        return Icons.crop_portrait;
      case 'back':
        return Icons.crop_portrait;
      case 'left':
        return Icons.crop_landscape;
      case 'right':
        return Icons.crop_landscape;
      default:
        return Icons.crop_portrait;
    }
  }

  void _showColorPicker(BuildContext context, TshirtController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Drawing Color'),
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
                          Colors.white,
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

  void _showStrokeWidthPicker(
    BuildContext context,
    TshirtController controller,
  ) {
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

  void _showTshirtColorPicker(
    BuildContext context,
    TshirtController controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('T-Shirt Color'),
        content: Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              [
                    'white',
                    'black',
                    'gray',
                    'red',
                    'blue',
                    'green',
                    'yellow',
                    'purple',
                  ]
                  .map(
                    (colorName) => GestureDetector(
                      onTap: () {
                        controller.changeTshirtColor(colorName);
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 60,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _getColorFromName(colorName),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            colorName.toUpperCase(),
                            style: TextStyle(
                              color: colorName == 'white'
                                  ? Colors.black
                                  : Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
        ),
      ),
    );
  }

  Color _getColorFromName(String colorName) {
    switch (colorName) {
      case 'white':
        return Colors.white;
      case 'black':
        return Colors.black;
      case 'gray':
        return Colors.grey;
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.yellow;
      case 'purple':
        return Colors.purple;
      default:
        return Colors.white;
    }
  }

  void _showImageSourceDialog(
    BuildContext context,
    TshirtController controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Image to T-Shirt'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () async {
                Navigator.pop(context);
                await controller.importImage(source: ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () async {
                Navigator.pop(context);
                await controller.importImage(source: ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showExportJson(BuildContext context, TshirtController controller) {
    final jsonData = controller.exportAsJson();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export T-Shirt Design'),
        content: SingleChildScrollView(child: SelectableText(jsonData)),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: jsonData));
              Navigator.pop(context);
              Get.snackbar('Success', 'Design JSON copied to clipboard');
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
  }

  void _showImportDialog(BuildContext context, TshirtController controller) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import T-Shirt Design'),
        content: TextField(
          controller: textController,
          maxLines: 10,
          decoration: const InputDecoration(
            hintText: 'Paste your design JSON here...',
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
                Get.snackbar('Success', 'Design imported successfully');
              }
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }
}
