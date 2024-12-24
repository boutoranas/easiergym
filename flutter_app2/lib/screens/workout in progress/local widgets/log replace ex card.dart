import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app/widgets/exercice_selection_card.dart';

import '../../../services/data_update.dart';
import '../../../services/user_preferences.dart';

class LogReplaceExCard extends StatelessWidget {
  final String name;
  final String rId;
  final String exId;
  final String type;
  LogReplaceExCard(
      {super.key,
      required this.name,
      required this.rId,
      required this.exId,
      required this.type});

  Map? userDataMapCopy = DataGestion.userDataMapCopy;

  @override
  Widget build(BuildContext context) {
    return exerciceSelectionCard(
      name: name,
      color: Theme.of(context).cardColor,
      onTap: () {
        Map sets = userDataMapCopy!["routines"][rId]["exercices"][exId]["sets"];
        sets.forEach((k, v) {
          v["reps"] = null;
          v["weightinkg"] = null;
        });
        userDataMapCopy!["routines"][rId]["exercices"][exId]["name"] = name;
        userDataMapCopy!["routines"][rId]["exercices"][exId]["im"] = null;
        userDataMapCopy!["routines"][rId]["exercices"][exId]["comment"] = null;
        userDataMapCopy!["routines"][rId]["exercices"][exId]["sets"] = sets;
        UserPreferences.saveLogInProgressMap(
            json.encode(DataGestion.userDataMapCopy));
        Navigator.pop(context);
      },
      type: type,
      trailing: null,
    );
  }
}
