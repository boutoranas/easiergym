import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/screens/workout/reorder_routines.dart';
import 'package:flutter_app/screens/workout/view%20workout%20page.dart';
import 'package:flutter_app/services/data_update.dart';

import '../../../services/user_preferences.dart';
import '../../../widgets/routines_log_card.dart';

class RoutineCard extends StatelessWidget {
  final Function workoutInProgress;
  final Function updateState;
  final String name;
  final String id;
  RoutineCard(
      {super.key,
      required this.name,
      required this.id,
      required this.updateState,
      required this.workoutInProgress});

  //!controllers
  TextEditingController routineEditController = TextEditingController();

  //!database
  final userID = FirebaseAuth.instance.currentUser!.uid;
  late DatabaseReference database =
      FirebaseDatabase.instance.ref().child("users").child(userID);

  late DatabaseReference ref = FirebaseDatabase.instance
      .ref()
      .child("users")
      .child(userID)
      .child("easiergym");

  //!userdata
  Map? userDataMap = DataGestion.userDataMap;

  //!functions
  renameRoutine(context) {
    routineEditController.value =
        routineEditController.value.copyWith(text: name);
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
                      //update local data

                      userDataMap!["routines"][id]["name"] =
                          routineEditController.text;

                      DataGestion.userDataMap = userDataMap;
                      UserPreferences.saveUserDataMap(
                          json.encode(DataGestion.userDataMap));

                      updateState();
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Enter'),
                ),
              ],
            ));
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
                    style: const ButtonStyle(
                      foregroundColor: MaterialStatePropertyAll(Colors.red),
                    ),
                    onPressed: () {
                      //delete locally
                      userDataMap!["routines"].remove(id);
                      DataGestion.userDataMap = userDataMap;
                      UserPreferences.saveUserDataMap(
                          json.encode(DataGestion.userDataMap));
                      //pop page

                      updateState();
                      Navigator.pop(context);
                    },
                    child: const Text("Delete")),
              ],
            ));
  }

  duplicateRoutine() {
    Map? mapp = userDataMap!["routines"][id];
    final routineKey = ref.child("routines").push();
    final Map<String, dynamic> duplicatedRoutine;
    Map? duplicatedExercices = json.decode(json.encode(mapp!["exercices"]));

    if (mapp != null) {
      duplicatedRoutine = {
        'name': mapp["name"],
        'id': routineKey.key,
        'exercices': duplicatedExercices,
      };
    } else {
      duplicatedRoutine = {};
    }
    //add locally
    if (userDataMap != null && userDataMap!["routines"] != null) {
      userDataMap!["routines"]
          .addAll({routineKey.key as String: duplicatedRoutine as dynamic});
    } else if (userDataMap == null) {
      userDataMap = {
        "routines": {routineKey.key as String: duplicatedRoutine as dynamic}
      };
    } else {
      userDataMap!["routines"] = {
        routineKey.key as String: duplicatedRoutine as dynamic
      };
    }
    DataGestion.userDataMap = userDataMap;
    UserPreferences.saveUserDataMap(json.encode(DataGestion.userDataMap));

    updateState();
  }

  late String? exercicesOfRoutine = null;

  getExercices() {
    if (userDataMap!["routines"][id]["exercices"] != null &&
        userDataMap!["routines"][id]["exercices"].isNotEmpty) {
      List nameList = [];
      List exsList = DataGestion.exercicesList(userDataMap, id);
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
      context: context,
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ViewWorkout(
                      workoutInProgress: workoutInProgress,
                      name: name,
                      id: id,
                    )));
      },
      name: name,
      exercicesOfRoutine: exercicesOfRoutine,
      trailing: PopupMenuButton(
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: "View",
            child: Text("View"),
          ),
          const PopupMenuItem(
            value: "Rename",
            child: Text("Rename"),
          ),
          const PopupMenuItem(
            value: "Reorder",
            child: Text("Reorder"),
          ),
          const PopupMenuItem(
            value: "Duplicate",
            child: Text("Duplicate"),
          ),
          const PopupMenuItem(
            value: "Delete",
            child: Text("Delete"),
          ),
        ],
        onSelected: (value) {
          if (value == "View") {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ViewWorkout(
                          workoutInProgress: workoutInProgress,
                          name: name,
                          id: id,
                        )));
          } else if (value == "Rename") {
            renameRoutine(context);
          } else if (value == "Duplicate") {
            duplicateRoutine();
          } else if (value == "Delete") {
            deleteRoutine(context);
          } else if (value == "Reorder") {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => ReorderRoutines()));
          }
        },
      ),
    );
  }
}
