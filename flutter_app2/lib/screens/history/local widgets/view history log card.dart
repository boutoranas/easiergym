import 'package:flutter/material.dart';
import 'package:flutter_app/widgets/exercice_view_card.dart';

class ViewHistoryLogCard extends StatelessWidget {
  final String name;
  final int numberOfSets;
  const ViewHistoryLogCard(
      {super.key, required this.name, required this.numberOfSets});

  @override
  Widget build(BuildContext context) {
    return exerciceViewCard(
      context: context,
      name: name,
      numberofsets: numberOfSets,
    );
  }
}
