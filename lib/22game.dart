import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool isCorrect = false;
  bool isWrong = false;
  bool shapePlaced = false;
  late ConfettiController _confettiController;

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

  void checkAnswer(String number) {
    if (number == "4") {
      setState(() {
        isCorrect = true;
        isWrong = false;
        shapePlaced = true;
      });
      _confettiController.play(); // 🎉 Start confetti animation!
    } else {
      setState(() {
        isCorrect = false;
        isWrong = true;
      });
    }
  }

  void resetGame() {
    setState(() {
      isCorrect = false;
      isWrong = false;
      shapePlaced = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double shortestSide = MediaQuery.of(context).size.shortestSide;
    bool isTablet = shortestSide > 600; // Detects if it's a tablet

    double shapeSize = screenWidth * 0.25;
    double fontSize = screenWidth * 0.06;
    double spacing = screenHeight * 0.02;

    return Scaffold(
      backgroundColor: Colors.amber.shade100,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Column(
              children: [
                // Curved Header
                Container(
                  height: screenHeight * 0.25,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: CurvedTopPainter(),
                    child: Center(
                      child: Text(
                        "Drag the number",
                        style: TextStyle(
                          fontSize: fontSize * 1.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: spacing),

                // Draggable Shapes (Grid Layout)
                if (!shapePlaced)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: spacing),
                    child: Wrap(
                      spacing: screenWidth * 0.05,
                      runSpacing: spacing,
                      alignment: WrapAlignment.center,
                      children: [
                        draggableShape(
                            "3", Colors.orange, ShapeType.triangle, shapeSize),
                        draggableShape(
                            "4", Colors.orange, ShapeType.rectangle, shapeSize),
                        draggableShape(
                            "5", Colors.orange, ShapeType.pentagon, shapeSize),
                        draggableShape(
                            "6", Colors.orange, ShapeType.hexagon, shapeSize),
                      ],
                    ),
                  ),
                SizedBox(height: spacing * 2),

                // Drop Target Area
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "2 + 2 = ",
                      style: TextStyle(
                          fontSize: fontSize * 2, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    DragTarget<String>(
                      onAccept: (number) => checkAnswer(number),
                      builder: (context, candidateData, rejectedData) {
                        return Container(
                          width: shapeSize,
                          height: shapeSize,
                          child: shapePlaced
                              ? shapeWidget("4", Colors.orange,
                                  ShapeType.rectangle, shapeSize)
                              : CustomPaint(
                                  painter: PolygonPainter(
                                      ShapeType.rectangle, Colors.black),
                                ),
                        );
                      },
                    ),
                  ],
                ),

                SizedBox(height: spacing * 2),

                // Result Screens
                if (isCorrect)
                  Column(
                    children: [
                      Text(
                        "🎉 You Win! 🎉",
                        style: TextStyle(
                            fontSize: fontSize * 2,
                            fontWeight: FontWeight.bold,
                            color: Colors.green),
                      ),
                      SizedBox(height: spacing),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context); // Navigate back to HomeScreen
                        },
                        child: Text("Next",
                            style: TextStyle(fontSize: fontSize * 1)),
                      ),
                      SizedBox(height: spacing),
                    ],
                  )
                else if (isWrong)
                  Column(
                    children: [
                      Text(
                        "❌ Try Again!",
                        style: TextStyle(
                            fontSize: fontSize * 1,
                            fontWeight: FontWeight.bold,
                            color: Colors.red),
                      ),
                      SizedBox(height: spacing * 2),
                      ElevatedButton(
                        onPressed: resetGame,
                        child: Text("Try Again",
                            style: TextStyle(fontSize: fontSize * 0.8)),
                      ),
                    ],
                  ),

                // 🎉 Confetti Animation 🎉
                ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirection: pi / 2,
                  emissionFrequency: 0.2,
                  shouldLoop: false,
                  numberOfParticles: 100,
                  blastDirectionality: BlastDirectionality.explosive,
                  gravity: 0.1,
                  colors: [
                    Colors.red,
                    Colors.blue,
                    Colors.green,
                    Colors.yellow
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget draggableShape(
      String number, Color color, ShapeType shapeType, double size) {
    return Draggable<String>(
      data: number,
      child: shapeWidget(number, color, shapeType, size),
      feedback: shapeWidget(number, color, shapeType, size * 1.2),
      childWhenDragging: Opacity(
          opacity: 0.3, child: shapeWidget(number, color, shapeType, size)),
    );
  }

  Widget shapeWidget(
      String number, Color color, ShapeType shapeType, double size) {
    return Container(
      width: size,
      height: size,
      child: CustomPaint(
        painter: PolygonPainter(shapeType, color),
        child: Center(
          child: Text(
            number,
            style: TextStyle(
                fontSize: size * 0.4,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
        ),
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

enum ShapeType { triangle, rectangle, pentagon, hexagon }

class PolygonPainter extends CustomPainter {
  final ShapeType shapeType;
  final Color color;

  PolygonPainter(this.shapeType, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = color;
    Path path;

    if (shapeType == ShapeType.rectangle) {
      // Draw a rectangle
      path = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    } else {
      // Draw other polygon shapes
      path = createPolygonPath(shapeType, size);
    }

    canvas.drawPath(path, paint);
  }

  Path createPolygonPath(ShapeType shapeType, Size size) {
    int sides = shapeType == ShapeType.triangle
        ? 3
        : shapeType == ShapeType.pentagon
            ? 5
            : 6;
    double angle = (2 * pi) / sides;
    double radius = size.width / 2;
    Offset center = Offset(size.width / 2, size.height / 2);
    Path path = Path();
    path.moveTo(center.dx + radius, center.dy);
    for (int i = 1; i < sides; i++)
      path.lineTo(center.dx + radius * cos(i * angle),
          center.dy + radius * sin(i * angle));
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
