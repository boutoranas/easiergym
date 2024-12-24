import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app/in%20app%20data.dart';

Widget exerciceSelectionCard({
  required String name,
  required Color color,
  required Function onTap,
  required String type,
  required Widget? trailing,
}) {
  Map exercices = InAppData.exercices;
  late String? imagePath = exercices[name]["image"];
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Card(
      elevation: 0,
      margin: const EdgeInsets.all(0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: color,
        ),
        child: ListTile(
          onTap: () {
            onTap();
          },
          minVerticalPadding: 0,
          tileColor: color,
          leading: Container(
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  width: 1,
                )),
            child: CircleAvatar(
              backgroundImage:
                  imagePath != null ? Image.file(File(imagePath)).image : null,
              maxRadius: 28,
              child: imagePath == null
                  ? Text(
                      name[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
          ),
          title: Text(
            name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(type),
          trailing: trailing,
        ),
      ),
    ),
  );
}
