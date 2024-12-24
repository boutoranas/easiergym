import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/const.dart';
import 'package:flutter_app/in%20app%20data.dart';
import 'package:flutter_app/services/app_media_query.dart';
import 'package:flutter_app/widgets/button.dart';
import 'package:flutter_app/widgets/snack_bar.dart';

import '../../services/data_update.dart';
import '../../services/user_preferences.dart';
import '../../widgets/custom appbar.dart';

class CreateExercicePage extends StatefulWidget {
  final Function updateState;
  const CreateExercicePage({super.key, required this.updateState});

  @override
  State<CreateExercicePage> createState() => _CreateExercicePageState();
}

class _CreateExercicePageState extends State<CreateExercicePage> {
  //!controllers
  TextEditingController titleController = TextEditingController();

  TextEditingController descriptionController = TextEditingController();

  //!database
  final userID = FirebaseAuth.instance.currentUser!.uid;
  late DatabaseReference database =
      FirebaseDatabase.instance.ref().child("users").child(userID);

  late DatabaseReference ref = FirebaseDatabase.instance
      .ref()
      .child("users")
      .child(userID)
      .child("easiergym")
      .child("created");

  Map? userDataMap = DataGestion.userDataMap;

  //!exercices data
  Map exercices = InAppData.exercices;

  List muscles = InAppData.muscles;

  List categories = InAppData.exerciceCategories;

  String selectedMuscle = '';

  String selectedCategory = '';

  //!functions
  saveExercice() {
    if (titleController.text.isNotEmpty &&
        selectedMuscle != '' &&
        selectedCategory != '') {
      if (exercices[titleController.text] == null) {
        exercices.addAll({
          titleController.text: {
            "name": titleController.text,
            "description": descriptionController.text.isNotEmpty
                ? descriptionController.text
                : null,
            "type": selectedMuscle,
            "category": selectedCategory[0]
          }
        });
        Map exsHistory = json.decode(json.encode(InAppData.exercices));
        exsHistory.forEach((key, value) {
          exsHistory[key].addAll({"history": {}});
        });
        //calculate prs
        exsHistory.forEach((k, v) {
          int maxReps = 0;
          num maxWeight = 0;
          int maxVolumeReps = 0;
          num maxVolumeWeight = 0;
          exsHistory[k]["history"].forEach((kk, vv) {
            exsHistory[k]["history"][kk]["sets"].forEach((kkk, vvv) {
              if (vvv["reps"] != null && vvv["reps"] > maxReps) {
                maxReps = vvv["reps"];
              }
              if (vvv["weightinkg"] != null && vvv["weightinkg"] > maxWeight) {
                maxWeight = vvv["weightinkg"];
              }
              if (vvv["reps"] != null &&
                  vvv["weightinkg"] != null &&
                  vvv["reps"] * vvv["weightinkg"] >
                      maxVolumeReps * maxVolumeWeight) {
                maxVolumeWeight = vvv["weightinkg"];
                maxVolumeReps = vvv["reps"];
              }
            });
          });
          exsHistory[k]["prs"] = {
            "maxReps": maxReps,
            "maxWeight": maxWeight,
            "maxVolumeReps": maxVolumeReps,
            "maxVolumeWeight": maxVolumeWeight
          };
        });
        DataGestion.exsHistory = exsHistory;
        //add to userdatamap
        if (userDataMap != null && userDataMap!["created"] != null) {
          userDataMap!["created"].addAll({
            titleController.text: {
              "name": titleController.text,
              "description": descriptionController.text.isNotEmpty
                  ? descriptionController.text
                  : null,
              "type": selectedMuscle,
              "category": selectedCategory[0]
            }
          });
        } else if (userDataMap == null) {
          userDataMap = {
            "created": {
              titleController.text: {
                "name": titleController.text,
                "description": descriptionController.text.isNotEmpty
                    ? descriptionController.text
                    : null,
                "type": selectedMuscle,
                "category": selectedCategory[0]
              }
            }
          };
        } else {
          userDataMap!["created"] = {
            titleController.text: {
              "name": titleController.text,
              "description": descriptionController.text.isNotEmpty
                  ? descriptionController.text
                  : null,
              "type": selectedMuscle,
              "category": selectedCategory[0]
            }
          };
        }
        DataGestion.userDataMap = userDataMap;
        UserPreferences.saveUserDataMap(json.encode(DataGestion.userDataMap));

        //
        widget.updateState();
        Navigator.pop(context);
      } else {
        showSnackBar(context, 'Exercice already exists');
      }
    } else {
      showSnackBar(context, 'All fields except the description are required');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
          title: 'Create exercice',
          leading: null,
          actions: null,
          context: context),
      /* AppBar(
        title: Text("Create exercice"),
      ), */
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding:
              EdgeInsets.symmetric(horizontal: Const.horizontalPagePadding / 2),
          child: Column(
            children: [
              const Padding(padding: EdgeInsets.only(bottom: 10)),
              inputTextField(
                  context: context, label: 'name', controller: titleController),
              const Padding(padding: EdgeInsets.only(bottom: 15)),
              inputTextField(
                  maxLength: 1000,
                  maxLines: 15,
                  keyboardType: TextInputType.multiline,
                  context: context,
                  label: 'description',
                  controller: descriptionController),
              const Padding(padding: EdgeInsets.only(bottom: 8)),
              ListTile(
                title: RichText(
                    text: TextSpan(
                        children: [
                      const TextSpan(
                        text: 'Muscle worked: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: selectedMuscle,
                      )
                    ],
                        style: TextStyle(
                          color: Theme.of(context)
                              .inputDecorationTheme
                              .border!
                              .borderSide
                              .color,
                          fontSize: 17,
                        ))),
                /* Text("Muscle worked: $selectedMuscle"), */
                trailing: PopupMenuButton(
                  icon: const Icon(Icons.arrow_drop_down),
                  itemBuilder: (context) {
                    return List.generate(muscles.length, (index) {
                      return PopupMenuItem(
                        onTap: () {
                          setState(() {
                            selectedMuscle = muscles[index].toLowerCase();
                          });
                        },
                        child: Text(muscles[index]),
                      );
                    });
                  },
                ),
              ),
              ListTile(
                title: RichText(
                    text: TextSpan(
                        children: [
                      const TextSpan(
                        text: 'Category: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: selectedCategory,
                      )
                    ],
                        style: TextStyle(
                          color: Theme.of(context)
                              .inputDecorationTheme
                              .border!
                              .borderSide
                              .color,
                          fontSize: 17,
                        ))), //Text("Category: $selectedCategory"),
                trailing: PopupMenuButton(
                  icon: const Icon(Icons.arrow_drop_down),
                  itemBuilder: (context) {
                    return List.generate(categories.length, (index) {
                      return PopupMenuItem(
                        onTap: () {
                          setState(() {
                            selectedCategory = categories[index].toLowerCase();
                          });
                        },
                        child: Text(categories[index]),
                      );
                    });
                  },
                ),
              ),
              const Padding(padding: EdgeInsets.only(top: 10)),
              button(
                context: context,
                onPressed: () {
                  saveExercice();
                },
                text: 'save',
                color: Theme.of(context).primaryColor,
                width: MediaQuery.of(context).size.width / 2.5,
              ),
              Padding(
                  padding: EdgeInsets.only(
                      bottom: AppMediaQuerry.mq.padding.bottom + 8)),
            ],
          ),
        ),
      ),
    );
  }
}

Widget inputTextField({
  required BuildContext context,
  required String label,
  required TextEditingController controller,
  int maxLength = 250,
  int maxLines = 1,
  keyboardType = TextInputType.text,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 10, left: 5),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
          ),
        ),
      ),
      Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(25),
        ),
        child: TextField(
          keyboardType: keyboardType,
          maxLines: maxLines,
          minLines: 1,
          maxLength: 250,
          controller: controller,
          decoration: InputDecoration(
              counterText: '',
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 17, horizontal: 15),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: const BorderSide(color: Colors.grey),
              )),
        ),
      ),
    ],
  );
}
