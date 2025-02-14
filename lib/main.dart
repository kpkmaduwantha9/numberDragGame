import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(NumberDragGame());
}

class NumberDragGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GameScreen(),
    );
  }
}

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
    _confettiController = ConfettiController(duration: Duration(seconds: 3));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void checkAnswer(String number) {
    if (number == "5") {
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
    return Scaffold(
      backgroundColor: Colors.amber.shade100,
      body: Stack(
        children: [
          Column(
            children: [
              // Custom Curved Banner
              Container(
                height: 150,
                child: CustomPaint(
                  painter: CurvedTopPainter(),
                  child: Center(
                    child: Text(
                      "Drag the number",
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 80),

              // Draggable Number Shapes (Fixed 2x2 Layout)
              if (!shapePlaced)
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        draggableShape(
                            "5", Colors.orange.shade700, ShapeType.pentagon),
                        SizedBox(width: 40),
                        draggableShape(
                            "6", Colors.orange.shade700, ShapeType.hexagon),
                      ],
                    ),
                    SizedBox(height: 50),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        draggableShape(
                            "3", Colors.orange.shade700, ShapeType.triangle),
                        SizedBox(width: 40),
                        draggableShape(
                            "8", Colors.orange.shade700, ShapeType.octagon),
                      ],
                    ),
                  ],
                ),
              SizedBox(height: 80),

              // Drop Target Area
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "4 + 1 = ",
                    style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 10),
                  DragTarget<String>(
                    onAccept: (number) => checkAnswer(number),
                    builder: (context, candidateData, rejectedData) {
                      return Container(
                        width: 80,
                        height: 80,
                        child: shapePlaced
                            ? shapeWidget("5", Colors.orange.shade700,
                                ShapeType.pentagon) // Keep correct shape
                            : CustomPaint(
                                painter: PolygonPainter(
                                    ShapeType.pentagon, Colors.black),
                              ),
                      );
                    },
                  ),
                ],
              ),

              SizedBox(height: 30),

              // Result Screens
              if (isCorrect)
                Column(
                  children: [
                    Text(
                      "🎉 You Win! 🎉",
                      style: TextStyle(
                          fontSize: 45,
                          fontWeight: FontWeight.bold,
                          color: Colors.green),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: resetGame,
                      child: Text("Next"),
                    ),
                    SizedBox(height: 20),
                    Image.network(
                      'https://drive.google.com/uc?export=view&id=1ewQjdd9gOLAU-12WJ6kG_FpaZUK86f7e',
                      height: 200,
                      width: 200,
                    ),
                  ],
                )
              else if (isWrong)
                Column(
                  children: [
                    Text(
                      "❌ Try Again!",
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.red),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: resetGame,
                      child: Text("Try Again"),
                    ),
                  ],
                ),
            ],
          ),

          // 🎉 Confetti Animation 🎉
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2, // Upwards
              emissionFrequency: 0.2,
              shouldLoop: false,
              numberOfParticles: 100,
              blastDirectionality: BlastDirectionality.explosive,
              gravity: 0.1,
              colors: [Colors.red, Colors.blue, Colors.green, Colors.yellow],
            ),
          ),
        ],
      ),
    );
  }

  // Function to create draggable number shapes
  Widget draggableShape(String number, Color color, ShapeType shapeType) {
    return Draggable<String>(
      data: number,
      child: shapeWidget(number, color, shapeType),
      feedback: shapeWidget(number, color, shapeType, scale: 1.2),
      childWhenDragging:
          Opacity(opacity: 0.3, child: shapeWidget(number, color, shapeType)),
    );
  }

  // Function to create the shape widgets
  Widget shapeWidget(String number, Color color, ShapeType shapeType,
      {double scale = 1.0}) {
    return Transform.scale(
      scale: scale,
      child: Container(
        width: 90,
        height: 90,
        child: CustomPaint(
          painter: PolygonPainter(shapeType, color),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

// Custom Painter for Polygon Shapes
class PolygonPainter extends CustomPainter {
  final ShapeType shapeType;
  final Color color;

  PolygonPainter(this.shapeType, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = color;
    Path path = Path();

    switch (shapeType) {
      case ShapeType.pentagon:
        path = createPolygonPath(5, size);
        break;
      case ShapeType.hexagon:
        path = createPolygonPath(6, size);
        break;
      case ShapeType.triangle:
        path = createPolygonPath(3, size);
        break;
      case ShapeType.octagon:
        path = createPolygonPath(8, size);
        break;
    }

    canvas.drawPath(path, paint);
  }

  Path createPolygonPath(int sides, Size size) {
    Path path = Path();
    double angle = (2 * pi) / sides;
    double radius = size.width / 2;
    Offset center = Offset(size.width / 2, size.height / 2);

    for (int i = 0; i < sides; i++) {
      double x = center.dx + radius * cos(i * angle);
      double y = center.dy + radius * sin(i * angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Enum for shape types
enum ShapeType { pentagon, hexagon, triangle, octagon }

// Custom Painter for the Curved Top Banner
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
