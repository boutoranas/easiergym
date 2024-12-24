import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app/const.dart';
import 'package:flutter_app/widgets/custom%20appbar.dart';

import '../../services/data_update.dart';
import '../../services/user_preferences.dart';
import '../workout/local widgets/reorder exercice list tile.dart';

class ReorderExercicesInSavedLog extends StatefulWidget {
  final String lId;
  const ReorderExercicesInSavedLog({super.key, required this.lId});

  @override
  State<ReorderExercicesInSavedLog> createState() =>
      _ReorderExercicesInSavedLogState();
}

class _ReorderExercicesInSavedLogState
    extends State<ReorderExercicesInSavedLog> {
  Map? userDataMap = DataGestion.userDataMap;
  late List broadExercicesList =
      DataGestion.broadExsInLogList(userDataMap, widget.lId);
  late List exercicesList =
      DataGestion.exercicesInLogList(userDataMap, widget.lId);

  @override
  Widget build(BuildContext context) {
    broadExercicesList = DataGestion.broadExsInLogList(userDataMap, widget.lId);
    exercicesList = DataGestion.exercicesInLogList(userDataMap, widget.lId);
    exercicesList.sort((a, b) => a["pos"].compareTo(b["pos"]));

    return Scaffold(
        appBar: customAppBar(
            title: 'Reorder exercices',
            leading: null,
            actions: null,
            context: context),
        body: Padding(
          padding:
              EdgeInsets.symmetric(horizontal: Const.horizontalPagePadding),
          child: ReorderableListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: exercicesList.length,
            onReorder: (oldIndex, newIndex) {
              if (oldIndex < newIndex) {
                newIndex--;
              }

              final exercice = exercicesList.removeAt(oldIndex);

              exercicesList.insert(newIndex, exercice);

              exercicesList.asMap().forEach(
                (nnum, value) {
                  String keyy = value["id"];

                  broadExercicesList[0]["exercices"][keyy]
                      .addAll({"pos": nnum});
                },
              );

              userDataMap!["logs"][widget.lId]["exercices"] =
                  broadExercicesList[0]["exercices"];

              DataGestion.userDataMap = userDataMap;
              UserPreferences.saveUserDataMap(
                  json.encode(DataGestion.userDataMap));
            },
            itemBuilder: (context, i) {
              return ReorderExTile(
                key: ValueKey(i),
                name: exercicesList[i]["name"],
              );
            },
          ),
        ));
  }
}
