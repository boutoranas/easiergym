import 'package:flutter/material.dart';

import '../../theme/theme.dart';

class IntroPage2 extends StatelessWidget {
  const IntroPage2({super.key});

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
                    'Get advanced analysis',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Visualize your performance and measurements data in the form of graphs!',
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
              image: AssetImage('assets/images/intro2.png'),
            ),
          ),
          //align 0, 0.1
        ],
      ),
    );
  }
}
