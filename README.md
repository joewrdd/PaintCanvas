# 🎨 Paint Canvas

A sophisticated Flutter drawing application with advanced painting tools and multi-format export capabilities.

## ✨ Features

### Drawing Tools
- **Freehand Drawing** - Smooth brush strokes with pressure sensitivity
- **Geometric Shapes** - Rectangle, Circle, Star, and Arrow tools
- **Line Tools** - Straight lines and freehand drawing
- **Text Tool** - Add text annotations with customizable styling
- **Image Import** - Import images from gallery or camera
- **Eraser Tool** - Precise erasing with adjustable size

### Canvas Controls
- **Zoom & Pan** - Interactive canvas transformation
- **Grid Background** - Optional grid overlay for precision
- **Undo/Redo** - Complete action history management
- **Clear Canvas** - Reset drawing surface

### Customization
- **Color Picker** - Full color palette with opacity control
- **Stroke Width** - Adjustable brush sizes (1-20px)
- **Opacity Control** - Fine-tune transparency levels
- **Real-time Preview** - Live stroke preview in settings

### Export & Import
- **Image Export** - Save drawings as high-quality images
- **JSON Export** - Export drawing data for backup/sharing
- **JSON Import** - Load previously saved drawings
- **Cross-platform Compatibility** - Works on iOS and Android

## 🛠️ Technology Stack

- **Flutter** ^3.8.1 - Cross-platform framework
- **GetX** ^4.7.2 - State management and navigation
- **flutter_drawing_board** ^0.9.8 - Advanced drawing functionality
- **image_picker** ^1.0.4 - Camera and gallery integration

## 📱 Screenshots

The app features a modern, intuitive interface with:
- Clean toolbar with organized drawing tools
- Professional color picker with opacity controls
- Responsive canvas with zoom capabilities
- Export options for various file formats

## 🚀 Getting Started

### Prerequisites
- Flutter SDK ^3.8.1
- Dart SDK
- iOS Simulator / Android Emulator or physical device

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd paint_canvas
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the application:
```bash
flutter run
```

## 📁 Project Structure

```
lib/
├── home/
│   ├── controllers/
│   │   └── home_controller.dart    # Main app logic and state management
│   ├── screens/
│   │   └── home.dart              # Primary drawing interface
│   └── widgets/
│       └── custom_paint_tools.dart # Custom drawing tools implementation
```

## 🎯 Usage

1. **Select a Tool** - Choose from drawing, shapes, text, or eraser tools
2. **Customize Settings** - Adjust color, stroke width, and opacity
3. **Draw on Canvas** - Create your artwork with intuitive gestures
4. **Export Your Work** - Save as image or JSON format
5. **Import Previous Work** - Load saved drawings via JSON import

## 🔧 Architecture

The app follows the **GetX Pattern** for state management:
- **Controller**: `HomeController` manages drawing state and canvas operations
- **View**: `HomeScreen` provides the user interface
- **Custom Tools**: Extended drawing tools for enhanced functionality

## 📄 License

This project is created for demonstration purposes. Please check with the repository owner for licensing terms.

## 🤝 Contributing

This is a personal project. For suggestions or improvements, please reach out to the project maintainer.

---

Built with ❤️ using Flutter
