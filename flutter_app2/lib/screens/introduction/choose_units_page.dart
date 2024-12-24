import 'package:flutter/material.dart';
import 'package:flutter_app/const.dart';
import 'package:flutter_app/theme/theme.dart';

import '../../services/data_update.dart';
import '../../services/user_preferences.dart';

class ChooseUnitsPage extends StatefulWidget {
  const ChooseUnitsPage({super.key});

  @override
  State<ChooseUnitsPage> createState() => _ChooseUnitsPageState();
}

class _ChooseUnitsPageState extends State<ChooseUnitsPage> {
  String weightUnit = "kg";
  String distanceUnit = "km";
  String sizeUnit = "cm";

  @override
  void initState() {
    if (DataGestion.weightImperial == true) {
      weightUnit = "lbs";
    }
    if (DataGestion.distanceImperial == true) {
      distanceUnit = "miles";
    }
    if (DataGestion.sizeImperial == true) {
      sizeUnit = "in";
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: testThemeYellow().scaffoldBackgroundColor,
      body: Stack(
        children: [
          Container(
            alignment: const Alignment(0, -0.65),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Choose units',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Selected the desired weight unit, distance unit and size unit that you want to be displayed!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: const Alignment(0, 0.1),
            child: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: Const.horizontalPagePadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  unitCard(
                    itemBuilder: (context) {
                      return [
                        const PopupMenuItem(
                          value: "kg",
                          child: Text("kg"),
                        ),
                        const PopupMenuItem(
                          value: "lbs",
                          child: Text("lbs"),
                        ),
                      ];
                    },
                    onSelected: (value) {
                      setState(() {
                        weightUnit = value;
                      });

                      if (value == "kg") {
                        DataGestion.weightImperial = false;
                        UserPreferences.setWeightUnit(false);
                      } else {
                        DataGestion.weightImperial = true;
                        UserPreferences.setWeightUnit(true);
                      }
                    },
                    context: context,
                    title: 'Weight',
                    unitText: weightUnit,
                  ),
                  unitCard(
                    itemBuilder: (context) {
                      return [
                        const PopupMenuItem(
                          value: "km",
                          child: Text("km"),
                        ),
                        const PopupMenuItem(
                          value: "miles",
                          child: Text("miles"),
                        ),
                      ];
                    },
                    onSelected: (value) {
                      setState(() {
                        distanceUnit = value;
                      });
                      if (value == "km") {
                        DataGestion.distanceImperial = false;
                        UserPreferences.setDistanceUnit(false);
                      } else {
                        DataGestion.distanceImperial = true;
                        UserPreferences.setDistanceUnit(true);
                      }
                    },
                    context: context,
                    title: 'Distance',
                    unitText: distanceUnit,
                  ),
                  unitCard(
                    itemBuilder: (context) {
                      return [
                        const PopupMenuItem(
                          value: "cm",
                          child: Text("cm"),
                        ),
                        const PopupMenuItem(
                          value: "in",
                          child: Text("in"),
                        ),
                      ];
                    },
                    onSelected: (value) {
                      setState(() {
                        sizeUnit = value;
                      });
                      if (value == "cm") {
                        DataGestion.sizeImperial = false;
                        UserPreferences.setSizeUnit(false);
                      } else {
                        DataGestion.sizeImperial = true;
                        UserPreferences.setSizeUnit(true);
                      }
                    },
                    context: context,
                    title: 'Size',
                    unitText: sizeUnit,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget unitCard({
  required List<PopupMenuEntry<String>> Function(BuildContext) itemBuilder,
  required void Function(String)? onSelected,
  required BuildContext context,
  required String title,
  required String unitText,
}) {
  return Card(
    color: testThemeYellow().cardColor,
    margin: const EdgeInsets.symmetric(vertical: 10),
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    child: ListTile(
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.black,
        ),
      ),
      trailing: PopupMenuButton(
        itemBuilder: itemBuilder,
        onSelected: onSelected,
        child: Container(
          height: 35,
          width: 85,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Align(
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  unitText,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(
                  width: 20,
                  child: Icon(
                    Icons.arrow_drop_down,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
