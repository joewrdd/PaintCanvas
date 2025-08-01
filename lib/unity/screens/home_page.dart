import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/design_controller.dart';
import 'sketch_canvas.dart';

class HomePage extends StatelessWidget {
  final DesignController controller = Get.put(DesignController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        //     leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () =>  ),
        title: Text('T-Shirt Designer'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(
            icon: Icon(Icons.clear_all),
            onPressed: () => _showClearDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Side Selection Tabs
          _buildSideSelector(),

          // Main Canvas Area
          Expanded(
            child: Container(
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SketchCanvas(),
              ),
            ),
          ),

          // Drawing Tools
          _buildDrawingTools(),
        ],
      ),
    );
  }

  Widget _buildSideSelector() {
    return Container(
      height: 60,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Obx(
        () => Row(
          children: List.generate(4, (index) {
            final isSelected = controller.selectedSide.value == index;
            return Expanded(
              child: GestureDetector(
                onTap: () => controller.changeSide(index),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.grey[300]!,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      controller.sideNames[index],
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildDrawingTools() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Color Palette
          _buildColorPalette(),
          SizedBox(height: 16),

          // Brush Size and Tools
          Row(
            children: [
              // Brush Size
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Brush Size',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Obx(
                      () => Slider(
                        value: controller.brushThickness.value,
                        min: 1.0,
                        max: 10.0,
                        divisions: 9,
                        label: controller.brushThickness.value
                            .round()
                            .toString(),
                        onChanged: controller.changeBrushThickness,
                      ),
                    ),
                  ],
                ),
              ),

              // Tools
              Column(
                children: [
                  Obx(
                    () => ElevatedButton.icon(
                      onPressed: controller.toggleEraser,
                      icon: Icon(
                        controller.isErasing.value
                            ? Icons.brush
                            : Icons.cleaning_services,
                      ),
                      label: Text(
                        controller.isErasing.value ? 'Draw' : 'Erase',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: controller.isErasing.value
                            ? Colors.red
                            : Colors.blue,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: controller.clearCurrentCanvas,
                    icon: Icon(Icons.clear),
                    label: Text('Clear'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorPalette() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Colors', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: controller.colorPalette.map((color) {
            return Obx(
              () => GestureDetector(
                onTap: () => controller.changeColor(color),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color:
                          controller.selectedColor.value == color &&
                              !controller.isErasing.value
                          ? Colors.black
                          : Colors.grey[300]!,
                      width:
                          controller.selectedColor.value == color &&
                              !controller.isErasing.value
                          ? 3
                          : 1,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _showClearDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: Text('Clear All Designs'),
        content: Text(
          'Are you sure you want to clear all designs on all sides?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
          TextButton(
            onPressed: () {
              controller.clearAllCanvases();
              Get.back();
            },
            child: Text('Clear All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
