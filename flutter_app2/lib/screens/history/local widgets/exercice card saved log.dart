import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/in%20app%20data.dart';
import 'package:flutter_app/screens/history/local%20widgets/set%20card%20in%20saved%20log.dart';
import 'package:flutter_app/widgets/exercice_inroutine_card.dart';

import '../../../services/data_update.dart';
import '../../../services/user_preferences.dart';
import '../saved logs replace exs.dart';

class ExerciceInSavedLogCard extends StatefulWidget {
  final Function updateState;
  final String lId;
  final String exName;
  final String exId;
  const ExerciceInSavedLogCard(
      {super.key,
      required this.lId,
      required this.exName,
      required this.exId,
      required this.updateState});

  @override
  State<ExerciceInSavedLogCard> createState() => _ExerciceInSavedLogCardState();
}

class _ExerciceInSavedLogCardState extends State<ExerciceInSavedLogCard> {
  TextEditingController commentController = TextEditingController();

  final userID = FirebaseAuth.instance.currentUser!.uid;
  late DatabaseReference database =
      FirebaseDatabase.instance.ref().child("users").child(userID);

  late DatabaseReference ref = FirebaseDatabase.instance
      .ref()
      .child("users")
      .child(userID)
      .child("easiergym")
      .child("logs")
      .child(widget.lId)
      .child("exercices")
      .child(widget.exId);

  Map? userDataMap = DataGestion.userDataMap;
  late List setsList =
      DataGestion.setsInLogList(userDataMap, widget.lId, widget.exId);
  late List exercicesList =
      DataGestion.exercicesInLogList(userDataMap, widget.lId);
  late List broadExercicesList =
      DataGestion.broadExsInLogList(userDataMap, widget.lId);

  Map exercices = InAppData.exercices;
  late String category = exercices[widget.exName]["category"];

  late String? comment =
      userDataMap!["logs"][widget.lId]["exercices"][widget.exId]["comment"];

  List units = ["reps", "kg", "time", "+kg", "-kg", "km"];

  late String unit1;
  late String unit2;

  bool weightImperial = DataGestion.weightImperial;
  bool distanceImperial = DataGestion.distanceImperial;

  void updateState() {
    userDataMap = DataGestion.userDataMap;
    exercicesList = DataGestion.exercicesInLogList(userDataMap, widget.lId);
    exercicesList.sort((a, b) => a["pos"].compareTo(b["pos"]));
    broadExercicesList = DataGestion.broadExsInLogList(userDataMap, widget.lId);
    /* Map? mapp = userDataMap!["routines"][widget.rId]["exercices"][widget.exId]
            ["sets"]; */
    if (userDataMap!["logs"][widget.lId]["exercices"][widget.exId]["sets"]
        .isEmpty) {
      deleteExercice();
    }
    widget.updateState();
    setState(() {});
  }

  int calculateNumber(index) {
    List sets = userDataMap!["logs"][widget.lId]["exercices"][widget.exId]
            ["sets"]
        .values
        .toList();
    sets.sort((a, b) => a["id"].compareTo(b["id"]));
    List nonWSets = [];
    for (var element in sets) {
      if (element["type"] != "W") {
        nonWSets.add(element);
      }
    }
    if (nonWSets.contains(sets[index])) {
      return nonWSets.indexOf(sets[index]) + 1;
    } else {
      return 0;
    }
  }

  addSet() {
    final setKey = ref.child("sets").push();
    final newSet = <String, dynamic>{
      'id': setKey.key,
      'reps': null,
      'weightinkg': null,
      'finished': false,
    };
    //add set locally
    userDataMap!["logs"][widget.lId]["exercices"][widget.exId]["sets"]
        .addAll({setKey.key as String: newSet as dynamic});
    DataGestion.userDataMap = userDataMap;
    UserPreferences.saveUserDataMap(json.encode(DataGestion.userDataMap));
    setState(() {
      setsList =
          DataGestion.setsInLogList(userDataMap, widget.lId, widget.exId);
    });
  }

  associateUnits() {
    String category = exercices[widget.exName]["category"];
    bool? imperial =
        userDataMap!["logs"][widget.lId]["exercices"][widget.exId]["im"];

    if (imperial == null) {
      category != "c" ? imperial = weightImperial : imperial = distanceImperial;
    }
    if (imperial == true) {
      units = ["reps", "lbs", "time", "+lbs", "-lbs", "miles"];
    } else {
      units = ["reps", "kg", "time", "+kg", "-kg", "km"];
    }
    if (category == "r") {
      unit1 = units[0];
      unit2 = units[1];
    }
    if (category == "b") {
      unit1 = units[0];
      unit2 = units[3];
    }
    if (category == "a") {
      unit1 = units[0];
      unit2 = units[4];
    }
    if (category == "c") {
      unit1 = units[2];
      unit2 = units[5];
    }
    if (category == "d") {
      unit1 = units[2];
      unit2 = units[3];
    }
  }

  changeUnits(value) {
    //for exs with weight
    if (category != "c") {
      if (value == "default") {
        userDataMap!["logs"][widget.lId]["exercices"][widget.exId]["im"] = null;
      }
      if (value == "metric") {
        userDataMap!["logs"][widget.lId]["exercices"][widget.exId]["im"] =
            false;
      }
      if (value == "imperial") {
        userDataMap!["logs"][widget.lId]["exercices"][widget.exId]["im"] = true;
      }
    }
    //for exs with distances
    else {
      if (value == "default") {
        userDataMap!["logs"][widget.lId]["exercices"][widget.exId]["im"] = null;
      }
      if (value == "metric") {
        userDataMap!["logs"][widget.lId]["exercices"][widget.exId]["im"] =
            false;
      }
      if (value == "imperial") {
        userDataMap!["logs"][widget.lId]["exercices"][widget.exId]["im"] = true;
      }
    }
    UserPreferences.saveUserDataMap(json.encode(DataGestion.userDataMap));
    setState(() {});
  }

  deleteExercice() {
    userDataMap = DataGestion.userDataMap;

    userDataMap!["logs"][widget.lId]["exercices"].remove(widget.exId);

    //recalculate position
    exercicesList = DataGestion.exercicesInLogList(userDataMap, widget.lId);
    exercicesList.sort((a, b) => a["pos"].compareTo(b["pos"]));
    broadExercicesList = DataGestion.broadExsInLogList(userDataMap, widget.lId);

    exercicesList.asMap().forEach((numm, value) {
      String keyy = value["id"];
      if (broadExercicesList[0]["exercices"][keyy] != null) {
        broadExercicesList[0]["exercices"][keyy].addAll({"pos": numm});
      }
    });

    DataGestion.userDataMap = userDataMap;
    UserPreferences.saveUserDataMap(json.encode(DataGestion.userDataMap));
    widget.updateState();
  }

  commentExercice() {
    if (comment == null) {
      setState(() {
        userDataMap!["logs"][widget.lId]["exercices"][widget.exId]["comment"] =
            '';
        commentController.text = '';
      });
    } else {
      setState(() {
        comment = null;
        userDataMap!["logs"][widget.lId]["exercices"][widget.exId]["comment"] =
            comment;
      });
    }
    UserPreferences.saveUserDataMap(json.encode(DataGestion.userDataMap));
  }

  @override
  void initState() {
    associateUnits();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    userDataMap = DataGestion.userDataMap;
    setsList = DataGestion.setsInLogList(userDataMap, widget.lId, widget.exId);
    late String category = exercices[widget.exName]["category"];
    comment =
        userDataMap!["logs"][widget.lId]["exercices"][widget.exId]["comment"];
    if (comment != null) {
      commentController.text = comment!;
    }
    associateUnits();

    return exerciceInRoutineCard(
      checkBox: true,
      name: widget.exName,
      popupMenuButton: PopupMenuButton(
        itemBuilder: ((context) {
          return [
            PopupMenuItem(
              value: "unit",
              child: PopupMenuButton(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 0, right: 8, top: 12, bottom: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        category != "c"
                            ? const Text("Weight unit")
                            : const Text("Distance unit"),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                  //icon: Icon(Icons.arrow_drop_down),
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem(
                        value: "default",
                        child: category != "c"
                            ? Text(
                                "Default",
                                style: userDataMap!["logs"][widget.lId]
                                            ["exercices"][widget.exId]["im"] ==
                                        null
                                    ? const TextStyle(
                                        color: Colors.blue,
                                      )
                                    : null,
                              )
                            : Text(
                                "Default",
                                style: userDataMap!["logs"][widget.lId]
                                            ["exercices"][widget.exId]["im"] ==
                                        null
                                    ? const TextStyle(
                                        color: Colors.blue,
                                      )
                                    : null,
                              ),
                      ),
                      PopupMenuItem(
                        value: "metric",
                        child: category != "c"
                            ? Text(
                                "Kgs",
                                style: userDataMap!["logs"][widget.lId]
                                            ["exercices"][widget.exId]["im"] ==
                                        false
                                    ? const TextStyle(
                                        color: Colors.blue,
                                      )
                                    : null,
                              )
                            : Text(
                                "Km",
                                style: userDataMap!["logs"][widget.lId]
                                            ["exercices"][widget.exId]["im"] ==
                                        false
                                    ? const TextStyle(
                                        color: Colors.blue,
                                      )
                                    : null,
                              ),
                      ),
                      PopupMenuItem(
                        value: "imperial",
                        child: category != "c"
                            ? Text(
                                "Lbs",
                                style: userDataMap!["logs"][widget.lId]
                                            ["exercices"][widget.exId]["im"] ==
                                        true
                                    ? const TextStyle(
                                        color: Colors.blue,
                                      )
                                    : null,
                              )
                            : Text(
                                "Miles",
                                style: userDataMap!["logs"][widget.lId]
                                            ["exercices"][widget.exId]["im"] ==
                                        true
                                    ? const TextStyle(
                                        color: Colors.blue,
                                      )
                                    : null,
                              ),
                      ),
                    ];
                  },
                  onSelected: (value) {
                    changeUnits(value);
                    Navigator.pop(context);
                  }),
            ),
            PopupMenuItem(
              value: "comment",
              child: comment != null
                  ? const Text("Delete comment")
                  : const Text("Add comment"),
            ),
            const PopupMenuItem(
              value: "replace",
              child: Text("Replace exercice"),
            ),
            const PopupMenuItem(
              value: "delete",
              child: Text("Delete exercice"),
            ),
          ];
        }),
        onSelected: (value) {
          if (value == "delete") {
            deleteExercice();
          }
          if (value == "replace") {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SavedLogsReplaceExs(
                          lId: widget.lId,
                          exId: widget.exId,
                        )));
          }
          if (value == "comment") {
            commentExercice();
          }
        },
      ),
      comment: comment,
      commentController: commentController,
      updateComment: () {
        userDataMap!["logs"][widget.lId]["exercices"][widget.exId]["comment"] =
            commentController.text;
      },
      addSet: () {
        addSet();
      },
      unit1: unit1,
      unit2: unit2,
      context: context,
      listViewBuilder: ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: setsList.length,
          itemBuilder: (context, i) {
            setsList.sort((a, b) => a["id"].compareTo(b["id"]));
            return SetCardInSavedLog(
              key: UniqueKey(),
              updateState: updateState,
              lId: widget.lId,
              number: calculateNumber(i),
              exId: widget.exId,
              sId: setsList[i]["id"],
              reps: setsList[i]["reps"],
              weightinkg: setsList[i]["weightinkg"],
              category: category,
            );
          }),
    );
  }
}