import 'dart:convert';

import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/screens/workout/edit%20exercice%20page.dart';
import 'package:flutter_app/widgets/button.dart';
import 'package:flutter_app/widgets/custom%20appbar.dart';

import '../../const.dart';
import '../../main.dart';
import '../../services/app_media_query.dart';
import '../../services/data_update.dart';
import '../../services/date formater.dart';
import '../../services/user_preferences.dart';
import 'local widgets/used exercice card.dart';

class ViewWorkout extends StatefulWidget {
  final Function workoutInProgress;
  final String name;
  final String id;
  const ViewWorkout(
      {super.key,
      required this.name,
      required this.id,
      required this.workoutInProgress});

  @override
  State<ViewWorkout> createState() => _ViewWorkoutState();
}

class _ViewWorkoutState extends State<ViewWorkout> with RouteAware {
  ScrollController scrollController = ScrollController();
  //!database
  final userID = FirebaseAuth.instance.currentUser!.uid;
  late DatabaseReference database =
      FirebaseDatabase.instance.ref().child("users").child(userID);

  late DatabaseReference ref = FirebaseDatabase.instance
      .ref()
      .child("users")
      .child(userID)
      .child("easiergym")
      .child("routines")
      .child(widget.id);

  //!user data
  Map? userDataMap = DataGestion.userDataMap;
  late List exercicesList = DataGestion.exercicesList(userDataMap, widget.id);

  late DateTime? date;

  late String routineName = widget.name;

  @override
  void initState() {
    calculateLastPerformed();
    super.initState();
  }

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
    super.didPopNext();
  }

  //!funtions
  void calculateLastPerformed() {
    int? dateInMs = userDataMap!["routines"][widget.id]["lastperf"];
    if (dateInMs != null) {
      date = DateTime.fromMillisecondsSinceEpoch(dateInMs);
    } else {
      date = null;
    }
  }

  //displayed sets next to each exercice
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

  showDeleteRoutineDialog() {
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
                      userDataMap!["routines"].remove(widget.id);
                      DataGestion.userDataMap = userDataMap;
                      UserPreferences.saveUserDataMap(
                          json.encode(DataGestion.userDataMap));

                      //pop page
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: const Text("Delete")),
              ],
            ));
  }

  startWorkout() {
    Navigator.of(context).pop();
    widget.workoutInProgress(true, widget.id, widget.name);
  }

  @override
  Widget build(BuildContext context) {
    //print(userDataMap);
    userDataMap = DataGestion.userDataMap;
    exercicesList = DataGestion.exercicesList(userDataMap, widget.id);
    routineName = userDataMap!["routines"][widget.id]["name"];

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
                          builder: (context) => EditRoutinePage(
                                rName: widget.name,
                                rId: widget.id,
                              )));
                },
                icon: const Icon(Icons.edit)),
            IconButton(
                tooltip: 'Delete routine',
                padding: const EdgeInsets.symmetric(horizontal: 5),
                constraints: const BoxConstraints(),
                onPressed: () {
                  showDeleteRoutineDialog();
                },
                icon: const Icon(Icons.delete)),
          ],
          context: context),
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
                      child: Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        child: date != null
                            ? Text(
                                'Last performed: ${DateFormater.month(date!)} ${DateFormater.day(date!)}${DateFormater.year(date!)}, ${DateFormater.dayOfTheWeek(date!)} at ${DateFormater.hour(date!).toString().padLeft(2, '0')}:${DateFormater.minute(date!).toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              )
                            : null,
                      ),
                    ),
                    //List view builder of exercices of specific routine
                    (exercicesList.isNotEmpty)
                        ? SliverList.builder(
                            itemCount: exercicesList.length,
                            itemBuilder: (context, i) {
                              exercicesList
                                  .sort((a, b) => a["pos"].compareTo(b["pos"]));
                              return UsedExerciceCard(
                                  name: exercicesList[i]["name"],
                                  numberofsets: getNumberOfSets(
                                      exercicesList[i]["sets"]));
                            })
                        : const SliverToBoxAdapter(
                            child: Center(child: Text("No exercices"))),
                  ],
                ),
              ),
            ),
            const Spacer(),
            button(
              context: context,
              onPressed: () {
                startWorkout();
              },
              text: 'Start workout',
            ),
            Padding(
                padding:
                    EdgeInsets.only(top: AppMediaQuerry.mq.padding.bottom + 8)),
          ],
        ),
      ),
    );
  }
}
