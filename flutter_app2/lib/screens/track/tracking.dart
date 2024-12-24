import 'package:flutter/material.dart';
import 'package:flutter_app/screens/track/select_day.dart';
import 'package:flutter_app/services/date%20formater.dart';
import '../../widgets/custom appbar.dart';
import '../../widgets/resume workout bar.dart';
import 'daily_data_page.dart';

class Tracking extends StatefulWidget {
  Function expandWhenWk;
  bool workoutInProg;

  Tracking(
      {super.key, required this.expandWhenWk, required this.workoutInProg});

  @override
  State<Tracking> createState() => _TrackingState();
}

class _TrackingState extends State<Tracking> {
  DateTime now = DateTime.now();

  late int daySince2000 = DateTime.utc(now.year, now.month, now.day)
      .difference(DateTime.utc(2000, 1, 1))
      .inDays;

  late PageController pageController = PageController(
    initialPage: daySince2000,
  );

  previousDay() {
    pageController.animateToPage(
      pageController.page!.round() - 1,
      duration: Duration(milliseconds: 200),
      curve: Curves.decelerate,
    );
  }

  nextDay() {
    pageController.animateToPage(
      pageController.page!.round() + 1,
      duration: Duration(milliseconds: 200),
      curve: Curves.decelerate,
    );
  }

  navigateToDay(int day) {
    pageController.jumpToPage(day);
  }

  late ValueNotifier dayNotifier = ValueNotifier(
    daySince2000,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        title: 'Tracking',
        leading: null,
        actions: null,
        context: context,
      ),
      body: Column(
        children: [
          const Padding(padding: EdgeInsets.only(bottom: 8)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  height: 25,
                  width: 25,
                  child: IconButton(
                    padding: const EdgeInsets.all(0),
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      previousDay();
                    },
                    icon: const Icon(Icons.keyboard_arrow_left),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Padding(padding: EdgeInsets.only(right: 25)),
                    ValueListenableBuilder(
                      valueListenable: dayNotifier,
                      builder: (context, value, child) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(padding: EdgeInsets.only(right: 20)),
                            Text(
                              DateFormater.dateToString(
                                  DateTime.utc(2000).add(Duration(
                                days: dayNotifier.value,
                              ))),
                            ),
                            Padding(padding: EdgeInsets.only(right: 5)),
                            SizedBox(
                              height: 25,
                              width: 25,
                              child: IconButton(
                                padding: EdgeInsets.all(0),
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => SelectTrackingDay(
                                      navigateToDay: navigateToDay,
                                      initialDay:
                                          DateTime.utc(2000).add(Duration(
                                        days: dayNotifier.value,
                                      )),
                                    ),
                                  ));
                                },
                                icon: Icon(Icons.calendar_month),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(
                  height: 25,
                  width: 25,
                  child: IconButton(
                    padding: const EdgeInsets.all(0),
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      nextDay();
                    },
                    icon: const Icon(Icons.keyboard_arrow_right),
                  ),
                ),
              ],
            ),
          ),
          const Padding(padding: EdgeInsets.only(bottom: 5)),
          Divider(
            thickness: 0.5,
            height: 0,
            color:
                Theme.of(context).inputDecorationTheme.border!.borderSide.color,
          ),
          Expanded(
              child: PageView.builder(
            physics: BouncingScrollPhysics(),
            itemCount: 36526,
            //physics: NeverScrollableScrollPhysics(),
            onPageChanged: (val) {
              dayNotifier.value = val;
            },
            controller: pageController,
            itemBuilder: (context, index) {
              return DailyDataPage();
            },
          )),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: (widget.workoutInProg == true)
                ? [
                    GestureDetector(
                      onTap: () => widget.expandWhenWk(),
                      child: const ResumeWourkout(),
                    ),
                  ]
                : [],
          )
        ],
      ),
    );
  }
}
