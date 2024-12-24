import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/screens/history/view%20saved%20log.dart';
import 'package:flutter_app/services/date%20formater.dart';
import 'package:flutter_app/widgets/routines_log_card.dart';

import '../../../in app data.dart';
import '../../../services/data_update.dart';
import '../../../services/user_preferences.dart';

class HistoryLogCard extends StatelessWidget {
  final Function updateState;
  final String name;
  final String id;
  final int time;
  HistoryLogCard(
      {super.key,
      required this.name,
      required this.time,
      required this.id,
      required this.updateState});

  final userID = FirebaseAuth.instance.currentUser!.uid;
  late DatabaseReference database =
      FirebaseDatabase.instance.ref().child("users").child(userID);

  late DatabaseReference ref = FirebaseDatabase.instance
      .ref()
      .child("users")
      .child(userID)
      .child("easiergym")
      .child("logs");

  late DatabaseReference ref2 = FirebaseDatabase.instance
      .ref()
      .child("users")
      .child(userID)
      .child("easiergym")
      .child("routines");

  late DateTime date = DateTime.fromMillisecondsSinceEpoch(time);

  Map? userDataMap = DataGestion.userDataMap;

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
                      userDataMap!["logs"].remove(id);
                      DataGestion.userDataMap = userDataMap;
                      UserPreferences.saveUserDataMap(
                          json.encode(DataGestion.userDataMap));
                      //delete on database
                      //ref.child(id).remove();
                      //pop page
                      Navigator.pop(context);
                      updateState("Delete");
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
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    )),
              ],
            ));
  }

  saveAsRoutine() {
    final keyy = ref2.push();
    Map? mapp = json.decode(json.encode(userDataMap!["logs"][id]));
    //save locally
    Map? newRoutine = {
      "name": mapp!["name"],
      "id": keyy.key,
      "exercices": mapp["exercices"]
    };
    if (userDataMap!["routines"] != null) {
      userDataMap!["routines"]
          .addAll({keyy.key as String: newRoutine as dynamic});
    } else {
      userDataMap!["routines"] = {keyy.key as String: newRoutine as dynamic};
    }
    DataGestion.userDataMap = userDataMap;
    UserPreferences.saveUserDataMap(json.encode(DataGestion.userDataMap));
    updateState("Save as Routine");
  }

  late String? exercicesOfRoutine = null;

  getExercices() {
    if (userDataMap!["logs"][id]["exercices"] != null &&
        userDataMap!["logs"][id]["exercices"].isNotEmpty) {
      List nameList = [];
      List exsList = DataGestion.exercicesInLogList(userDataMap, id);
      exsList.sort((a, b) => a["pos"].compareTo(b["pos"]));
      for (var element in exsList) {
        nameList.add(element["name"]);
      }
      exercicesOfRoutine = nameList.join(', ');
    }
  }

  @override
  Widget build(BuildContext context) {
    getExercices();
    return routinesNLogCard(
        exercicesOfRoutine: exercicesOfRoutine,
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ViewSavedLog(
                        name: name,
                        rId: id,
                      )));
        },
        context: context,
        name:
            '${DateFormater.dayOfTheWeek(date)[0]}${DateFormater.dayOfTheWeek(date)[1]}${DateFormater.dayOfTheWeek(date)[2]} ${DateFormater.day(date)} - $name',
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: "View",
              child: Text("View"),
            ),
            const PopupMenuItem(
              value: "Save as routine",
              child: Text("Save as routine"),
            ),
            const PopupMenuItem(
              value: "Delete",
              child: Text("Delete"),
            ),
          ],
          onSelected: (value) async {
            if (value == "View") {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ViewSavedLog(
                            name: name,
                            rId: id,
                          )));
            }
            if (value == "Save as routine") {
              saveAsRoutine();
            }
            if (value == "Delete") {
              deleteRoutine(context);
            }
          },
        ));
  }
}
