import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/widgets/exercice_selection_card.dart';

import '../../../services/data_update.dart';
import '../../workout/detail exercices.dart';

class AddExerciceCardInSavedLog extends StatefulWidget {
  final Function updateState;
  final String lId;
  final String name;
  final String type;
  const AddExerciceCardInSavedLog(
      {super.key,
      required this.lId,
      required this.name,
      required this.type,
      required this.updateState});

  @override
  State<AddExerciceCardInSavedLog> createState() =>
      _AddExerciceCardInSavedLogState();
}

class _AddExerciceCardInSavedLogState extends State<AddExerciceCardInSavedLog> {
  final userID = FirebaseAuth.instance.currentUser!.uid;
  late DatabaseReference database =
      FirebaseDatabase.instance.ref().child("users").child(userID);

  late DatabaseReference ref = FirebaseDatabase.instance
      .ref()
      .child("users")
      .child(userID)
      .child("easiergym")
      .child("logs")
      .child(widget.lId);

  Map? userDataMap = DataGestion.userDataMap;

  late bool selected = false;

  late Map newEx;
  late Map newSet;
  late DatabaseReference exKey;
  late DatabaseReference setKey;

  Map selectedExercices = DataGestion.selectedExercices;

  @override
  void initState() {
    //verifying if already selected
    if (DataGestion.selectedExercices[widget.name] != null) {
      selected = true;
    }
    creatingExercice();
    super.initState();
  }

  creatingExercice() {
    //creating the future exercice
    exKey = ref.child("exercices").push();

    setKey = exKey.child("sets").push();

    //Map? mapp = userDataMap!["routines"][widget.rId]["exercices"];
    newSet = <String, dynamic>{
      'id': setKey.key,
      'finished': false,
    };
    newEx = <String, dynamic>{
      'id': exKey.key,
      'name': widget.name,
      'sets': {
        setKey.key as String: newSet as dynamic,
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    if (DataGestion.selectedExercices[widget.name] != null) {
      selected = true;
    } else {
      selected = false;
    }
    creatingExercice();
    return exerciceSelectionCard(
      name: widget.name,
      color: selected == false ? Theme.of(context).cardColor : Colors.green,
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ExercicesDetail(
                      exName: widget.name,
                    )));
      },
      type: widget.type,
      trailing: Checkbox(
          value: selected,
          onChanged: (value) {
            setState(() {
              selected = !selected;
            });

            if (value == true) {
              DataGestion.selectedExercices.addAll({
                widget.name: {exKey.key as String: newEx as dynamic}
              });
            } else {
              DataGestion.selectedExercices.remove(widget.name);
            }
            widget.updateState();
          }),
    );
  }
}
