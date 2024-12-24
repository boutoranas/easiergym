import 'package:flutter/material.dart';
import 'package:flutter_app/theme/theme.dart';

class IntroPage3 extends StatelessWidget {
  const IntroPage3({super.key});

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
                    'Explore routines',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Get access to numerous routines and perform the best routines that suit your goal!',
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
              image: AssetImage('assets/images/intro3.png'),
            ),
          ),
          //align 0, 0.1
        ],
      ),
    );
  }
}
