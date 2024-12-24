import 'dart:convert';

import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/const.dart';
import 'package:flutter_app/services/data_update.dart';
import 'package:flutter_app/widgets/button.dart';
import 'package:flutter_app/widgets/custom%20appbar.dart';

import '../../services/app_media_query.dart';
import '../../services/user_preferences.dart';
import '../workout/local widgets/used exercice card.dart';

class ViewRoutine extends StatelessWidget {
  final Function navigateBackToWkSection;
  final Map routineMap;
  ViewRoutine(
      {super.key,
      required this.routineMap,
      required this.navigateBackToWkSection});

  ScrollController scrollController = ScrollController();

  final userID = FirebaseAuth.instance.currentUser!.uid;
  late DatabaseReference database =
      FirebaseDatabase.instance.ref().child("users").child(userID);

  late DatabaseReference ref = FirebaseDatabase.instance
      .ref()
      .child("users")
      .child(userID)
      .child("easiergym");

  Map? userDataMap = DataGestion.userDataMap;

  late List exercicesList = routineMap["exercices"].values.toList();

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

  addAsRoutine(context) {
    //create key and map
    final routineKey = ref.child("routines").push();
    final newRoutine = <String, dynamic>{
      'exercices': routineMap["exercices"],
      'name': routineMap["name"],
      'id': routineKey.key,
    };
    //add routine locally
    if (userDataMap != null && userDataMap!["routines"] != null) {
      userDataMap!["routines"].addAll(json.decode(
          json.encode({routineKey.key as String: newRoutine as dynamic})));
    } else if (userDataMap == null) {
      userDataMap = json.decode(json.encode({
        "routines": {routineKey.key as String: newRoutine as dynamic}
      }));
    } else {
      userDataMap!["routines"] = json.decode(
          json.encode({routineKey.key as String: newRoutine as dynamic}));
    }
    DataGestion.userDataMap = userDataMap;
    UserPreferences.saveUserDataMap(json.encode(DataGestion.userDataMap));
    /* //add on database
                //await routineKey.set(newRoutine); */
    Navigator.pop(context);
    navigateBackToWkSection(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
          title: routineMap["name"],
          leading: null,
          actions: null,
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
                      const SliverToBoxAdapter(
                          child: Padding(padding: EdgeInsets.only(bottom: 10))),
                      SliverToBoxAdapter(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: RichText(
                            text: TextSpan(
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .inputDecorationTheme
                                      .border!
                                      .borderSide
                                      .color,
                                ),
                                children: [
                                  const TextSpan(
                                    text: 'Muscles worked: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        '${routineMap["muscles worked"].join(", ")}.',
                                  ),
                                ]),
                          ),
                          /* Text(
                        "Muscles worked: ${routineMap["muscles worked"].join(", ")}.") */
                        ),
                      ),
                      const SliverToBoxAdapter(
                          child: Padding(padding: EdgeInsets.only(bottom: 10))),
                      SliverList.builder(
                          itemCount: exercicesList.length,
                          itemBuilder: (context, i) {
                            exercicesList
                                .sort((a, b) => a["pos"].compareTo(b["pos"]));
                            return UsedExerciceCard(
                                name: exercicesList[i]["name"],
                                numberofsets:
                                    getNumberOfSets(exercicesList[i]["sets"]));
                          }),
                    ],
                  ),
                )),
            const Spacer(),
            button(
                icon: Icons.add,
                color: Theme.of(context).primaryColor,
                context: context,
                onPressed: () {
                  addAsRoutine(context);
                },
                text: 'Add to routines'),
            Padding(
                padding: EdgeInsets.only(
                    bottom: AppMediaQuerry.mq.padding.bottom + 8)),
          ],
        ),
      ),
    );
  }
}
