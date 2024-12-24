import 'dart:convert';
import 'dart:io';

import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/const.dart';
import 'package:flutter_app/in%20app%20data.dart';
import 'package:flutter_app/widgets/custom%20appbar.dart';

import '../../services/app_media_query.dart';
import '../../services/data_update.dart';
import '../../services/user_preferences.dart';
import '../../widgets/button.dart';

class CongratsPage extends StatelessWidget {
  final int time;
  final num sets;
  final num volume;
  final String lId;
  final String assignedId;
  CongratsPage(
      {super.key,
      required this.lId,
      required this.time,
      required this.sets,
      required this.volume,
      required this.assignedId});

  ScrollController scrollController = ScrollController();

  Map? userDataMap = DataGestion.userDataMap;

  List repsPrs = [];
  List weightPrs = [];
  List volumePrs = [];

  List prExercices = [];

  bool weightImperial = DataGestion.weightImperial;
  bool distanceImperial = DataGestion.distanceImperial;

  String calculateDuration() {
    Duration duration = Duration(milliseconds: time);
    final hours = duration.inHours.remainder(60);
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    if (hours != 0) {
      return "$hours hours, $minutes minutes and $seconds seconds";
    } else if (minutes != 0) {
      return "$minutes minutes and $seconds seconds";
    } else {
      return "$seconds seconds";
    }
  }

  prs() {
    userDataMap!["logs"][lId]["exercices"].forEach((ek, ev) {
      String name = userDataMap!["logs"][lId]["exercices"][ek]["name"];
      Map oldPrs = DataGestion.oldPrs;
      int maxReps = 0;
      num maxWeight = 0;
      int maxVolumeReps = 0;
      num maxVolumeWeight = 0;

      int actualRepPr = oldPrs[name]["maxReps"] ?? 0;
      num actualWeightPr = oldPrs[name]["maxWeight"] ?? 0;
      int actualVolumeRepsPr = oldPrs[name]["maxVolumeReps"] ?? 0;
      num actualVolumeWeightPr = oldPrs[name]["maxVolumeWeight"] ?? 0;
      if (oldPrs[name] != null) {
        userDataMap!["logs"][lId]["exercices"][ek]["sets"].forEach((sk, sv) {
          int currentReps = 0;
          num currentWeight = 0;

          if (sv["reps"] != null) {
            currentReps = sv["reps"];
          }
          if (sv["weightinkg"] != null) {
            currentWeight = sv["weightinkg"];
          }
          //comparing
          if (currentReps > actualRepPr && currentReps > maxReps) {
            maxReps = currentReps;
          }
          if (currentWeight > actualWeightPr && currentWeight > maxWeight) {
            maxWeight = currentWeight;
          }
          if (currentReps * currentWeight >
                  actualVolumeRepsPr * actualVolumeWeightPr &&
              currentReps * currentWeight > maxVolumeReps * maxVolumeWeight) {
            maxVolumeReps = currentReps;
            maxVolumeWeight = currentWeight;
          }
        });
      } else {
        userDataMap!["logs"][lId]["exercices"][ek]["sets"].forEach((sk, sv) {
          sv["reps"] != null ? maxReps = sv["reps"] : maxReps = 0;
          sv["weightinkg"] != null
              ? maxWeight = sv["weightinkg"]
              : maxWeight = 0;
          if (sv["reps"] != null &&
              sv["weightinkg"] != null &&
              sv["reps"] * sv["weightinkg"] > 0) {
            maxVolumeReps = sv["reps"];
            maxVolumeWeight = sv["weightinkg"];
          }
        });
      }
      if (maxReps > 0) {
        repsPrs.add({name: maxReps});
      }
      if (maxWeight > 0) {
        weightPrs.add({name: maxWeight});
      }
      if (maxVolumeReps > 0 && maxVolumeWeight > 0) {
        volumePrs.add({
          name: {"maxVreps": maxVolumeReps, "maxVweight": maxVolumeWeight}
        });
      }
    });
  }

  exercicesWithPrs() {
    for (var element in repsPrs) {
      if (!prExercices.contains(element.keys.join())) {
        prExercices.add(element.keys.join());
      }
    }
    for (var element in weightPrs) {
      String category = InAppData.exercices[element.keys.join()]["category"];
      if (category != "a" && !prExercices.contains(element.keys.join())) {
        prExercices.add(element.keys.join());
      }
    }
    for (var element in volumePrs) {
      String category = InAppData.exercices[element.keys.join()]["category"];
      if (category != "a" &&
          category != "d" &&
          !prExercices.contains(element.keys.join())) {
        prExercices.add(element.keys.join());
      }
    }
  }

  Widget displayPrs(String nname, unit1, unit2, category, imperial) {
    String repsPr = '';
    String weightPr = '';
    String volumePr = '';
    //resistance eexs
    if (category == "r") {
      for (var element in repsPrs) {
        if (element[nname] != null) {
          repsPr =
              "Reps pr: ${calculateUnit1(element[nname], category)} $unit1";
        }
      }
      for (var element in weightPrs) {
        if (element[nname] != null) {
          weightPr =
              "weight pr: ${calculateUnit2(element[nname], category, imperial)} $unit2";
        }
      }
      for (var element in volumePrs) {
        if (element[nname] != null) {
          volumePr =
              "volume pr: ${calculateUnit1(element[nname]["maxVreps"], category)} $unit1 x ${calculateUnit2(element[nname]["maxVweight"], category, imperial)} $unit2 = ${element[nname]["maxVreps"] * num.parse(calculateUnit2(element[nname]["maxVweight"], category, imperial))} $unit2";
        }
      }
    }
    //bodyweight exs
    if (category == "b") {
      for (var element in repsPrs) {
        if (element[nname] != null) {
          repsPr =
              "Reps pr: ${calculateUnit1(element[nname], category)} $unit1";
        }
      }
      for (var element in weightPrs) {
        if (element[nname] != null) {
          weightPr =
              "added weight pr: ${calculateUnit2(element[nname], category, imperial)} $unit2";
        }
      }
      for (var element in volumePrs) {
        if (element[nname] != null) {
          volumePr =
              "added volume pr: ${calculateUnit1(element[nname]["maxVreps"], category)} $unit1 x ${calculateUnit2(element[nname]["maxVweight"], category, imperial)} $unit2 = ${element[nname]["maxVreps"] * num.parse(calculateUnit2(element[nname]["maxVweight"], category, imperial))} $unit2";
        }
      }
    }
    //assisted bodyweight
    if (category == "a") {
      for (var element in repsPrs) {
        if (element[nname] != null) {
          repsPr =
              "Reps pr: ${calculateUnit1(element[nname], category)} $unit1";
        }
      }
    }
    //cardio
    if (category == "c") {
      for (var element in repsPrs) {
        if (element[nname] != null) {
          repsPr =
              "longest time pr: ${calculateUnit1(element[nname], category)}";
        }
      }
      for (var element in weightPrs) {
        if (element[nname] != null) {
          weightPr =
              "distance pr: ${calculateUnit2(element[nname], category, imperial)} $unit2";
        }
      }
      for (var element in volumePrs) {
        if (element[nname] != null) {
          volumePr =
              "pace pr: ${calculateUnit2(element[nname]["maxVweight"], category, imperial)} $unit2 / ${calculateUnit1(element[nname]["maxVreps"], category)} $unit1 = ${(num.parse(calculateUnit2(element[nname]["maxVweight"], category, imperial)) / (element[nname]["maxVreps"] / 3600)).toStringAsFixed(2)} $unit2/h"; //= ${element[nname]["maxVreps"] * element[nname]["maxVweight"]} $unit2";
        }
      }
    }
    //duration
    if (category == "d") {
      for (var element in repsPrs) {
        if (element[nname] != null) {
          repsPr =
              "longest duration pr: ${calculateUnit1(element[nname], category)}";
        }
      }
      for (var element in weightPrs) {
        if (element[nname] != null) {
          weightPr =
              "added weight pr: ${calculateUnit2(element[nname], category, imperial)} $unit2";
        }
      }
    }

    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            child: repsPr != '' ? Text(repsPr) : null,
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            child: weightPr != '' ? Text(weightPr) : null,
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            child: volumePr != '' ? Text(volumePr) : null,
          ),
        ),
      ],
    );
  }

  String calculateUnit2(num value, category, imperial) {
    RegExp dec = RegExp(r'^([0-9]?)+([\.][0-9]+)$');
    RegExp oneDec = RegExp(r'^([0-9]?)+([\.][0-9])$');
    RegExp zeros = RegExp(r'^([0-9]?)+([\.][0][0]?)$');

    num val = 0;

    if (category != "c") {
      (imperial == false)
          ? val = value //kg
          : val = value * 2.2; //lbs
    } else {
      (imperial == false)
          ? val = value //km
          : val = value * 0.6214; //miles
    }

    if (dec.hasMatch(val.toString())) {
      double number = double.parse(val.toStringAsFixed(2));
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

  String calculateUnit1(reps, category) {
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

  String calculateVolume(num volume) {
    if (weightImperial == false) {
      return "$volume kg";
    } else {
      return "${(volume * 2.2).toStringAsFixed(1)} lbs";
    }
  }

  saveAsNewTemplate(context) {
    String name = userDataMap!["logs"][lId]["name"];
    int date = userDataMap!["logs"][lId]["tdate"];
    Map? exercices =
        json.decode(json.encode(userDataMap!["logs"][lId]["exercices"]));

    if (userDataMap != null && userDataMap!["routines"] != null) {
      userDataMap!["routines"].addAll({
        lId: {"exercices": exercices, "id": lId, "lastperf": date, "name": name}
      });
    } else {
      userDataMap!["routines"] = {
        lId: {"exercices": exercices, "id": lId, "lastperf": date, "name": name}
      };
    }
    DataGestion.userDataMap = userDataMap;
    UserPreferences.saveUserDataMap(json.encode(DataGestion.userDataMap));
    Navigator.pop(context);
    DataGestion.userDataMapCopy =
        json.decode(json.encode(DataGestion.userDataMap));
    UserPreferences.saveLogInProgressMap(
        json.encode(DataGestion.userDataMapCopy));
  }

  updateRoutine(context) {
    String name = userDataMap!["logs"][lId]["name"];
    Map? exercices =
        json.decode(json.encode(userDataMap!["logs"][lId]["exercices"]));
    userDataMap!["routines"][assignedId]["name"] = name;
    userDataMap!["routines"][assignedId]["exercices"] = exercices;
    UserPreferences.saveUserDataMap(json.encode(DataGestion.userDataMap));
    Navigator.pop(context);
    DataGestion.userDataMapCopy =
        json.decode(json.encode(DataGestion.userDataMap));
    UserPreferences.saveLogInProgressMap(
        json.encode(DataGestion.userDataMapCopy));
  }

  exitWithoutSaving(context) {
    Navigator.pop(context);
    DataGestion.userDataMapCopy =
        json.decode(json.encode(DataGestion.userDataMap));
    UserPreferences.saveLogInProgressMap(
        json.encode(DataGestion.userDataMapCopy));
  }

  @override
  Widget build(BuildContext context) {
    calculateDuration();
    prs();
    exercicesWithPrs();
    return Scaffold(
      appBar: customAppBar(
          title: 'Routine finished',
          leading: null,
          actions: null,
          context: context),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: Const.horizontalPagePadding),
        child: Column(
          children: [
            const Padding(padding: EdgeInsets.only(bottom: 20)),
            Text(
              "Congratulations!".toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
            const Padding(padding: EdgeInsets.only(bottom: 10)),
            Text(
              '''You worked out for: ${calculateDuration()}, accomplished $sets sets with a total volume of: ${calculateVolume(volume)}''',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
              ),
            ),
            const Padding(padding: EdgeInsets.only(bottom: 15)),
            prExercices.isNotEmpty
                ? const Text(
                    "Acheived prs: ",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : const Text(''),
            const Padding(padding: EdgeInsets.only(bottom: 10)),
            Expanded(
              child: FadingEdgeScrollView.fromScrollView(
                child: ListView.builder(
                    controller: scrollController,
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: prExercices.length,
                    itemBuilder: (context, i) {
                      String category =
                          InAppData.exercices[prExercices[i]]["category"];
                      bool? imperial;
                      if (category != "c") {
                        imperial = weightImperial;
                      } else {
                        imperial = distanceImperial;
                      }

                      List units = ["reps", "kg", "time", "+kg", "-kg", "km"];

                      if (imperial == true) {
                        units = [
                          "reps",
                          "lbs",
                          "time",
                          "+lbs",
                          "-lbs",
                          "miles"
                        ];
                      } else {
                        units = ["reps", "kg", "time", "+kg", "-kg", "km"];
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
                      String? imagePath =
                          InAppData.exercices[prExercices[i]]["image"];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          minVerticalPadding: 10,
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
                                      prExercices[i][0].toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                          title: Text(
                            prExercices[i],
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                          subtitle: displayPrs(
                              prExercices[i], unit1, unit2, category, imperial),
                        ),
                      );
                    }),
              ),
            ),
            const Padding(padding: EdgeInsets.only(bottom: 5)),
            Center(
              child: button(
                  height: 45,
                  color: Theme.of(context).primaryColor,
                  context: context,
                  onPressed: () {
                    saveAsNewTemplate(context);
                  },
                  text: 'Save as new template'),
            ),
            Center(
              child: userDataMap!["routines"][assignedId] != null
                  ? button(
                      height: 45,
                      context: context,
                      onPressed: () {
                        updateRoutine(context);
                      },
                      text: 'Update existing routine')
                  : null,
            ),
            const Padding(padding: EdgeInsets.only(bottom: 5)),
            TextButton(
                style: TextButton.styleFrom(
                  //backgroundColor: Colors.red,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  minimumSize: Size.zero,
                ),
                onPressed: () {
                  exitWithoutSaving(context);
                },
                child: const Text("Exit without saving")),
            Padding(
                padding: EdgeInsets.only(
                    bottom: AppMediaQuerry.mq.padding.bottom + 13)),
          ],
        ),
      ),
    );
  }
}
