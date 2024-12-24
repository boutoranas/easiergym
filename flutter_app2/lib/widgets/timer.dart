import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app/services/data_update.dart';
import 'package:flutter_app/services/user_preferences.dart';

class Timerr extends StatefulWidget {
  const Timerr({super.key});

  @override
  State<Timerr> createState() => _TimerrState();
}

class _TimerrState extends State<Timerr> {
  Duration duration = const Duration();
  late Timer? timer;

  int seconds = 0;

  Widget buildTime() {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    if (hours == "00") {
      return Text("Duration: $minutes:$seconds");
    } else {
      return Text("Duration: $hours:$minutes:$seconds");
    }
  }

  @override
  void initState() {
    DateTime initTime = DataGestion.initTime ?? DateTime.now();

    seconds = DateTime.now().difference(initTime).inSeconds;
    duration = Duration(seconds: seconds);
    DataGestion.time = duration.inSeconds;

    DataGestion.initTime = initTime;
    UserPreferences.saveInitTime(initTime);
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        //final seconds = duration.inSeconds + 1;
        seconds = DateTime.now().difference(initTime).inSeconds;
        duration = Duration(seconds: seconds);
        DataGestion.time = duration.inSeconds;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return buildTime();
  }
}
