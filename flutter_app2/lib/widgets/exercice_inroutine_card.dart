import 'dart:io';

import 'package:flutter/material.dart';

import '../in app data.dart';
import 'button.dart';

Widget exerciceInRoutineCard({
  required String name,
  required Widget popupMenuButton,
  required String? comment,
  required TextEditingController commentController,
  required Function updateComment,
  required Function addSet,
  required String unit1,
  required String unit2,
  required BuildContext context,
  required Widget listViewBuilder,
  bool checkBox = false,
}) {
  Map exercices = InAppData.exercices;
  late String? imagePath = exercices[name]["image"];
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 0),
    child: Column(
      children: [
        Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            minVerticalPadding: 20,
            leading: Container(
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    width: 1,
                  )),
              child: CircleAvatar(
                backgroundImage: imagePath != null
                    ? Image.file(File(imagePath)).image
                    : null,
                maxRadius: 20,
                child: imagePath == null
                    ? Text(
                        name[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
            ),
            title: Text(name),
            trailing: popupMenuButton,
          ),
        ),
        const Padding(padding: EdgeInsets.only(bottom: 5)),

        comment != null
            ? TextField(
                minLines: 1,
                maxLines: 10,
                style: const TextStyle(
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                    fillColor: const Color.fromARGB(255, 233, 226, 130),
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    )),
                controller: commentController,
                keyboardType: TextInputType.multiline,
                onChanged: (value) {
                  updateComment();
                },
              )
            : Container(),
        //),
        const Padding(padding: EdgeInsets.only(bottom: 5)),
        Row(
          children: checkBox == false
              ? [
                  const Text('Set'),
                  const Expanded(child: Center(child: Text('Previous'))),
                  Container(
                    width: 80,
                    child: Center(child: Text(unit1)),
                  ),
                  const Padding(padding: EdgeInsets.only(left: 28)),
                  Container(
                    width: 80,
                    child: Center(child: Text(unit2)),
                  ),
                ]
              : [
                  const Text('Set'),
                  const Expanded(child: Center(child: Text('Previous'))),
                  Container(
                    width: 80,
                    child: Center(child: Text(unit1)),
                  ),
                  const Padding(padding: EdgeInsets.only(left: 10)),
                  Container(
                    width: 80,
                    child: Center(child: Text(unit2)),
                  ),
                  const Padding(padding: EdgeInsets.only(left: 30)),
                ],
        ),
        listViewBuilder,
        button(
            context: context,
            text: 'Add set',
            width: 110,
            height: 35,
            color: Colors.yellow,
            icon: null,
            onPressed: () {
              addSet();
            }),
        const Padding(padding: EdgeInsets.only(bottom: 10)),
      ],
    ),
  );
}
