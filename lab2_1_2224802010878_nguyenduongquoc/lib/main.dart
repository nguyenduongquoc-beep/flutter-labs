import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: EdgeInsets.all(20), // Task 3: thêm padding
          child: LayoutApp(),
        ),
      ),
    );
  }
}

class LayoutApp extends StatelessWidget {
  const LayoutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center, // căn giữa dọc
      children: [

        const Text(
          "I'm in a Column and Centered. The below is a row.",
        ),

        const SizedBox(height: 20),

        // Task 1: Row căn giữa
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0), // Task 3
              child: Container(
                width: 100,
                height: 100,
                color: Colors.red,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: 100,
                height: 100,
                color: Colors.green,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: 100,
                height: 100,
                color: Colors.blue,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Task 2: Stack topLeft
        Stack(
          alignment: Alignment.topLeft,
          children: [
            Container(
              width: 300,
              height: 200,
              color: Colors.yellow,
            ),
            const Padding(
              padding: EdgeInsets.all(10), // Task 3
              child: Text(
                "Stacked on Yellow Box",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}