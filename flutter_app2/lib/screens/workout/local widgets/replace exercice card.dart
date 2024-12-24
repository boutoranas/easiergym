import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_app/widgets/exercice_selection_card.dart';

import '../../../services/data_update.dart';
import '../../../services/user_preferences.dart';

class ReplaceExerciceCard extends StatelessWidget {
  final String name;
  final String rId;
  final String exId;
  final String type;
  ReplaceExerciceCard(
      {super.key,
      required this.name,
      required this.rId,
      required this.type,
      required this.exId});

  Map? userDataMap = DataGestion.userDataMap;

  @override
  Widget build(BuildContext context) {
    return exerciceSelectionCard(
      name: name,
      color: Theme.of(context).cardColor,
      onTap: () {
        Map sets = userDataMap!["routines"][rId]["exercices"][exId]["sets"];
        sets.forEach((k, v) {
          v["reps"] = null;
          v["weightinkg"] = null;
        });
        userDataMap!["routines"][rId]["exercices"][exId]["name"] = name;
        userDataMap!["routines"][rId]["exercices"][exId]["im"] = null;
        userDataMap!["routines"][rId]["exercices"][exId]["comment"] = null;
        userDataMap!["routines"][rId]["exercices"][exId]["sets"] = sets;
        UserPreferences.saveUserDataMap(json.encode(DataGestion.userDataMap));
        Navigator.pop(context);
      },
      type: type,
      trailing: null,
    );
  }
}
