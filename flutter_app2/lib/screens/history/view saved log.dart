import 'dart:convert';

import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/const.dart';
import 'package:flutter_app/screens/history/edit%20saved%20log.dart';
import 'package:flutter_app/services/date%20formater.dart';
import 'package:flutter_app/widgets/custom%20appbar.dart';

import '../../in app data.dart';
import '../../main.dart';
import '../../services/data_update.dart';
import '../../services/user_preferences.dart';
import 'local widgets/view history log card.dart';

class ViewSavedLog extends StatefulWidget {
  final String name;
  final String rId;
  const ViewSavedLog({super.key, required this.name, required this.rId});

  @override
  State<ViewSavedLog> createState() => _ViewSavedLogState();
}

class _ViewSavedLogState extends State<ViewSavedLog> with RouteAware {
  ScrollController scrollController = ScrollController();

  final userID = FirebaseAuth.instance.currentUser!.uid;
  late DatabaseReference database =
      FirebaseDatabase.instance.ref().child("users").child(userID);

  late DatabaseReference ref = FirebaseDatabase.instance
      .ref()
      .child("users")
      .child(userID)
      .child("easiergym")
      .child("logs")
      .child(widget.rId);

  Map? userDataMap = DataGestion.userDataMap;
  late List exercicesList =
      DataGestion.exercicesInLogList(userDataMap, widget.rId);

  int getNumberOfSets(Map? setsMap) {
    if (setsMap != null) {
      List setsList = setsMap.values.toList();
      List nonWSets = [];
      for (var element in setsList) {
        if (element["type"] != "W") {
          nonWSets.add(element);
        }
      }
      return nonWSets.length;
    } else {
      return 0;
    }
  }

  late String routineName = widget.name;
  late DateTime date;

  @override
  void didChangeDependencies() {
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() async {
    setState(() {});
    Map? updatedRoutineMap = DataGestion.userDataMap!["logs"][widget.rId];
    if (updatedRoutineMap!["exercices"] != null) {
      List toDelete = [];
      updatedRoutineMap["exercices"].forEach((exk, exv) {
        List toRemove = [];
        exv["sets"].forEach((sk, sv) async {
          if (sv["finished"] == false) {
            toRemove.add(sk);
            //await exv["sets"].remove(sk);
          } else if (sv["finished"] != null) {
            sv.remove("finished");
          }
        });
        exv["sets"].removeWhere((key, value) {
          //print(toRemove.contains(key));
          return toRemove.contains(key);
        });
        if (exv["sets"].length == 0) {
          toDelete.add(exk);
        } else {}
      });
      updatedRoutineMap["exercices"].removeWhere((exkey, exvalue) {
        return toDelete.contains(exkey);
      });
    }
    //retreive exercice history data
    if (userDataMap != null && userDataMap!["logs"] != null) {
      Map exsHistory = json.decode(json.encode(InAppData.exercices));
      exsHistory.forEach((key, value) {
        exsHistory[key].addAll({"history": {}});
      });
      exsHistory.forEach((key, value) {
        userDataMap!["logs"].forEach((lk, lv) {
          if (userDataMap!["logs"][lk]["exercices"] != null) {
            userDataMap!["logs"][lk]["exercices"].forEach((ek, ev) {
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
          }
        });
      });
      //calculate prs
      exsHistory.forEach((k, v) {
        int maxReps = 0;
        num maxWeight = 0;
        int maxVolumeReps = 0;
        num maxVolumeWeight = 0;
        exsHistory[k]["history"].forEach((kk, vv) {
          exsHistory[k]["history"][kk]["sets"].forEach((kkk, vvv) {
            if (vvv["reps"] != null && vvv["reps"] > maxReps) {
              maxReps = vvv["reps"];
            }
            if (vvv["weightinkg"] != null && vvv["weightinkg"] > maxWeight) {
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
        historyList = exsHistory[key]["history"].values.toList();
        historyList.sort(((a, b) => b["id"].compareTo(a["id"])));
        if (historyList.isNotEmpty) {
          Map? recent = historyList[0]["sets"];
          exsHistory[key]["recent"] = recent;
        }
      });
      DataGestion.exsHistory = exsHistory;
    } //no history
    else {
      Map exsHistory = json.decode(json.encode(InAppData.exercices));

      exsHistory.forEach((key, value) {
        exsHistory[key].addAll({"history": {}});
      });
      exsHistory.forEach((k, v) {
        int maxReps = 0;
        num maxWeight = 0;
        int maxVolumeReps = 0;
        num maxVolumeWeight = 0;
        exsHistory[k]["history"].forEach((kk, vv) {
          exsHistory[k]["history"][kk]["sets"].forEach((kkk, vvv) {
            if (vvv["reps"] != null && vvv["reps"] > maxReps) {
              maxReps = vvv["reps"];
            }
            if (vvv["weightinkg"] != null && vvv["weightinkg"] > maxWeight) {
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
    //await ref.set(updatedRoutineMap);
    super.didPopNext();
  }

  deleteRoutine(context) {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text("Please confirm"),
              content: const Text("Would you like to delete this routine?"),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Cancel")),
                TextButton(
                    onPressed: () {
                      //delete locally
                      userDataMap!["logs"].remove(widget.rId);
                      DataGestion.userDataMap = userDataMap;
                      UserPreferences.saveUserDataMap(
                          json.encode(DataGestion.userDataMap));
                      //delete on database
                      //ref.remove();
                      //pop page
                      Navigator.pop(context);
                      Navigator.pop(context);
                      //retreive exercice history data
                      if (userDataMap != null && userDataMap!["logs"] != null) {
                        Map exsHistory =
                            json.decode(json.encode(InAppData.exercices));
                        exsHistory.forEach((key, value) {
                          exsHistory[key].addAll({"history": {}});
                        });
                        exsHistory.forEach((key, value) {
                          userDataMap!["logs"].forEach((lk, lv) {
                            if (userDataMap!["logs"][lk]["exercices"] != null) {
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
                            }
                          });
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
                    },
                    child: const Text(
                      "Delete",
                      style: TextStyle(color: Colors.red),
                    )),
              ],
            ));
  }

  int seconds = 0;

  String buildTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    if (hours == "00") {
      return "duration: $minutes:$seconds";
    } else {
      return "duration: $hours:$minutes:$seconds";
    }
  }

  @override
  Widget build(BuildContext context) {
    userDataMap = DataGestion.userDataMap;
    exercicesList = DataGestion.exercicesInLogList(userDataMap, widget.rId);
    routineName = userDataMap!["logs"][widget.rId]["name"];
    date = DateTime.fromMillisecondsSinceEpoch(
        userDataMap!["logs"][widget.rId]["tdate"]);

    return Scaffold(
      appBar: customAppBar(
          title: routineName,
          leading: null,
          actions: [
            IconButton(
                tooltip: 'Edit routine',
                padding: const EdgeInsets.all(5),
                constraints: const BoxConstraints(),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EditSavedLog(
                                lName: widget.name,
                                lId: widget.rId,
                              )));
                },
                icon: const Icon(Icons.edit)),
            IconButton(
                tooltip: 'Delete routine',
                padding: const EdgeInsets.symmetric(horizontal: 5),
                constraints: const BoxConstraints(),
                onPressed: () {
                  deleteRoutine(context);
                },
                icon: const Icon(Icons.delete)),
          ],
          context: context),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: Const.horizontalPagePadding),
        child: FadingEdgeScrollView.fromScrollView(
          child: CustomScrollView(
            controller: scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              const SliverToBoxAdapter(
                  child: Padding(padding: EdgeInsets.only(bottom: 10))),
              SliverToBoxAdapter(
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    // Date property
                    '${DateFormater.month(date)} ${DateFormater.day(date)}${DateFormater.year(date)}, ${DateFormater.dayOfTheWeek(date)} at ${DateFormater.hour(date).toString().padLeft(2, '0')}:${DateFormater.minute(date).toString().padLeft(2, '0')}, ${buildTime(Duration(seconds: userDataMap!["logs"][widget.rId]["tdur"]))}',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                  child: Padding(padding: EdgeInsets.only(bottom: 10))),
              //List view builder of exercices of specific routine
              (exercicesList.isNotEmpty)
                  ? SliverList.builder(
                      itemCount: exercicesList.length,
                      itemBuilder: (context, i) {
                        exercicesList
                            .sort((a, b) => a["pos"].compareTo(b["pos"]));
                        return ViewHistoryLogCard(
                          name: exercicesList[i]["name"],
                          numberOfSets:
                              getNumberOfSets(exercicesList[i]["sets"]),
                        );
                      })
                  : const SliverToBoxAdapter(
                      child: Center(child: Text("No exercices"))),
            ],
          ),
        ),
      ),
    );
  }
}
