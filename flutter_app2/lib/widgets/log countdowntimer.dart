import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/services/data_update.dart';

import '../services/user_preferences.dart';

class CountDownTimer extends StatefulWidget {
  const CountDownTimer({Key? key}) : super(key: key);

  @override
  State<CountDownTimer> createState() => CountDownTimerState();
}

class CountDownTimerState extends State<CountDownTimer>
    with WidgetsBindingObserver {
  //!audio
  final audioPlayer = AudioPlayer();

  num maxSeconds = DataGestion.maxSeconds;
  num seconds = DataGestion.seconds;
  Timer? timer;
  bool toggle = UserPreferences.getTimerStarted();
  bool paused = UserPreferences.getTimerPaused();
  DateTime? endTime = UserPreferences.getEndTime();

  @override
  void initState() {
    //observe life cycle
    WidgetsBinding.instance.addObserver(this);
    //
    if (endTime != null && endTime!.isAfter(DateTime.now())) {
      //on going
      if (toggle == true && paused == false) {
        setState(() {
          seconds = endTime!.difference(DateTime.now()).inSeconds;
        });
        resumeTimer();
      }
      //resumed
      else if (toggle == true && paused == true) {
        setState(() {
          endTime = DateTime.now()
              .add(Duration(milliseconds: (seconds * 1000).round()));
          //seconds = endTime!.difference(DateTime.now()).inMilliseconds / 1000;
        });
      }
      if (toggle == false) {
        paused = false;
        DataGestion.paused = paused;
      }
    }
    //stopped
    else {
      if (toggle == true && paused == true) {
      } else {
        DataGestion.timerStarted = false;
        DataGestion.paused = false;
        UserPreferences.setTimerStarted(false);
        UserPreferences.setTimerPaused(true);
        resetTimer();
      }
    }

    super.initState();
  }

  bool appStateResumed = true;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      setState(() {
        appStateResumed = false;
      });
    } else {
      setState(() {
        appStateResumed = true;
      });
    }
  }

  triggerTimer() {
    bool finished = false;
    timer = Timer.periodic(const Duration(milliseconds: 50), (timer) async {
      if (seconds > 0.05) {
        setState(() {
          seconds = endTime!.difference(DateTime.now()).inMilliseconds / 1000;
          DataGestion.seconds = seconds;
        });
      } else {
        if (finished != true) {
          if (appStateResumed == true) {
            //print('played');
            if (DataGestion.soundOn == true) {
              await audioPlayer.play(
                  AssetSource('sounds/flutter_sound_effect.mp3'),
                  volume: 100);
            }
          }
          await Future.delayed(const Duration(milliseconds: 500));
          resetTimer();
        }
        setState(() {
          finished = true;
        });
      }
    });
  }

  resumeTimer() {
    setState(() {
      paused = false;
      endTime =
          DateTime.now().add(Duration(milliseconds: (seconds * 1000).round()));
    });
    triggerTimer();
  }

  startTimer() async {
    stopTimer();
    //paused = false;
    DataGestion.paused = paused;
    DataGestion.maxSeconds = maxSeconds;
    DataGestion.seconds = seconds;
    setState(() {
      toggle = true;
      endTime = DateTime.now()
          .add(Duration(milliseconds: (maxSeconds * 1000).round()));
      DataGestion.endTime = endTime;
    });

    triggerTimer();
  }

  resetTimer() {
    stopTimer();
    setState(() {
      endTime = null;
      DataGestion.endTime = endTime;
      toggle = false;
      paused = false;
      seconds = maxSeconds;
      DataGestion.seconds = seconds;
      DataGestion.timerStarted = toggle;
      DataGestion.paused = paused;
    });
  }

  stopTimer() {
    if (timer != null) {
      timer!.cancel();
    }
  }

  incrementSecs() {
    if (seconds < 3595) {
      setState(() {
        if (endTime != null) {
          endTime = endTime!.add(const Duration(seconds: 5));
          DataGestion.endTime = endTime;
        }
        maxSeconds = maxSeconds + 5;
        seconds = seconds + 5;
        DataGestion.maxSeconds = maxSeconds;
        DataGestion.seconds = seconds;
      });
    }
  }

  incrementMins() {
    if (seconds < 3535) {
      setState(() {
        if (endTime != null) {
          endTime = endTime!.add(const Duration(minutes: 1));
          DataGestion.endTime = endTime;
        }
        maxSeconds = maxSeconds + 60;
        seconds = seconds + 60;
        DataGestion.maxSeconds = maxSeconds;
        DataGestion.seconds = seconds;
      });
    }
  }

  decrementSecs() {
    if (seconds > 5) {
      setState(() {
        if (endTime != null) {
          endTime = endTime!.subtract(const Duration(seconds: 5));
          DataGestion.endTime = endTime;
        }
        maxSeconds = maxSeconds - 5;
        seconds = seconds - 5;
        DataGestion.maxSeconds = maxSeconds;
        DataGestion.seconds = seconds;
      });
    }
  }

  decrementMins() {
    if (seconds > 60) {
      setState(() {
        if (endTime != null) {
          endTime = endTime!.subtract(const Duration(minutes: 1));
          DataGestion.endTime = endTime;
        }
        maxSeconds = maxSeconds - 60;
        seconds = seconds - 60;
        DataGestion.maxSeconds = maxSeconds;
        DataGestion.seconds = seconds;
      });
    } else if (seconds.floor() == 60) {
      setState(() {
        maxSeconds = maxSeconds - 55;
        seconds = seconds - 55;
        DataGestion.maxSeconds = maxSeconds;
        DataGestion.seconds = seconds;
      });
    }
  }

  Widget buildTime() {
    String twoDigits(int n) => n.toString().padLeft(2, '0');

    final second = twoDigits(seconds.floor() % 60);
    final minute = twoDigits((seconds / 60).floor());

    return Text("$minute:$second");
  }

  @override
  void dispose() {
    if (timer != null) {
      timer!.cancel();
    }
    DataGestion.maxSeconds = maxSeconds;
    DataGestion.paused = false;
    DataGestion.timerStarted = false;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (toggle == true) {
      return buildTime();
    } else {
      return const Text(
        'Workout log',
        style: TextStyle(
          fontWeight: FontWeight.w800,
        ),
      );
    }
  }
}
