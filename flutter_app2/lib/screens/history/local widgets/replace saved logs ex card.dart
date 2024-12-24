import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app/widgets/exercice_selection_card.dart';

import '../../../services/data_update.dart';
import '../../../services/user_preferences.dart';

class SavedLogReplaceExsCard extends StatelessWidget {
  final String name;
  final String lId;
  final String exId;
  final String type;
  SavedLogReplaceExsCard(
      {super.key,
      required this.name,
      required this.lId,
      required this.exId,
      required this.type});

  Map? userDataMap = DataGestion.userDataMap;

  @override
  Widget build(BuildContext context) {
    return exerciceSelectionCard(
      name: name,
      color: Theme.of(context).cardColor,
      onTap: () {
        Map sets = userDataMap!["logs"][lId]["exercices"][exId]["sets"];
        sets.forEach((k, v) {
          v["reps"] = null;
          v["weightinkg"] = null;
        });
        userDataMap!["logs"][lId]["exercices"][exId]["name"] = name;
        userDataMap!["logs"][lId]["exercices"][exId]["im"] = null;
        userDataMap!["logs"][lId]["exercices"][exId]["comment"] = null;
        userDataMap!["logs"][lId]["exercices"][exId]["sets"] = sets;

        UserPreferences.saveUserDataMap(json.encode(DataGestion.userDataMap));
        Navigator.pop(context);
      },
      type: type,
      trailing: null,
    );
  }
}
