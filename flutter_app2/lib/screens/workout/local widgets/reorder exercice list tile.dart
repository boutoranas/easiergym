import 'dart:io';

import 'package:flutter/material.dart';

import '../../../in app data.dart';

class ReorderExTile extends StatelessWidget {
  final String? name;
  const ReorderExTile({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    Map exercices = InAppData.exercices;
    late String? imagePath = exercices[name]["image"];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.all(0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).cardColor,
          ),
          child: ListTile(
            minVerticalPadding: 0,
            tileColor: Theme.of(context).cardColor,
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
                maxRadius: 28,
                child: imagePath == null
                    ? Text(
                        name![0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
            ),
            title: Text(
              name!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [],
            ),
          ),
        ),
      ),
    );
  }
}
