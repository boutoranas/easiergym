import 'package:flutter/material.dart';
import 'package:flutter_app/theme/theme.dart';

class IntroDone extends StatelessWidget {
  const IntroDone({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: testThemeYellow().scaffoldBackgroundColor,
      body: Stack(
        children: [
          Container(
            alignment: const Alignment(0, -0.65),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'That\'s it!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'You are now ready to start working out with Easier Gym!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: const Alignment(0, 0.1),
            child: Icon(
              Icons.done_outline_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: 70,
            ),
          ),
          //align 0, 0.1
        ],
      ),
    );
  }
}
