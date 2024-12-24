import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../widgets/exercice_selection_card.dart';
import '../workout/detail exercices.dart';

class ExerciceCardInProfile extends StatefulWidget {
  final Function updateState;
  final String name;
  final String type;
  const ExerciceCardInProfile({
    super.key,
    required this.name,
    required this.type,
    required this.updateState,
  });

  @override
  State<ExerciceCardInProfile> createState() => _ExerciceCardInProfileState();
}

class _ExerciceCardInProfileState extends State<ExerciceCardInProfile> {
  final userID = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return exerciceSelectionCard(
      name: widget.name,
      type: widget.type,
      color: Theme.of(context).cardColor,
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ExercicesDetail(
                      exName: widget.name,
                    )));
      },
      trailing: null,
    );
  }
}
