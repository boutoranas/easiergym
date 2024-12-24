import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/const.dart';
import 'package:flutter_app/in%20app%20data.dart';
import 'package:flutter_app/services/data_update.dart';
import 'package:flutter_app/widgets/custom%20appbar.dart';

import '../../services/date formater.dart';

class ExercicesDetail extends StatelessWidget {
  final String exName;
  ExercicesDetail({super.key, required this.exName});

  ScrollController scrollController = ScrollController();

  Map exsHistory = DataGestion.exsHistory;

  late List routines = exsHistory[exName]["history"].values.toList();
  late String category = exsHistory[exName]["category"];

  bool weightImperial = DataGestion.weightImperial;
  bool distanceImperial = DataGestion.distanceImperial;

  int calculateNumber(List sets, index) {
    sets.sort((a, b) => a["id"].compareTo(b["id"]));
    List nonWSets = [];
    for (var element in sets) {
      if (element["type"] != "W") {
        nonWSets.add(element);
      }
    }
    if (nonWSets.contains(sets[index])) {
      return nonWSets.indexOf(sets[index]) + 1;
    } else {
      return 0;
    }
  }

  String calculateUnit2(num val) {
    RegExp dec = RegExp(r'^([0-9]?)+([\.][0-9]+)$');
    RegExp oneDec = RegExp(r'^([0-9]?)+([\.][0-9])$');
    RegExp zeros = RegExp(r'^([0-9]?)+([\.][0][0]?)$');

    if (dec.hasMatch(val.toString())) {
      double number = double.parse(val.toString());
      if (zeros.hasMatch(number.toString())) {
        //number with one or two zeros as decimals ("3.0 or 4.00")
        return (double.parse(val.toString())).round().toString();
      } else {
        if (oneDec.hasMatch(number.toString())) {
          //numbers with one decimal (1.3 or 0.8)
          return val.toStringAsFixed(1);
        } else {
          //numbers with two decimals (1.65 or 10.34)
          return val.toStringAsFixed(2);
        }
      }
    } else {
      //int numbers (1, 5)
      return double.parse(val.toString()).round().toString();
    }
  }

  String calculateUnit1(reps) {
    if (category == "c" || category == "d") {
      DateTime duration = DateTime.fromMillisecondsSinceEpoch(reps * 1000);
      String twoDigits(int n) => n.toString().padLeft(2, '0');
      final hours = twoDigits(duration.hour);
      final minutes = twoDigits(duration.minute);
      final seconds = twoDigits(duration.second);
      return "$hours:$minutes:$seconds";
    } else {
      return reps.toString();
    }
  }

  Widget prText() {
    int repsPr = DataGestion.exsHistory[exName]["prs"]["maxReps"];
    num weightPr = DataGestion.exsHistory[exName]["prs"]["maxWeight"];
    int volumeRepsPr = DataGestion.exsHistory[exName]["prs"]["maxVolumeReps"];
    num volumeWeightPr =
        DataGestion.exsHistory[exName]["prs"]["maxVolumeWeight"];
    //bool imperial = false;

    List units = ["reps", "kg", "", "+kg", "-kg", "km"];

    if (category != "c") {
      if (weightImperial == true) {
        units = ["reps", "lbs", "", "+lbs", "-lbs", "miles"];
      } else {
        units = ["reps", "kg", "", "+kg", "-kg", "km"];
      }
    } else {
      if (distanceImperial == true) {
        units = ["reps", "lbs", "", "+lbs", "-lbs", "miles"];
      } else {
        units = ["reps", "kg", "", "+kg", "-kg", "km"];
      }
    }
    late String unit1;
    late String unit2;
    if (category == "r") {
      unit1 = units[0];
      unit2 = units[1];
    }
    if (category == "b") {
      unit1 = units[0];
      unit2 = units[3];
    }
    if (category == "a") {
      unit1 = units[0];
      unit2 = units[4];
    }
    if (category == "c") {
      unit1 = units[2];
      unit2 = units[5];
    }
    if (category == "d") {
      unit1 = units[2];
      unit2 = units[3];
    }
    String reps = calculateUnit1(repsPr);
    String weight;
    if (category != "c") {
      weightImperial == false
          ? weight = calculateUnit2(weightPr)
          : weight = calculateUnit2(weightPr * 2.2);
    } else {
      distanceImperial == false
          ? weight = calculateUnit2(weightPr)
          : weight = calculateUnit2(weightPr * 0.6214);
    }
    String volumeReps = calculateUnit1(volumeRepsPr);
    String volumeWeight;
    if (category != "c") {
      weightImperial == false
          ? volumeWeight = calculateUnit2(volumeWeightPr)
          : volumeWeight = calculateUnit2(volumeWeightPr * 2.2);
    } else {
      distanceImperial == false
          ? volumeWeight = calculateUnit2(volumeWeightPr)
          : volumeWeight = calculateUnit2(volumeWeightPr * 0.6214);
    }
    if (category == "r") {
      return Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              child: repsPr != 0 ? Text("Maximum reps: $reps $unit1") : null,
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              child:
                  weightPr != 0 ? Text("Maximum weight: $weight $unit2") : null,
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              child: volumeRepsPr * volumeWeightPr != 0
                  ? Text(
                      "Maximum volume: $volumeReps $unit1 x $volumeWeight $unit2 = ${num.parse(volumeReps) * num.parse(volumeWeight)} $unit2")
                  : null,
            ),
          ),
        ],
      );
    } else if (category == "b") {
      return Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              child: repsPr != 0 ? Text("Maximum reps: $reps $unit1") : null,
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              child: weightPr != 0
                  ? Text("Maximum added weight: $weight $unit2")
                  : null,
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              child: volumeRepsPr * volumeWeightPr != 0
                  ? Text(
                      "Maximum added volume: $volumeReps $unit1 x $volumeWeight $unit2 = ${num.parse(volumeReps) * num.parse(volumeWeight)} $unit2")
                  : null,
            ),
          ),
        ],
      );
    } else if (category == "a") {
      return Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              child: repsPr != 0 ? Text("Maximum reps: $reps $unit1") : null,
            ),
          ),
        ],
      );
    } else if (category == "c") {
      return Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              child: repsPr != 0 ? Text("Longest time: $reps $unit1") : null,
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              child: weightPr != 0
                  ? Text("Longest distance: $weight $unit2")
                  : null,
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              child: volumeRepsPr * volumeWeightPr != 0
                  ? Text(
                      "Fastest pace: $volumeWeight $unit2 / $volumeReps $unit1 = ${(num.parse(volumeWeight) / (volumeRepsPr / 3600)).toStringAsFixed(2)} $unit2/h")
                  : null,
            ),
          ),
        ],
      );
    } else {
      return Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              child: repsPr != 0 ? Text("Longest time: $reps $unit1") : null,
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              child: weightPr != 0
                  ? Text("Maximum added weight: $weight $unit2")
                  : null,
            ),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
          title: exName, leading: null, actions: null, context: context),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: Const.horizontalPagePadding),
        child: FadingEdgeScrollView.fromScrollView(
          child: CustomScrollView(
              controller: scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                const SliverToBoxAdapter(
                    child: Padding(padding: EdgeInsets.only(bottom: 10))),
                InAppData.exercices[exName]["description"] != null
                    ? SliverToBoxAdapter(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(bottom: 5),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Description: ",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            Align(
                                alignment: Alignment.centerLeft,
                                child: Text(InAppData.exercices[exName]
                                        ["description"] ??
                                    '')),
                            const Padding(
                              padding: EdgeInsets.only(bottom: 5),
                            ),
                          ],
                        ),
                      )
                    : SliverToBoxAdapter(child: Container()),
                //
                const SliverToBoxAdapter(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Prs: ",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                    child: Align(
                        alignment: Alignment.centerLeft, child: prText())),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(10),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "History: ",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                    child: Padding(padding: EdgeInsets.only(bottom: 5))),
                routines.isNotEmpty
                    ? SliverList.builder(
                        itemCount: routines.length,
                        itemBuilder: (context, index) {
                          routines.sort((a, b) => b["id"].compareTo(a["id"]));
                          DateTime date = DateTime.fromMillisecondsSinceEpoch(
                              routines[index]["date"]);
                          bool? imperial;
                          if (routines[index]["im"] != null) {
                            imperial = routines[index]["im"];
                          } else {
                            if (category != "c") {
                              imperial = weightImperial;
                            } else {
                              imperial = distanceImperial;
                            }
                          }

                          List units = ["reps", "kg", "", "+kg", "-kg", "km"];

                          if (imperial == true) {
                            units = [
                              "reps",
                              "lbs",
                              "",
                              "+lbs",
                              "-lbs",
                              "miles"
                            ];
                          } else {
                            units = ["reps", "kg", "", "+kg", "-kg", "km"];
                          }
                          late String unit1;
                          late String unit2;
                          if (category == "r") {
                            unit1 = units[0];
                            unit2 = units[1];
                          }
                          if (category == "b") {
                            unit1 = units[0];
                            unit2 = units[3];
                          }
                          if (category == "a") {
                            unit1 = units[0];
                            unit2 = units[4];
                          }
                          if (category == "c") {
                            unit1 = units[2];
                            unit2 = units[5];
                          }
                          if (category == "d") {
                            unit1 = units[2];
                            unit2 = units[3];
                          }
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: ListTile(
                              minVerticalPadding: 10,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              tileColor: Theme.of(context).cardColor,
                              title: Text(
                                  "${routines[index]["name"]} (${DateFormater.month(date)} ${DateFormater.day(date)}${DateFormater.year(date)}, ${DateFormater.dayOfTheWeek(date)} at ${DateFormater.hour(date).toString().padLeft(2, '0')}:${DateFormater.minute(date).toString().padLeft(2, '0')})"),
                              subtitle: ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: routines[index]["sets"]
                                    .values
                                    .toList()
                                    .length,
                                itemBuilder: (context, i) {
                                  List sets =
                                      routines[index]["sets"].values.toList();

                                  sets.sort(
                                      (a, b) => a["id"].compareTo(b["id"]));
                                  String? type = sets[i]["type"];
                                  String reps;
                                  if (sets[i]["reps"] != null) {
                                    reps = calculateUnit1(sets[i]["reps"]);
                                  } else {
                                    reps = '--';
                                  }
                                  String weight;
                                  if (sets[i]["weightinkg"] != null) {
                                    //weight = calculateUnit2(sets[i]["weightinkg"]);
                                    if (category != "c") {
                                      (imperial == false)
                                          ? weight = calculateUnit2(
                                              sets[i]["weightinkg"]) //kg
                                          : weight = calculateUnit2(sets[i]
                                                  ["weightinkg"] *
                                              2.2); //lbs
                                    } else {
                                      (imperial == false)
                                          ? weight = calculateUnit2(
                                              sets[i]["weightinkg"]) //km
                                          : weight = calculateUnit2(sets[i]
                                                  ["weightinkg"] *
                                              0.6214); //miles
                                    }
                                  } else {
                                    weight = '--';
                                  }
                                  int number = calculateNumber(sets, i);
                                  String displayNumber;
                                  type != null
                                      ? displayNumber = type
                                      : displayNumber = number.toString();
                                  print(sets);
                                  return ListTile(
                                    dense: true,
                                    title: Text(
                                        "$displayNumber: $reps $unit1 x $weight $unit2"),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      )
                    : const SliverToBoxAdapter(
                        child: Center(child: Text("Not performed yet"))),
              ]),
        ),
      ),
    );
  }
}
