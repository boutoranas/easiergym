import 'dart:convert';

import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/const.dart';
import 'package:flutter_app/screens/workout/exercices%20page.dart';
import 'package:flutter_app/screens/workout/local%20widgets/exercice%20in%20edit.dart';
import 'package:flutter_app/screens/workout/reorder%20exercices%20page.dart';
import 'package:flutter_app/services/data_update.dart';
import 'package:flutter_app/widgets/custom%20appbar.dart';

import '../../main.dart';
import '../../services/app_media_query.dart';
import '../../services/user_preferences.dart';
import '../../widgets/button.dart';

class EditRoutinePage extends StatefulWidget {
  final String rName;
  final String rId;
  const EditRoutinePage({super.key, required this.rName, required this.rId});

  @override
  State<EditRoutinePage> createState() => _EditRoutinePageState();
}

class _EditRoutinePageState extends State<EditRoutinePage> with RouteAware {
  //!controllers
  TextEditingController routineEditController = TextEditingController();
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
      .child(widget.rId);

  //!userdata
  Map? userDataMap = DataGestion.userDataMap;
  late List exercicesList = DataGestion.exercicesList(userDataMap, widget.rId);

  late String routineName = widget.rName;

  //!keys
  List<GlobalKey<AnimatedListState>> _globalKeyList = [];

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
  void didPopNext() {
    setState(() {});
    super.didPopNext();
  }

  //!functions
  void updateState() {
    setState(() {});
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

                      userDataMap!["routines"][widget.rId]["name"] =
                          routineName;

                      DataGestion.userDataMap = userDataMap;
                      UserPreferences.saveUserDataMap(
                          json.encode(DataGestion.userDataMap));

                      //pop page
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Enter'),
                ),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    userDataMap = DataGestion.userDataMap;
    exercicesList = DataGestion.exercicesList(userDataMap, widget.rId);
    routineName = userDataMap!["routines"][widget.rId]["name"];
    _globalKeyList = List.generate(
        exercicesList.length + 1, (index) => GlobalKey<AnimatedListState>());

    return Scaffold(
      //resizeToAvoidBottomInset: false,
      appBar: customAppBar(
          title: 'Edit routine',
          leading: null,
          actions: [
            IconButton(
                tooltip: 'Reorder exercices',
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.symmetric(horizontal: 5),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ReorderExercices(
                                rId: widget.rId,
                              )));
                },
                icon: const Icon(Icons.menu)),
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
                          padding: const EdgeInsets.symmetric(vertical: 12),
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
                                                fontWeight: FontWeight.bold,
                                              )),
                                          TextSpan(
                                            text: routineName,
                                          )
                                        ])),
                              ),
                              const Padding(padding: EdgeInsets.only(left: 5)),
                              IconButton(
                                  tooltip: 'Rename routine',
                                  constraints: const BoxConstraints(),
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  onPressed: () {
                                    editRoutineName();
                                  },
                                  icon: const Icon(Icons.edit)),
                            ],
                          ),
                        ),
                      ),
                      (exercicesList.isNotEmpty)
                          ? SliverList.builder(
                              key: _globalKeyList[0],
                              itemCount: exercicesList.length,
                              itemBuilder: (context, i) {
                                exercicesList.sort(
                                    (a, b) => a["pos"].compareTo(b["pos"]));
                                return ExerciceInEditCard(
                                    daKey: _globalKeyList[i + 1],
                                    updateState: updateState,
                                    exName: exercicesList[i]["name"],
                                    exId: exercicesList[i]["id"],
                                    rId: widget.rId);
                              })
                          : const SliverToBoxAdapter(
                              child: Center(child: Text("Add an exercice"))),
                    ],
                  ),
                )),
            const Spacer(),
            button(
                context: context,
                text: 'Add exercice',
                icon: Icons.add,
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ExercicesPage(rId: widget.rId)));
                }),
            Padding(
                padding: EdgeInsets.only(
                    bottom: AppMediaQuerry.mq.padding.bottom + 8)),
          ],
        ),
      ),
    );
  }
}
