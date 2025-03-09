import 'package:dragnumbershapes/21game.dart';
import 'package:dragnumbershapes/22game.dart';
import 'package:dragnumbershapes/41game.dart';
import 'package:dragnumbershapes/RGB_color_match1.dart';
import 'package:dragnumbershapes/shapes_drag.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(NumberDragGame());
}

class NumberDragGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber.shade100,
      appBar: AppBar(
        title: Text("Number Drag Game"),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GameScreen2()),
                );
              },
              child: Text("4+1="),
            ),
            SizedBox(height: 20), // Adds spacing between buttons
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GameScreen()),
                );
              },
              child: Text("2+2="),
            ),
            SizedBox(height: 20), // Adds spacing between buttons
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GameScreen3()),
                );
              },
              child: Text("2+1="),
            ),
            SizedBox(height: 20), // Adds spacing between buttons
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GameScreen4()),
                );
              },
              child: Text("shapes drag"),
            ),
            SizedBox(height: 20), // Adds spacing between buttons
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GameScreen5()),
                );
              },
              child: Text("RGB color match"),
            ),
          ],
        ),
      ),
    );
  }
}

// Ensure you have the GameScreen() class implemented elsewhere in your project.
