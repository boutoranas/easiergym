import 'package:flutter/material.dart';
import 'package:flutter_app/theme/theme.dart';

class IntroPage1 extends StatelessWidget {
  const IntroPage1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: testThemeYellow().scaffoldBackgroundColor,
      body: Stack(
        children: [
          Container(
            alignment: const Alignment(0, -0.7),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Track your workouts',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Take note of the exercices performed, the number of sets and more!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Align(
            alignment: Alignment(0, 0.2),
            child: Image(
              image: AssetImage('assets/images/intro1.png'),
            ),
          ),
          //align 0, 0.1
        ],
      ),
    );
  }
}
