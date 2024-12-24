import 'dart:convert';

import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/const.dart';
import 'package:flutter_app/in%20app%20data.dart';
import 'package:flutter_app/services/user_preferences.dart';
import 'package:flutter_app/widgets/button.dart';
import 'package:flutter_app/widgets/snack_bar.dart';

import '../../main.dart';
import '../../services/app_media_query.dart';
import '../../services/data_update.dart';
import '../../widgets/clock.dart';
import '../../widgets/log countdowntimer.dart';
import '../../widgets/timer.dart';
import '../../widgets/volume.dart';
import 'congrats page.dart';
import 'local widgets/exercice in log card.dart';
import 'log exercices page.dart';
import 'log reorder exercices page.dart';

class WorkoutLog extends StatefulWidget {
  final Function reduced;
  final Function reduce;
  final Function workoutEnd;
  final String? rName;
  final String? rId;
  const WorkoutLog(
      {super.key,
      required this.reduce,
      required this.reduced,
      required this.workoutEnd,
      required this.rName,
      required this.rId});

  @override
  State<WorkoutLog> createState() => _WorkoutLogState();
}

class _WorkoutLogState extends State<WorkoutLog> with RouteAware {
  ScrollController scrollController = ScrollController();

  final userID = FirebaseAuth.instance.currentUser!.uid;
  late DatabaseReference database =
      FirebaseDatabase.instance.ref().child("users").child(userID);

  late DatabaseReference ref = FirebaseDatabase.instance
      .ref()
      .child("users")
      .child(userID)
      .child("easiergym");

  Map? userDataMapCopy = DataGestion.userDataMapCopy;
  //json.decode(json.encode(DataGestion.userDataMap));
  late List exsInLog = DataGestion.exercicesList(userDataMapCopy, widget.rId);
  Map? logMap = {};
  Map? userDataMap = DataGestion.userDataMap;
  num vol = 0;
  num sets = 0;

  Map exercices = InAppData.exercices;

  late String routineName = widget.rName!;
  late String assignedId;

  TextEditingController routineEditController = TextEditingController();

  int startTime = DateTime.now().millisecondsSinceEpoch;

  @override
  void initState() {
    UserPreferences.setWorkoutInProgress(true);

    DataGestion.volume = 0;
    DataGestion.sets = 0;

    if (widget.rId != null) {
      setState(() {
        assignedId = widget.rId!;
      });
      assignedId = widget.rId!;
      UserPreferences.saveAssignedId(assignedId);
      DataGestion.userDataMapCopy = userDataMapCopy;
    } else {
      setState(() {
        assignedId = ref.child("logs").push().key!;
      });
      UserPreferences.saveAssignedId(assignedId);

      final newRoutine = <String, dynamic>{
        'name': "New routine",
        'id': assignedId,
      };

      if (userDataMapCopy != null && userDataMapCopy!["routines"] != null) {
        userDataMapCopy!["routines"]
            .addAll({assignedId: newRoutine as dynamic});
      } else if (userDataMapCopy == null) {
        userDataMapCopy = {
          "routines": {assignedId: newRoutine as dynamic}
        };
      } else {
        userDataMapCopy!["routines"] = {assignedId: newRoutine as dynamic};
      }
      DataGestion.userDataMapCopy = userDataMapCopy;
      UserPreferences.saveLogInProgressMap(
          json.encode(DataGestion.userDataMapCopy));

      setState(() {
        userDataMapCopy = DataGestion.userDataMapCopy;
      });
    }
    updateState();

    super.initState();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
    super.didChangeDependencies();
  }

  @override
  void didPopNext() {
    setState(() {
      userDataMapCopy = DataGestion.userDataMapCopy;
      exsInLog = DataGestion.exercicesList(userDataMapCopy, assignedId);
    });
    super.didPopNext();
  }

  void updateState() {
    userDataMapCopy = DataGestion.userDataMapCopy;
    exsInLog = DataGestion.exercicesList(userDataMapCopy, assignedId);
    //update sets
    sets = 0;
    for (var element in exsInLog) {
      element["sets"].forEach((k, v) {
        if (v["finished"] == true) {
          sets = sets + 1;
        }
      });
    }
    DataGestion.sets = sets;
    //update volume
    num volume = 0;
    for (var element in exsInLog) {
      element["sets"].forEach((k, v) {
        if (v["finished"] == true &&
            v["reps"] != null &&
            v["weightinkg"] != null &&
            (exercices[element["name"]]["category"] == "r" ||
                exercices[element["name"]]["category"] == "b")) {
          final reps = v["reps"];

          final weight = v["weightinkg"];

          volume = volume + (reps * weight);
        }
      });
    }
    DataGestion.volume = volume;
    //update map
    setState(() {
      userDataMapCopy = DataGestion.userDataMapCopy;
      exsInLog = DataGestion.exercicesList(userDataMapCopy, assignedId);
      vol = DataGestion.volume;
      sets = DataGestion.sets;
    });
  }

  final ValueNotifier updateVolume = ValueNotifier(DataGestion.volume);
  //final ValueNotifier updateSets = ValueNotifier(DataGestion.sets);
  changeVolume() {
    vol = DataGestion.volume;
    //sets = DataGestion.sets;
    updateVolume.value = vol;
    //updateSets.value = sets;
  }

  final timerKey = GlobalKey<CountDownTimerState>();

  timerControl(String function) {
    final state = timerKey.currentState!;

    if (function == "start") {
      state.startTimer();
    }
    if (function == "resume") {
      state.resumeTimer();
    }
    if (function == "stop") {
      state.stopTimer();
    }
    if (function == "reset") {
      state.resetTimer();
    }
    if (function == "+s") {
      state.incrementSecs();
    }
    if (function == "-s") {
      state.decrementSecs();
    }
    if (function == "+m") {
      state.incrementMins();
    }
    if (function == "-m") {
      state.decrementMins();
    }
  }

  finishWorkout() async {
    if (userDataMapCopy!["routines"][assignedId]["exercices"] != null &&
        DataGestion.sets > 0) {
      showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
                title: const Text("Routine completed?"),
                content: const Text(
                    "Did you complete your routine? All invalidated sets will be discarded!"),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Cancel")),
                  TextButton(
                      onPressed: () async {
                        UserPreferences.removeAssignedId();
                        //
                        userDataMap = DataGestion.userDataMap;
                        userDataMapCopy = DataGestion.userDataMapCopy;
                        logMap = {};
                        //Create the saved log
                        userDataMapCopy!["routines"][assignedId]["exercices"]
                            .forEach((String exk, dynamic exv) {
                          logMap!.addAll({
                            exk: {
                              "comment": exv["comment"],
                              "name": exv["name"],
                              "id": exv["id"],
                              "pos": exv["pos"],
                              "sets": {},
                            } as dynamic
                          });
                          int count = 0;
                          exv["sets"].forEach((sk, sv) {
                            if (sv["finished"] == true) {
                              logMap![exk]["sets"]
                                  .addAll(json.decode(json.encode({sk: sv})));
                              logMap![exk]["sets"][sk].remove("finished");
                              count++;
                            }
                          });
                          if (count == 0) {
                            logMap!.remove(exk);
                          }
                        });

                        //save the log
                        final keyy = ref.child("logs").push();

                        int saveDate = DateTime.now().millisecondsSinceEpoch;

                        Map? mapp = {
                          "name": routineName,
                          "id": keyy.key,
                          "exercices": logMap,
                          "tdate": saveDate,
                          "tdur": DataGestion.time,
                        };
                        if (userDataMap != null &&
                            userDataMap!["logs"] != null) {
                          userDataMap!["logs"]
                              .addAll({keyy.key as String: mapp as dynamic});
                        } else if (userDataMap == null) {
                          userDataMap = {
                            "logs": {keyy.key as String: mapp as dynamic}
                          };
                        } else {
                          userDataMap!["logs"] = {
                            keyy.key as String: mapp as dynamic
                          };
                        }
                        //update routine last performed
                        if (userDataMap!["routines"] != null &&
                            userDataMap!["routines"][assignedId] != null) {
                          userDataMap!["routines"][assignedId]["lastperf"] =
                              DateTime.now().millisecondsSinceEpoch;
                          /*  ref
                                                .child("routines")
                                                .child(assignedId)
                                                .child("lastperf")
                                                .set(DateTime.now()
                                                    .millisecondsSinceEpoch); */
                        }
                        DataGestion.userDataMap = userDataMap;
                        //end workout
                        widget.workoutEnd(false, null, "");

                        //pop page
                        Navigator.pop(context);

                        //retreive exercice history data
                        if (userDataMap != null &&
                            userDataMap!["logs"] != null) {
                          Map exsHistory =
                              json.decode(json.encode(InAppData.exercices));
                          exsHistory.forEach((key, value) {
                            exsHistory[key].addAll({"history": {}});
                          });
                          exsHistory.forEach((key, value) {
                            userDataMap!["logs"].forEach((lk, lv) {
                              userDataMap!["logs"][lk]["exercices"]
                                  .forEach((ek, ev) {
                                if (ev["name"] == key) {
                                  //int length = exsHistory[key]["history"].length;
                                  final newId = "$lk${ev["pos"]}";
                                  exsHistory[key]["history"].addAll({
                                    newId: {
                                      "id": newId,
                                      "date": lv["tdate"],
                                      "name": lv["name"],
                                      "sets": ev["sets"],
                                      "im": ev["im"],
                                    }
                                  });
                                }
                              });
                            });
                          });
                          //get old prs map
                          Map oldPrs = {};
                          DataGestion.exsHistory.forEach((k, v) {
                            if (v["prs"] != null) {
                              oldPrs.addAll({k: v["prs"]});
                            }
                            DataGestion.oldPrs = oldPrs;
                          });
                          //calculate prs
                          exsHistory.forEach((k, v) {
                            int maxReps = 0;
                            num maxWeight = 0;
                            int maxVolumeReps = 0;
                            num maxVolumeWeight = 0;
                            exsHistory[k]["history"].forEach((kk, vv) {
                              exsHistory[k]["history"][kk]["sets"]
                                  .forEach((kkk, vvv) {
                                if (vvv["reps"] != null &&
                                    vvv["reps"] > maxReps) {
                                  maxReps = vvv["reps"];
                                }
                                if (vvv["weightinkg"] != null &&
                                    vvv["weightinkg"] > maxWeight) {
                                  maxWeight = vvv["weightinkg"];
                                }
                                if (vvv["reps"] != null &&
                                    vvv["weightinkg"] != null &&
                                    vvv["reps"] * vvv["weightinkg"] >
                                        maxVolumeReps * maxVolumeWeight) {
                                  maxVolumeWeight = vvv["weightinkg"];
                                  maxVolumeReps = vvv["reps"];
                                }
                              });
                            });
                            exsHistory[k]["prs"] = {
                              "maxReps": maxReps,
                              "maxWeight": maxWeight,
                              "maxVolumeReps": maxVolumeReps,
                              "maxVolumeWeight": maxVolumeWeight
                            };
                          });

                          //most recent performance
                          exsHistory.forEach((key, value) {
                            List historyList;
                            historyList =
                                exsHistory[key]["history"].values.toList();
                            historyList
                                .sort(((a, b) => b["id"].compareTo(a["id"])));
                            if (historyList.isNotEmpty) {
                              Map? recent = historyList[0]["sets"];
                              exsHistory[key]["recent"] = recent;
                            }
                          });
                          DataGestion.exsHistory = exsHistory;
                        } //no history
                        else {
                          Map exsHistory =
                              json.decode(json.encode(InAppData.exercices));

                          exsHistory.forEach((key, value) {
                            exsHistory[key].addAll({"history": {}});
                          });
                          exsHistory.forEach((k, v) {
                            int maxReps = 0;
                            num maxWeight = 0;
                            int maxVolumeReps = 0;
                            num maxVolumeWeight = 0;
                            exsHistory[k]["history"].forEach((kk, vv) {
                              exsHistory[k]["history"][kk]["sets"]
                                  .forEach((kkk, vvv) {
                                if (vvv["reps"] != null &&
                                    vvv["reps"] > maxReps) {
                                  maxReps = vvv["reps"];
                                }
                                if (vvv["weightinkg"] != null &&
                                    vvv["weightinkg"] > maxWeight) {
                                  maxWeight = vvv["weightinkg"];
                                }
                                if (vvv["reps"] != null &&
                                    vvv["weightinkg"] != null &&
                                    vvv["reps"] * vvv["weightinkg"] >
                                        maxVolumeReps * maxVolumeWeight) {
                                  maxVolumeWeight = vvv["weightinkg"];
                                  maxVolumeReps = vvv["reps"];
                                }
                              });
                            });
                            exsHistory[k]["prs"] = {
                              "maxReps": maxReps,
                              "maxWeight": maxWeight,
                              "maxVolumeReps": maxVolumeReps,
                              "maxVolumeWeight": maxVolumeWeight
                            };
                          });
                          DataGestion.exsHistory = exsHistory;
                        }
                        int stopTime = userDataMap!["logs"][keyy.key]["tdate"];
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CongratsPage(
                                    assignedId: assignedId,
                                    sets: DataGestion.sets,
                                    volume: DataGestion.volume,
                                    time: stopTime - startTime,
                                    lId: keyy.key as String)));
                      },
                      child: const Text("End")),
                ],
              ));
    } else {
      showSnackBar(context, 'You need to complete at least 1 set!');
    }
  }

  editRoutineName() {
    routineEditController.value =
        routineEditController.value.copyWith(text: routineName);
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text('Edit routine name'),
              content: TextField(
                maxLength: 250,
                controller: routineEditController,
                autofocus: true,
                decoration: const InputDecoration(
                    hintText: 'Enter your routine\'s name', counterText: ''),
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    if (routineEditController.text.isNotEmpty) {
                      //display only change
                      setState(() {
                        routineName = routineEditController.text;
                      });
                      //update local data

                      userDataMapCopy!["routines"][assignedId]["name"] =
                          routineName;

                      DataGestion.userDataMapCopy = userDataMapCopy;
                      UserPreferences.saveLogInProgressMap(
                          json.encode(DataGestion.userDataMapCopy));
                      ////update database
                      //ref.update({"name": routineName});

                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Enter'),
                ),
              ],
            ));
  }

  cancelWorkout() {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text("End routine?"),
              content: const Text(
                  "Are you sure you want to end this routine? All changes will be lost!"),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Continue")),
                TextButton(
                    onPressed: () {
                      //end workout
                      widget.workoutEnd(false, null, "");
                      //pop page
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "End",
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    )),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    userDataMapCopy = DataGestion.userDataMapCopy;
    exsInLog = DataGestion.exercicesList(userDataMapCopy, assignedId);
    routineName = userDataMapCopy!["routines"][assignedId]["name"];
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: CountDownTimer(
          key: timerKey,
        ),
        leadingWidth: 95,
        leading: Row(
          children: [
            BackButton(
              onPressed: () {
                widget.reduce();
              },
            ),
            const Padding(padding: EdgeInsets.only(right: 10)),
            IconButton(
                tooltip: 'Timer',
                padding: const EdgeInsets.symmetric(horizontal: 0),
                constraints: const BoxConstraints(),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: ((context) {
                        return Clock(
                          timerControl: timerControl,
                        );
                      }));
                },
                icon: const Icon(Icons.timer)),
            const Padding(padding: EdgeInsets.only(right: 10)),
          ],
        ),
        elevation: 0,
        shape: const Border(bottom: BorderSide(width: 1, color: Colors.black)),
        actions: [
          Container(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    finishWorkout();
                  },
                  child: const Text(
                    'Finish',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ),
                const Padding(padding: EdgeInsets.all(7))
              ],
            ),
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: Const.horizontalPagePadding),
        child: Column(
          children: [
            Expanded(
                flex: 100,
                child: FadingEdgeScrollView.fromScrollView(
                  child: CustomScrollView(
                    controller: scrollController,
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Flexible(
                                        child: RichText(
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            text: TextSpan(
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .inputDecorationTheme
                                                      .border!
                                                      .borderSide
                                                      .color,
                                                  fontSize: 16,
                                                ),
                                                children: [
                                                  const TextSpan(
                                                      text: 'Name: ',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      )),
                                                  TextSpan(
                                                    text: routineName,
                                                  )
                                                ])),
                                      ),
                                      IconButton(
                                          tooltip: 'Rename routine',
                                          padding: const EdgeInsets.all(5),
                                          constraints: const BoxConstraints(),
                                          onPressed: () {
                                            editRoutineName();
                                          },
                                          icon: const Icon(Icons.edit)),
                                    ],
                                  ),
                                ),
                                IconButton(
                                    tooltip: 'Reorder exercices',
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5),
                                    constraints: const BoxConstraints(),
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  LogReorderExercices(
                                                    rId: assignedId,
                                                  )));
                                    },
                                    icon: const Icon(Icons.menu)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Duration since start + sum of weightinkg + sum of accomplished sets
                              //buildTime(),
                              const Timerr(),
                              ValueListenableBuilder(
                                valueListenable: updateVolume,
                                builder: (context, value, child) {
                                  return Volume(
                                    volume: vol,
                                    weightImperial: DataGestion.weightImperial,
                                  );
                                },
                              ),
                              Text("Sets: $sets"),
                            ],
                          ),
                        ),
                      ),
                      (exsInLog.isNotEmpty)
                          ? SliverList.builder(
                              itemCount: exsInLog.length,
                              itemBuilder: (context, i) {
                                exsInLog.sort(
                                    (a, b) => a["pos"].compareTo(b["pos"]));

                                return ExerciceInLogCard(
                                  updateState: updateState,
                                  updateVolume: changeVolume,
                                  exName: exsInLog[i]["name"],
                                  exId: exsInLog[i]["id"],
                                  rId: assignedId,
                                );
                              })
                          : const SliverToBoxAdapter(
                              child: Center(child: Text("Add an exercice"))),
                    ],
                  ),
                )),
            const Spacer(),
            button(
                height: 45,
                icon: Icons.add,
                context: context,
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              LogExercicesPage(rId: assignedId)));
                },
                text: 'Add exercice'),
            button(
                height: 45,
                color: Colors.red,
                context: context,
                onPressed: () {
                  cancelWorkout();
                },
                text: 'Cancel workout'),
            Padding(
                padding: EdgeInsets.only(
                    bottom: AppMediaQuerry.mq.padding.bottom + 8)),
          ],
        ),
      ),
    );
  }
}
