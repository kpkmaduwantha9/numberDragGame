//need to check requirements
//shapes place in different positions

import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

class GameScreen4 extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen4> {
  late ConfettiController _confettiController;

  // Define the order for draggable shapes (orange)
  final List<ShapeType> draggableShapeOrder = [
    ShapeType.circle,
    ShapeType.triangle,
    ShapeType.hexagon,
    ShapeType.rectangle,
    ShapeType.pentagon,
  ];

  // Define the order for target shapes (black)
  final List<ShapeType> targetShapeOrder = [
    ShapeType.pentagon,
    ShapeType.hexagon,
    ShapeType.triangle,
    ShapeType.rectangle,
    ShapeType.circle,
  ];

  final Map<ShapeType, bool> placedShapes = {
    for (var shape in ShapeType.values) shape: false,
  };

  final Map<ShapeType, Color> placedShapeColors = {};
  bool isWrong = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: Duration(seconds: 5));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void checkAnswer(ShapeType shape, ShapeType targetShape) {
    if (shape == targetShape) {
      setState(() {
        placedShapes[shape] = true;
        placedShapeColors[shape] = Colors.orange;
        isWrong = false;
      });

      if (placedShapes.values.every((isPlaced) => isPlaced)) {
        _confettiController.play();
      }
    } else {
      setState(() {
        isWrong = true;
      });
    }
  }

  void resetGame() {
    setState(() {
      placedShapes.updateAll((key, value) => false);
      placedShapeColors.clear();
      isWrong = false;
    });
  }

  void resetWrong() {
    setState(() {
      isWrong = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber.shade100,
      body: LayoutBuilder(
        builder: (context, constraints) {
          double screenWidth = constraints.maxWidth;
          double screenHeight = constraints.maxHeight;
          double shapeSize = screenWidth * 0.2;
          double fontSize = screenWidth * 0.06;
          double spacing = screenHeight * 0.02;

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(fontSize, screenHeight),
                SizedBox(height: spacing),
                _buildDropTargets(shapeSize, screenWidth),
                SizedBox(height: spacing * 2),
                _buildDraggableShapes(shapeSize, screenWidth),
                SizedBox(height: spacing * 2),
                _buildResultUI(fontSize, spacing),
                _buildConfetti(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(double fontSize, double screenHeight) {
    return Container(
      height: screenHeight * 0.25,
      width: double.infinity,
      child: CustomPaint(
        painter: CurvedTopPainter(),
        child: Center(
          child: Text(
            "Match the Shapes",
            style: TextStyle(
              fontSize: fontSize * 1.5,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropTargets(double shapeSize, double screenWidth) {
    return Wrap(
      spacing: screenWidth * 0.05,
      runSpacing: shapeSize * 0.2,
      alignment: WrapAlignment.center,
      children: targetShapeOrder
          .map((shape) => dropTarget(shape, shapeSize))
          .toList(),
    );
  }

  Widget _buildDraggableShapes(double shapeSize, double screenWidth) {
    return placedShapes.values.every((isPlaced) => isPlaced)
        ? SizedBox.shrink()
        : Wrap(
            spacing: screenWidth * 0.05,
            runSpacing: shapeSize * 0.2,
            alignment: WrapAlignment.center,
            children: draggableShapeOrder.map((shape) {
              bool isPlaced = placedShapes[shape] ?? false;
              Color color =
                  isPlaced ? Colors.orange.withOpacity(0.2) : Colors.orange;
              return draggableShape(shape, color, shapeSize);
            }).toList(),
          );
  }

  Widget _buildResultUI(double fontSize, double spacing) {
    if (placedShapes.values.every((isPlaced) => isPlaced)) {
      return Column(
        children: [
          Text(
            "🎉 Correct! 🎉",
            style: TextStyle(
              fontSize: fontSize * 2,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          SizedBox(height: spacing),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Navigate back to HomeScreen
            },
            child: Text("Next", style: TextStyle(fontSize: fontSize * 1)),
          ),
        ],
      );
    } else if (isWrong) {
      return Column(
        children: [
          Text(
            "❌ Try Again!",
            style: TextStyle(
              fontSize: fontSize * 1,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          SizedBox(height: spacing * 2),
          ElevatedButton(
            onPressed: resetWrong,
            child:
                Text("Try Again", style: TextStyle(fontSize: fontSize * 0.8)),
          ),
        ],
      );
    }
    return SizedBox.shrink();
  }

  Widget _buildConfetti() {
    return ConfettiWidget(
      confettiController: _confettiController,
      blastDirection: pi / 2,
      emissionFrequency: 0.2,
      shouldLoop: false,
      numberOfParticles: 100,
      blastDirectionality: BlastDirectionality.explosive,
      gravity: 0.1,
      colors: [Colors.red, Colors.blue, Colors.green, Colors.yellow],
    );
  }

  Widget draggableShape(ShapeType shapeType, Color color, double size) {
    return Draggable<ShapeType>(
      data: shapeType,
      child: shapeWidget(shapeType, color, size),
      feedback: shapeWidget(shapeType, color, size * 1.2),
      childWhenDragging:
          Opacity(opacity: 0.3, child: shapeWidget(shapeType, color, size)),
    );
  }

  Widget dropTarget(ShapeType shapeType, double size) {
    return DragTarget<ShapeType>(
      onAccept: (shape) => checkAnswer(shape, shapeType),
      builder: (context, candidateData, rejectedData) {
        bool isPlaced = placedShapes[shapeType] ?? false;
        Color shapeColor = isPlaced
            ? (placedShapeColors[shapeType] ?? Colors.orange)
            : Colors.black;

        return Container(
          width: size,
          height: size,
          child: CustomPaint(
            painter: PolygonPainter(shapeType, shapeColor),
          ),
        );
      },
    );
  }

  Widget shapeWidget(ShapeType shapeType, Color color, double size) {
    return Container(
      width: size,
      height: size,
      child: CustomPaint(
        painter: PolygonPainter(shapeType, color),
      ),
    );
  }
}

class CurvedTopPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = Colors.orange.shade500;
    Path path = Path();
    path.moveTo(0, 0);
    path.lineTo(0, size.height * 0.8);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height * 0.8);
    path.lineTo(size.width, 0);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

enum ShapeType { pentagon, hexagon, triangle, rectangle, circle }

class PolygonPainter extends CustomPainter {
  final ShapeType shapeType;
  final Color color;

  PolygonPainter(this.shapeType, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = color;
    Path path = createPolygonPath(shapeType, size);
    canvas.drawPath(path, paint);
  }

  Path createPolygonPath(ShapeType shapeType, Size size) {
    if (shapeType == ShapeType.circle) {
      return Path()..addOval(Rect.fromLTWH(0, 0, size.width, size.height));
    }

    int sides = {
          ShapeType.pentagon: 5,
          ShapeType.hexagon: 6,
          ShapeType.triangle: 3,
          ShapeType.rectangle: 4,
        }[shapeType] ??
        4; // Default to 4 sides if shape is not found

    return Path()
      ..addPolygon(
          List.generate(sides, (i) {
            double angle = (2 * pi * i) / sides;
            return Offset(size.width / 2 + size.width / 2 * cos(angle),
                size.height / 2 + size.height / 2 * sin(angle));
          }),
          true);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
