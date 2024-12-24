import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app/screens/workout/local%20widgets/reorder%20exercice%20list%20tile.dart';
import 'package:flutter_app/widgets/custom%20appbar.dart';

import '../../const.dart';
import '../../services/data_update.dart';
import '../../services/user_preferences.dart';

class LogReorderExercices extends StatefulWidget {
  final String rId;
  const LogReorderExercices({super.key, required this.rId});

  @override
  State<LogReorderExercices> createState() => _LogReorderExercicesState();
}

class _LogReorderExercicesState extends State<LogReorderExercices> {
  Map? userDataMapCopy = DataGestion.userDataMapCopy;
  late List broadExercicesList =
      DataGestion.broadExercicesList(userDataMapCopy, widget.rId);
  late List exercicesList =
      DataGestion.exercicesList(userDataMapCopy, widget.rId);

  @override
  Widget build(BuildContext context) {
    broadExercicesList =
        DataGestion.broadExercicesList(userDataMapCopy, widget.rId);
    exercicesList = DataGestion.exercicesList(userDataMapCopy, widget.rId);
    exercicesList.sort((a, b) => a["pos"].compareTo(b["pos"]));
    return Scaffold(
        appBar: customAppBar(
            title: 'Reorder Exercices',
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
              DataGestion.userDataMapCopy = userDataMapCopy;
              UserPreferences.saveLogInProgressMap(
                  json.encode(DataGestion.userDataMapCopy));
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
