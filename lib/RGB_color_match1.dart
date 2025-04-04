import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

class GameScreen5 extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen5>
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  AnimationController? _tutorialAnimationController;
  Animation<double>? _handAnimationX;
  Animation<double>? _handAnimationY;

  bool showTutorial = true;
  Offset? redCirclePosition;
  Offset? redTextPosition;
  Size? redCircleSize;
  int tutorialRepeatCount = 0;
  final int maxTutorialRepeats = 3;

  // Define the colors for draggable circles
  final List<ColorItem> draggableColors = [
    ColorItem(name: "RED", color: Colors.red),
    ColorItem(name: "BLUE", color: Colors.blue),
    ColorItem(name: "GREEN", color: Colors.green),
  ];

  // Define the order for target text labels
  final List<String> targetColorNames = [
    "GREEN",
    "RED",
    "BLUE",
  ];

  final Map<String, bool> placedColors = {};
  final Map<String, Color> textColors = {};
  bool isWrong = false;
  double handSize = 100.0; // Increased hand size
  bool isGameReset = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: Duration(seconds: 5));

    // Initialize the maps
    for (var colorItem in draggableColors) {
      placedColors[colorItem.name] = false;
      textColors[colorItem.name] = Colors.black;
    }

    // Initialize the tutorial animation
    _initTutorialAnimation();

    // Schedule a callback to start the tutorial after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      startTutorial();
    });
  }

  void _initTutorialAnimation() {
    // Dispose old controller if it exists
    _tutorialAnimationController?.dispose();

    // Create a new animation controller
    _tutorialAnimationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    // Create placeholder animations (will be properly initialized after layout)
    _handAnimationX = Tween<double>(begin: 0.0, end: 0.0)
        .animate(_tutorialAnimationController!);
    _handAnimationY = Tween<double>(begin: 0.0, end: 0.0)
        .animate(_tutorialAnimationController!);

    // Reset counter
    tutorialRepeatCount = 0;

    // Listen for animation completion to handle repeats
    _tutorialAnimationController!.addStatusListener(_handleAnimationStatus);
  }

  void _handleAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      tutorialRepeatCount++;
      if (tutorialRepeatCount < maxTutorialRepeats) {
        // Reset the hand position without animation
        Future.delayed(Duration(milliseconds: 300), () {
          if (mounted && showTutorial && _tutorialAnimationController != null) {
            _tutorialAnimationController!.reset();
            Future.delayed(Duration(milliseconds: 300), () {
              if (mounted &&
                  showTutorial &&
                  _tutorialAnimationController != null) {
                _tutorialAnimationController!.forward();
              }
            });
          }
        });
      } else {
        // End tutorial after 3 repetitions
        if (mounted) {
          setState(() {
            showTutorial = false;
          });
        }
      }
    }
  }

  void startTutorial() {
    // Wait a moment for the UI to be fully rendered
    Future.delayed(Duration(milliseconds: 800), () {
      if (!mounted) return;

      if (redCirclePosition != null &&
          redTextPosition != null &&
          redCircleSize != null &&
          _tutorialAnimationController != null) {
        // Calculate the start and end positions for the hand
        final startX =
            redCirclePosition!.dx + redCircleSize!.width / 2 - handSize / 2;
        final startY =
            redCirclePosition!.dy + redCircleSize!.height / 2 - handSize / 2;
        final endX = redTextPosition!.dx;
        final endY = redTextPosition!.dy;

        // Update the animations with the correct path
        _handAnimationX = Tween<double>(
          begin: startX,
          end: endX,
        ).animate(CurvedAnimation(
          parent: _tutorialAnimationController!,
          curve: Curves.easeInOut,
        ));

        _handAnimationY = Tween<double>(
          begin: startY,
          end: endY,
        ).animate(CurvedAnimation(
          parent: _tutorialAnimationController!,
          curve: Curves.easeInOut,
        ));

        // Reset counter and start the animation
        tutorialRepeatCount = 0;
        _tutorialAnimationController!.forward();
      } else {
        // If positions aren't ready yet, try again after a delay
        Future.delayed(Duration(milliseconds: 500), () {
          if (mounted) startTutorial();
        });
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _tutorialAnimationController?.dispose();
    super.dispose();
  }

  void checkAnswer(ColorItem colorItem, String targetColorName) {
    if (colorItem.name == targetColorName) {
      setState(() {
        placedColors[colorItem.name] = true;
        textColors[colorItem.name] = colorItem.color;
        isWrong = false;
      });

      if (placedColors.values.every((isPlaced) => isPlaced)) {
        _confettiController.play();
      }
    } else {
      setState(() {
        isWrong = true;
      });
    }
  }

  void resetGame() {
    // Stop any ongoing animations
    _tutorialAnimationController?.stop();

    setState(() {
      // Mark as reset to handle special logic
      isGameReset = true;

      // Reset game state
      placedColors.updateAll((key, value) => false);
      textColors.updateAll((key, value) => Colors.black);
      isWrong = false;
      showTutorial = true;

      // Reset positions to force recalculation
      redCirclePosition = null;
      redTextPosition = null;
      redCircleSize = null;
    });

    // Re-initialize the tutorial animation
    _initTutorialAnimation();

    // Schedule tutorial start after layout is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Clear the reset flag
      isGameReset = false;
      // Start tutorial with a delay to ensure positions are updated
      Future.delayed(Duration(milliseconds: 1000), () {
        if (mounted) startTutorial();
      });
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
          double circleSize = screenWidth * 0.15;
          double fontSize = screenWidth * 0.06;
          double spacing = screenHeight * 0.02;

          return Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHeader(fontSize, screenHeight),
                    SizedBox(height: spacing),
                    _buildDropTargets(fontSize, screenWidth),
                    SizedBox(height: spacing * 4),
                    _buildDraggableCircles(circleSize, screenWidth),
                    SizedBox(height: spacing * 4),
                    _buildResultUI(fontSize, spacing),
                    _buildConfetti(),
                  ],
                ),
              ),
              if (showTutorial &&
                  _handAnimationX != null &&
                  _handAnimationY != null &&
                  _tutorialAnimationController != null)
                _buildTutorialHand(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTutorialHand() {
    return AnimatedBuilder(
      animation: _tutorialAnimationController!,
      builder: (context, child) {
        return Positioned(
          left: _handAnimationX!.value,
          top: _handAnimationY!.value,
          child: Image.asset(
            'assets/images/hand.png',
            width: handSize,
            height: handSize,
          ),
        );
      },
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
            "Match the Colors",
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

  Widget _buildDropTargets(double fontSize, double screenWidth) {
    return Wrap(
      spacing: screenWidth * 0.1,
      runSpacing: fontSize * 1.5,
      alignment: WrapAlignment.center,
      children: targetColorNames.map((colorName) {
        Widget target = dropTarget(colorName, fontSize);

        // Store the position of the RED text for the tutorial
        if (colorName == "RED") {
          return Builder(
            builder: (context) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted && !isGameReset) {
                  RenderBox? box = context.findRenderObject() as RenderBox?;
                  if (box != null) {
                    Offset position = box.localToGlobal(Offset.zero);
                    setState(() {
                      redTextPosition = position;
                    });
                  }
                }
              });
              return target;
            },
          );
        }
        return target;
      }).toList(),
    );
  }

  Widget _buildDraggableCircles(double circleSize, double screenWidth) {
    if (placedColors.values.every((isPlaced) => isPlaced)) {
      return SizedBox.shrink();
    }

    return Wrap(
      spacing: screenWidth * 0.1,
      runSpacing: circleSize * 0.5,
      alignment: WrapAlignment.center,
      children: draggableColors.map((colorItem) {
        bool isPlaced = placedColors[colorItem.name] ?? false;
        Color displayColor =
            isPlaced ? colorItem.color.withOpacity(0.2) : colorItem.color;

        Widget circle = draggableCircle(colorItem, displayColor, circleSize);

        // Store the position of the red circle for the tutorial
        if (colorItem.name == "RED") {
          return Builder(
            builder: (context) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted && !isGameReset) {
                  RenderBox? box = context.findRenderObject() as RenderBox?;
                  if (box != null) {
                    Offset position = box.localToGlobal(Offset.zero);
                    Size size = box.size;
                    setState(() {
                      redCirclePosition = position;
                      redCircleSize = size;
                    });
                  }
                }
              });
              return circle;
            },
          );
        }
        return circle;
      }).toList(),
    );
  }

  Widget _buildResultUI(double fontSize, double spacing) {
    if (placedColors.values.every((isPlaced) => isPlaced)) {
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
            onPressed: resetGame,
            child: Text("Play Again", style: TextStyle(fontSize: fontSize * 1)),
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

  Widget draggableCircle(ColorItem colorItem, Color displayColor, double size) {
    return Draggable<ColorItem>(
      data: colorItem,
      child: circleWidget(displayColor, size * 1.5),
      feedback: circleWidget(displayColor, size * 1.5),
      childWhenDragging:
          Opacity(opacity: 0.3, child: circleWidget(displayColor, size * 1.5)),
    );
  }

  Widget dropTarget(String colorName, double fontSize) {
    return DragTarget<ColorItem>(
      onAccept: (colorItem) => checkAnswer(colorItem, colorName),
      builder: (context, candidateData, rejectedData) {
        Color textColor = textColors[colorName] ?? Colors.black;

        return Container(
          padding: EdgeInsets.all(1),
          child: Text(
            colorName,
            style: TextStyle(
              fontSize: fontSize * 2,
              fontWeight: FontWeight.w900,
              color: textColor,
            ),
          ),
        );
      },
    );
  }

  Widget circleWidget(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5,
            offset: Offset(2, 2),
          ),
        ],
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

class ColorItem {
  final String name;
  final Color color;

  ColorItem({required this.name, required this.color});
}
