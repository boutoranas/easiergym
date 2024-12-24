import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/widgets/exercice_inroutine_card.dart';

import '../../../in app data.dart';
import '../../../services/data_update.dart';
import '../../../services/user_preferences.dart';
import '../log replace exercice.dart';
import 'set card.dart';

class ExerciceInLogCard extends StatefulWidget {
  final Function updateState;
  final Function updateVolume;
  final String exName;
  final String exId;
  final String rId;
  const ExerciceInLogCard(
      {super.key,
      required this.exName,
      required this.rId,
      required this.exId,
      required this.updateState,
      required this.updateVolume});

  @override
  State<ExerciceInLogCard> createState() => _ExerciceInLogCardState();
}

class _ExerciceInLogCardState extends State<ExerciceInLogCard> {
  TextEditingController commentController = TextEditingController();
  final userID = FirebaseAuth.instance.currentUser!.uid;
  late DatabaseReference database =
      FirebaseDatabase.instance.ref().child("users").child(userID);

  late DatabaseReference ref = FirebaseDatabase.instance
      .ref()
      .child("users")
      .child(userID)
      .child("easiergym")
      .child("routines")
      .child(widget.rId)
      .child("exercices")
      .child(widget.exId);

  Map? userDataMapCopy = DataGestion.userDataMapCopy;
  late List setsList =
      DataGestion.setsList(userDataMapCopy, widget.rId, widget.exId);
  late List exercicesList =
      DataGestion.exercicesList(userDataMapCopy, widget.rId);
  late List broadExercicesList =
      DataGestion.broadExercicesList(userDataMapCopy, widget.rId);

  Map exercices = InAppData.exercices;
  late String category = exercices[widget.exName]["category"];

  late String? comment = userDataMapCopy!["routines"][widget.rId]["exercices"]
      [widget.exId]["comment"];

  List units = ["reps", "kg", "time", "+kg", "-kg", "km"];

  late String unit1;
  late String unit2;

  bool weightImperial = DataGestion.weightImperial;
  bool distanceImperial = DataGestion.distanceImperial;

  @override
  void initState() {
    associateUnits();
    super.initState();
  }

  void updateState({bool? onlyExercice = false}) {
    userDataMapCopy = DataGestion.userDataMapCopy;
    exercicesList = DataGestion.exercicesList(userDataMapCopy, widget.rId);
    exercicesList.sort((a, b) => a["pos"].compareTo(b["pos"]));
    broadExercicesList =
        DataGestion.broadExercicesList(userDataMapCopy, widget.rId);
    /* Map? mapp = userDataMap!["routines"][widget.rId]["exercices"][widget.exId]
            ["sets"]; */
    if (userDataMapCopy!["routines"][widget.rId]["exercices"][widget.exId]
            ["sets"]
        .isEmpty) {
      deleteExercice();
    } else {
      if (onlyExercice == false) {
        widget.updateState();
      }
      setState(() {});
    }
  }

  int calculateNumber(index) {
    List sets = userDataMapCopy!["routines"][widget.rId]["exercices"]
            [widget.exId]["sets"]
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

  changeUnits(value) {
    if (category != "c") {
      if (value == "default") {
        userDataMapCopy!["routines"][widget.rId]["exercices"][widget.exId]
            ["im"] = null;
      }
      if (value == "metric") {
        userDataMapCopy!["routines"][widget.rId]["exercices"][widget.exId]
            ["im"] = false;
      }
      if (value == "imperial") {
        userDataMapCopy!["routines"][widget.rId]["exercices"][widget.exId]
            ["im"] = true;
      }
    }
    //for exs with distances
    else {
      if (value == "default") {
        userDataMapCopy!["routines"][widget.rId]["exercices"][widget.exId]
            ["im"] = null;
      }
      if (value == "metric") {
        userDataMapCopy!["routines"][widget.rId]["exercices"][widget.exId]
            ["im"] = false;
      }
      if (value == "imperial") {
        userDataMapCopy!["routines"][widget.rId]["exercices"][widget.exId]
            ["im"] = true;
      }
    }
    UserPreferences.saveLogInProgressMap(
        json.encode(DataGestion.userDataMapCopy));
    setState(() {});
  }

  deleteExercice() {
    userDataMapCopy = DataGestion.userDataMapCopy;

    userDataMapCopy!["routines"][widget.rId]["exercices"].remove(widget.exId);

    //recalculate position
    exercicesList = DataGestion.exercicesList(userDataMapCopy, widget.rId);
    exercicesList.sort((a, b) => a["pos"].compareTo(b["pos"]));
    broadExercicesList =
        DataGestion.broadExercicesList(userDataMapCopy, widget.rId);

    exercicesList.asMap().forEach((numm, value) {
      String keyy = value["id"];
      if (broadExercicesList[0]["exercices"][keyy] != null) {
        broadExercicesList[0]["exercices"][keyy].addAll({"pos": numm});
      }
    });

    DataGestion.userDataMapCopy = userDataMapCopy;
    UserPreferences.saveLogInProgressMap(
        json.encode(DataGestion.userDataMapCopy));
    widget.updateState();
  }

  commentExercice() {
    if (comment == null) {
      setState(() {
        userDataMapCopy!["routines"][widget.rId]["exercices"][widget.exId]
            ["comment"] = '';
        commentController.text = '';
      });
    } else {
      setState(() {
        comment = null;
        userDataMapCopy!["routines"][widget.rId]["exercices"][widget.exId]
            ["comment"] = comment;
      });
    }
    UserPreferences.saveLogInProgressMap(
        json.encode(DataGestion.userDataMapCopy));
  }

  void addSet() {
    final setKey = ref.child("sets").push();
    final newSet = <String, dynamic>{
      'id': setKey.key,
      'reps': null,
      'weightinkg': null,
    };
    //add set locally
    userDataMapCopy!["routines"][widget.rId]["exercices"][widget.exId]["sets"]
        .addAll({setKey.key as String: newSet as dynamic});
    DataGestion.userDataMapCopy = userDataMapCopy;
    UserPreferences.saveLogInProgressMap(
        json.encode(DataGestion.userDataMapCopy));
    setState(() {
      setsList = DataGestion.setsList(userDataMapCopy, widget.rId, widget.exId);
    });
  }

  associateUnits() {
    String category = exercices[widget.exName]["category"];
    bool? imperial = userDataMapCopy!["routines"][widget.rId]["exercices"]
        [widget.exId]["im"];

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

  @override
  Widget build(BuildContext context) {
    userDataMapCopy = DataGestion.userDataMapCopy;
    setsList = DataGestion.setsList(userDataMapCopy, widget.rId, widget.exId);
    late String category = exercices[widget.exName]["category"];
    comment = userDataMapCopy!["routines"][widget.rId]["exercices"][widget.exId]
        ["comment"];
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
                                style: userDataMapCopy!["routines"][widget.rId]
                                            ["exercices"][widget.exId]["im"] ==
                                        null
                                    ? const TextStyle(
                                        color: Colors.blue,
                                      )
                                    : null,
                              )
                            : Text(
                                "Default",
                                style: userDataMapCopy!["routines"][widget.rId]
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
                                style: userDataMapCopy!["routines"][widget.rId]
                                            ["exercices"][widget.exId]["im"] ==
                                        false
                                    ? const TextStyle(
                                        color: Colors.blue,
                                      )
                                    : null,
                              )
                            : Text(
                                "Km",
                                style: userDataMapCopy!["routines"][widget.rId]
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
                                style: userDataMapCopy!["routines"][widget.rId]
                                            ["exercices"][widget.exId]["im"] ==
                                        true
                                    ? const TextStyle(
                                        color: Colors.blue,
                                      )
                                    : null,
                              )
                            : Text(
                                "Miles",
                                style: userDataMapCopy!["routines"][widget.rId]
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
                    builder: (context) => LogReplaceExercice(
                          rId: widget.rId,
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
        userDataMapCopy!["routines"][widget.rId]["exercices"][widget.exId]
            ["comment"] = commentController.text;
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
            return SetCard(
              key: UniqueKey(),
              category: category,
              updateVolume: widget.updateVolume,
              updateState: updateState,
              number: calculateNumber(i),
              exId: widget.exId,
              rId: widget.rId,
              sId: setsList[i]["id"],
              reps: setsList[i]["reps"],
              weightinkg: setsList[i]["weightinkg"],
            );
          }),
    );
  }
}
