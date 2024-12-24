import 'package:flutter/material.dart';

Widget routinesNLogCard({
  required Function onTap,
  required BuildContext context,
  required String name,
  String? exercicesOfRoutine,
  Widget? trailing,
}) {
  return Card(
    margin: const EdgeInsets.symmetric(vertical: 5),
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: ListTile(
      onTap: () {
        onTap();
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      minVerticalPadding: 30,
      tileColor: Theme.of(context).cardColor,
      title: Text(name),
      subtitle: exercicesOfRoutine != null
          ? Text(
              exercicesOfRoutine,
              maxLines: 2,
              style: const TextStyle(
                overflow: TextOverflow.ellipsis,
              ),
            )
          : null,
      trailing: trailing,
    ),
  );
}
