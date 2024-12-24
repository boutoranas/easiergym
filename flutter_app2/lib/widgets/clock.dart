import 'dart:async';

import 'package:capped_progress_indicator/capped_progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/services/data_update.dart';

import 'button.dart';

class Clock extends StatefulWidget {
  final Function timerControl;
  const Clock({super.key, required this.timerControl});

  @override
  State<Clock> createState() => _ClockState();
}

class _ClockState extends State<Clock> {
  Timer? timer;
  //int window = 0;
  bool timerStarted = DataGestion.timerStarted;
  bool paused = DataGestion.paused;
  //ValueNotifier seconds = ValueNotifier(DataGestion.seconds);
  num seconds = DataGestion.seconds;
  num maxSeconds = DataGestion.maxSeconds;

  bool activated = true;

  startTimer() {
    timer = Timer.periodic(const Duration(milliseconds: 50), (timer) async {
      if (seconds > 0.05) {
        setState(() {
          seconds = DataGestion.seconds;
          activated = false;
        });
        /* setState(() {
          seconds = DataGestion.seconds;
        }); */
      } else {
        await Future.delayed(const Duration(milliseconds: 300));
        resetTimer();
      }
    });
  }

  resetTimer() async {
    stopTimer();
    setState(() {
      seconds = maxSeconds;
      timerStarted = false;
      paused = false;
      DataGestion.timerStarted = timerStarted;
      DataGestion.paused = paused;
    });
    await Future.delayed(const Duration(milliseconds: 700));
    setState(() {
      activated = true;
    });
  }

  stopTimer() {
    if (timer != null) {
      timer!.cancel();
    }
  }

  /* cancelTimer() {
    if (timer != null) {
      timer!.cancel();
    }
  } */

  incrementSecs() {
    if (seconds < 3595) {
      setState(() {
        maxSeconds = maxSeconds + 5;
        seconds = seconds + 5;
      });
    }
  }

  incrementMins() {
    if (seconds < 3535) {
      setState(() {
        maxSeconds = maxSeconds + 60;
        seconds = seconds + 60;
      });
    }
  }

  decrementSecs() {
    if (seconds > 5) {
      setState(() {
        maxSeconds = maxSeconds - 5;
        seconds = seconds - 5;
      });
    }
  }

  decrementMins() {
    if (seconds > 60) {
      setState(() {
        maxSeconds = maxSeconds - 60;
        seconds = seconds - 60;
      });
    } else if (seconds.floor() == 60) {
      setState(() {
        maxSeconds = maxSeconds - 55;
        seconds = seconds - 55;
      });
    }
  }

  Widget buildTime(value) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');

    final second = twoDigits(value.floor() % 60);
    final minute = twoDigits((value / 60).floor());

    return Text(
      "$minute:$second",
      style: const TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
    );
  }

  Widget buildMaxTime(value) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');

    final second = twoDigits(value.floor() % 60);
    final minute = twoDigits((value / 60).floor());

    return Text(
      "$minute:$second",
      style: const TextStyle(
        fontSize: 25,
      ),
    );
  }

  Widget buildTimer() {
    return Column(
      children: [
        SizedBox(
          height: 200,
          width: 200,
          child: Stack(
            fit: StackFit.expand,
            children: [
              /* CircularProgressIndicator(
                value: seconds / maxSeconds, //seconds / maxSeconds,
                strokeWidth: 13,
              ), */
              CircularCappedProgressIndicator(
                value: seconds / maxSeconds,
                //strokeWidth: 18,
                color: Colors.black,
              ),
              CircularCappedProgressIndicator(
                value: seconds / maxSeconds,
                strokeWidth: 14,
                backgroundColor: Colors.grey.withOpacity(0.5),
              ),
              Center(
                child: buildTime(seconds),
              ),
              Positioned(
                top: 25,
                right: 69,
                child: Center(
                  child: timerStarted == true ? buildMaxTime(maxSeconds) : null,
                ),
              ),
              //top left
              Positioned(
                top: 45,
                left: 42,
                child: GestureDetector(
                  onTap: () {
                    incrementMins();
                    widget.timerControl("+m");
                  },
                  child: const Icon(
                    Icons.arrow_drop_up,
                    size: 50,
                  ),
                ),
              ),
              //top right
              Positioned(
                top: 45,
                right: 42,
                child: GestureDetector(
                  onTap: () {
                    incrementSecs();
                    widget.timerControl("+s");
                  },
                  child: const Icon(
                    Icons.arrow_drop_up,
                    size: 50,
                  ),
                ),
              ),
              //bottom left
              Positioned(
                bottom: 45,
                left: 42,
                child: GestureDetector(
                  onTap: () {
                    decrementMins();
                    widget.timerControl("-m");
                  },
                  child: const Icon(
                    Icons.arrow_drop_down,
                    size: 50,
                  ),
                ),
              ),
              //bottom right
              Positioned(
                bottom: 45,
                right: 42,
                child: GestureDetector(
                  onTap: () {
                    decrementSecs();
                    widget.timerControl("-s");
                  },
                  child: const Icon(
                    Icons.arrow_drop_down,
                    size: 50,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    seconds = DataGestion.seconds;
    maxSeconds = DataGestion.maxSeconds;
    if (timerStarted == true && paused == false) {
      startTimer();
    }
    if (timerStarted == false) {
      DataGestion.seconds = maxSeconds;
      seconds = maxSeconds;
    }
    super.initState();
  }

  @override
  void dispose() {
    if (timer != null) {
      timer!.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.all(0),
      contentPadding: const EdgeInsets.only(bottom: 60, top: 60),
      title: const Center(child: Text("Rest timer:")),
      content: Container(
        margin: const EdgeInsets.only(right: 30, left: 30),
        height: 225,
        width: 200,
        child: buildTimer(),
      ),
      actions: timerStarted == false
          ? [
              //start button

              button(
                context: context,
                onPressed: activated == true
                    ? () {
                        startTimer();
                        setState(() {
                          timerStarted = true;
                          DataGestion.timerStarted = timerStarted;
                        });
                        widget.timerControl("start");
                      }
                    : null,
                text: 'Start timer',
                width: 340,
                color: const Color.fromARGB(255, 255, 198, 9),
              ),
            ]
          : [
              Row(
                children: [
                  paused == false
                      ? button(
                          context: context,
                          onPressed: () {
                            setState(() {
                              paused = true;
                              DataGestion.paused = paused;
                            });
                            stopTimer();
                            widget.timerControl("stop");
                          },
                          text: 'Pause timer',
                          width: 167.5,
                          color: const Color.fromARGB(255, 9, 165, 255),
                        )
                      : button(
                          context: context,
                          onPressed: () {
                            startTimer();
                            setState(() {
                              paused = false;
                              DataGestion.paused = paused;
                            });
                            widget.timerControl("resume");
                          },
                          text: 'Resume',
                          width: 167.5,
                          color: const Color.fromARGB(255, 38, 255, 9),
                        ),
                  const SizedBox(
                    width: 5,
                  ),
                  //stop button
                  button(
                    context: context,
                    onPressed: () {
                      resetTimer();
                      setState(() {
                        timerStarted = false;
                        paused = false;
                        DataGestion.paused = paused;
                        DataGestion.timerStarted = timerStarted;
                      });
                      widget.timerControl("reset");
                    },
                    text: 'Stop timer',
                    color: const Color.fromARGB(255, 255, 17, 9),
                    width: 167.5,
                  )
                ],
              ),
            ],
    );
  }
}
