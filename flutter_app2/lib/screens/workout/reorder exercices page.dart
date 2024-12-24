import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app/const.dart';
import 'package:flutter_app/screens/workout/local%20widgets/reorder%20exercice%20list%20tile.dart';
import 'package:flutter_app/widgets/custom%20appbar.dart';

import '../../services/data_update.dart';
import '../../services/user_preferences.dart';

class ReorderExercices extends StatefulWidget {
  final String rId;
  const ReorderExercices({super.key, required this.rId});

  @override
  State<ReorderExercices> createState() => _ReorderExercicesState();
}

class _ReorderExercicesState extends State<ReorderExercices> {
  Map? userDataMap = DataGestion.userDataMap;
  late List broadExercicesList =
      DataGestion.broadExercicesList(userDataMap, widget.rId);
  late List exercicesList = DataGestion.exercicesList(userDataMap, widget.rId);

  @override
  Widget build(BuildContext context) {
    broadExercicesList =
        DataGestion.broadExercicesList(userDataMap, widget.rId);
    exercicesList = DataGestion.exercicesList(userDataMap, widget.rId);
    exercicesList.sort((a, b) => a["pos"].compareTo(b["pos"]));
    return Scaffold(
        appBar: customAppBar(title: 'Reorder Exercices', context: context),
        body: Padding(
          padding:
              EdgeInsets.symmetric(horizontal: Const.horizontalPagePadding),
          child: ReorderableListView.builder(
            padding: EdgeInsets.symmetric(vertical: 5),
            proxyDecorator: (child, index, animation) {
              return Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        spreadRadius: 4,
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      ),
                    ]),
                child: child,
              );
            },
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

              userDataMap!["routines"][widget.rId]["exercices"] =
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
