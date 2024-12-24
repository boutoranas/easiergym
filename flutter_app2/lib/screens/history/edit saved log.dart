import 'dart:convert';

import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/const.dart';
import 'package:flutter_app/screens/history/reorder%20exercices%20in%20saved%20log.dart';
import 'package:flutter_app/widgets/button.dart';

import '../../main.dart';
import '../../services/app_media_query.dart';
import '../../services/data_update.dart';
import '../../services/user_preferences.dart';
import '../../widgets/custom appbar.dart';
import 'exercices in saved log page.dart';
import 'local widgets/exercice card saved log.dart';

class EditSavedLog extends StatefulWidget {
  final String lName;
  final String lId;
  const EditSavedLog({super.key, required this.lName, required this.lId});

  @override
  State<EditSavedLog> createState() => _EditSavedLogState();
}

class _EditSavedLogState extends State<EditSavedLog> with RouteAware {
  ScrollController scrollController = ScrollController();

  late String logName = widget.lName;
  TextEditingController logEditController = TextEditingController();

  final userID = FirebaseAuth.instance.currentUser!.uid;
  late DatabaseReference database =
      FirebaseDatabase.instance.ref().child("users").child(userID);

  late DatabaseReference ref = FirebaseDatabase.instance
      .ref()
      .child("users")
      .child(userID)
      .child("easiergym")
      .child("logs")
      .child(widget.lId);

  Map? userDataMap = DataGestion.userDataMap;
  late List exsInLogList =
      DataGestion.exercicesInLogList(userDataMap, widget.lId);

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

  void updateState() {
    setState(() {});
  }

  renameRoutine(context) {
    logEditController.value = logEditController.value.copyWith(text: logName);
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text('Edit log name'),
              content: TextField(
                maxLength: 250,
                controller: logEditController,
                autofocus: true,
                decoration: const InputDecoration(
                    hintText: 'Enter your log\'s name', counterText: ''),
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    if (logEditController.text.isNotEmpty) {
                      //display only change
                      setState(() {
                        logName = logEditController.text;
                      });
                      //update local data

                      userDataMap!["logs"][widget.lId]["name"] = logName;

                      DataGestion.userDataMap = userDataMap;
                      UserPreferences.saveUserDataMap(
                          json.encode(DataGestion.userDataMap));
                      ////update database

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
    exsInLogList = DataGestion.exercicesInLogList(userDataMap, widget.lId);
    logName = userDataMap!["logs"][widget.lId]["name"];

    return Scaffold(
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
                          builder: (context) => ReorderExercicesInSavedLog(
                                lId: widget.lId,
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
                                          text: logName,
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
                                  renameRoutine(context);
                                },
                                icon: const Icon(Icons.edit)),
                          ],
                        ),
                      ),
                    ),
                    (exsInLogList.isNotEmpty)
                        ? SliverList.builder(
                            itemCount: exsInLogList.length,
                            itemBuilder: (context, i) {
                              exsInLogList
                                  .sort((a, b) => a["pos"].compareTo(b["pos"]));

                              return ExerciceInSavedLogCard(
                                updateState: updateState,
                                lId: widget.lId,
                                exName: exsInLogList[i]["name"],
                                exId: exsInLogList[i]["id"],
                              );
                            })
                        : const SliverToBoxAdapter(
                            child: Center(child: Text("Add an exercice"))),
                  ],
                ),
              ),
            ),
            const Spacer(),
            button(
                icon: Icons.add,
                context: context,
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ExercicesPageInSavedLog(lId: widget.lId)));
                },
                text: 'Add exercice'),
            Padding(
                padding: EdgeInsets.only(
                    bottom: AppMediaQuerry.mq.padding.bottom + 8)),
          ],
        ),
      ),
    );
  }
}
