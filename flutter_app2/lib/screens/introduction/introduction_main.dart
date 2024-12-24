import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/screens/introduction/choose_units_page.dart';
import 'package:flutter_app/screens/introduction/intro_done.dart';
import 'package:flutter_app/screens/introduction/intro_page1.dart';
import 'package:flutter_app/screens/introduction/intro_page2.dart';
import 'package:flutter_app/screens/introduction/intro_page3.dart';
import 'package:flutter_app/theme/theme.dart';
import 'package:flutter_app/widgets/bottomnavigbar.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../services/user_preferences.dart';

class IntroductionScreen extends StatefulWidget {
  const IntroductionScreen({super.key});

  @override
  State<IntroductionScreen> createState() => _IntroductionScreenState();
}

class _IntroductionScreenState extends State<IntroductionScreen> {
  final PageController _controller = PageController();

  String rightText = 'Next';

  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: testThemeYellow().scaffoldBackgroundColor,
      body: Stack(
        children: [
          PageView(
            physics: const BouncingScrollPhysics(),
            controller: _controller,
            children: const [
              IntroPage1(),
              IntroPage2(),
              IntroPage3(),
              ChooseUnitsPage(),
              IntroDone(),
            ],
            onPageChanged: (value) {
              if (value == 4) {
                setState(() {
                  rightText = 'Finish';
                });
              } else {
                setState(() {
                  rightText = 'Next';
                });
              }
              setState(() {
                currentPage = value;
              });
            },
          ),
          //dot indicator
          Container(
            alignment: const Alignment(0, 0.75),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: currentPage < 3
                      ? () {
                          _controller.animateToPage(
                            3,
                            duration: const Duration(milliseconds: 700),
                            curve: Curves.easeOutCubic,
                          );
                        }
                      : null,
                  child: Text(
                    currentPage < 3 ? 'Skip' : '',
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
                SmoothPageIndicator(
                  controller: _controller,
                  count: 5,
                  effect: ExpandingDotsEffect(
                    activeDotColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    if (currentPage != 4) {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 700),
                        curve: Curves.easeOutCubic,
                      );
                    } else {
                      await AwesomeNotifications()
                          .isNotificationAllowed()
                          .then((isAllowed) async {
                        if (!isAllowed) {
                          await AwesomeNotifications()
                              .requestPermissionToSendNotifications();
                          AwesomeNotifications()
                              .isNotificationAllowed()
                              .then((isAllowed) async {
                            if (isAllowed) {
                              UserPreferences.setNotificationsOn(true);
                            } else {
                              UserPreferences.setNotificationsOn(false);
                            }
                          });
                        }
                      });
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const MainPage()));
                    }
                  },
                  child: Text(
                    rightText,
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
