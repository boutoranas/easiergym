import 'package:flutter/material.dart';
import 'package:flutter_app/widgets/exercice_selection_card.dart';

class ExerciceChoiceCard extends StatelessWidget {
  final Function chooseExercice;
  final String name;
  final String type;
  const ExerciceChoiceCard(
      {super.key,
      required this.name,
      required this.type,
      required this.chooseExercice});

  @override
  Widget build(BuildContext context) {
    return exerciceSelectionCard(
      name: name,
      color: Theme.of(context).cardColor,
      onTap: () {
        chooseExercice(name);
        Navigator.pop(context);
      },
      type: type,
      trailing: null,
    );
  }
}
