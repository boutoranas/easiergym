import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app/const.dart';
import 'package:flutter_app/widgets/custom%20appbar.dart';

import '../../services/data_update.dart';
import '../../services/user_preferences.dart';
import '../../widgets/routines_log_card.dart';

class ReorderRoutines extends StatefulWidget {
  const ReorderRoutines({super.key});

  @override
  State<ReorderRoutines> createState() => _ReorderRoutinesState();
}

class _ReorderRoutinesState extends State<ReorderRoutines> {
  Map? userDataMap = DataGestion.userDataMap;
  List routinesList = DataGestion.routinesList(DataGestion.userDataMap);

  @override
  Widget build(BuildContext context) {
    routinesList = DataGestion.routinesList(userDataMap);
    return Scaffold(
      appBar: customAppBar(title: 'Reorder routines', context: context),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: Const.horizontalPagePadding),
        child: ReorderableListView.builder(
          padding: EdgeInsets.symmetric(vertical: 5),
          proxyDecorator: (child, index, animation) {
            return Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      spreadRadius: 4,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ]),
              child: child,
            );
          },
          physics: BouncingScrollPhysics(),
          itemBuilder: (context, i) {
            routinesList.sort((a, b) => b["id"].compareTo(a["id"]));
            return Container(
              key: ValueKey(i),
              child: routinesNLogCard(
                  context: context,
                  onTap: () {},
                  name: routinesList[i]["name"]),
            );
          },
          itemCount: routinesList.length,
          onReorder: (oldIndex, newIndex) {
            if (oldIndex < newIndex) {
              newIndex--;
            }

            List ids = [];

            for (var r in routinesList) {
              ids.add(r["id"]);
            }

            final routine = routinesList.removeAt(oldIndex);

            routinesList.insert(newIndex, routine);

            for (var r in routinesList) {
              r["id"] = ids[0];
              ids.remove(ids[0]);
            }

            userDataMap!["routines"] = {};

            for (var r in routinesList) {
              userDataMap!["routines"].addAll({r["id"]: r});
            }

            //setState(() {});

            DataGestion.userDataMap = userDataMap;
            UserPreferences.saveUserDataMap(
                json.encode(DataGestion.userDataMap));
          },
        ),
      ),
    );
  }
}
