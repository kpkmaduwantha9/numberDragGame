import 'package:dragnumbershapes/22game.dart';
import 'package:dragnumbershapes/41game.dart';
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
              child: Text("Go to GameScreen2"),
            ),
            SizedBox(height: 20), // Adds spacing between buttons
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GameScreen()),
                );
              },
              child: Text("Go to GameScreen"),
            ),
            SizedBox(height: 20), // Adds spacing between buttons
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GameScreen()),
                );
              },
              child: Text("Go to GameScreen"),
            ),
          ],
        ),
      ),
    );
  }
}

// Ensure you have the GameScreen() class implemented elsewhere in your project.
