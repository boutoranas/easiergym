import 'package:flutter/material.dart';

import '../../../widgets/exercice_view_card.dart';

class UsedExerciceCard extends StatelessWidget {
  final String name;
  final int numberofsets;
  const UsedExerciceCard({
    super.key,
    required this.name,
    required this.numberofsets,
  });

  @override
  Widget build(BuildContext context) {
    return exerciceViewCard(
      context: context,
      name: name,
      numberofsets: numberofsets,
    );
  }
}
