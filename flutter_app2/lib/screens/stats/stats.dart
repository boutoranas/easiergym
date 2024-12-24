import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/const.dart';
import 'package:flutter_app/in%20app%20data.dart';
import 'package:flutter_app/screens/stats/exercice%20choice%20in%20stats.dart';
import 'package:flutter_app/services/date%20formater.dart';
import 'package:flutter_app/widgets/custom%20appbar.dart';

import '../../main.dart';
import '../../services/data_update.dart';
import '../../widgets/resume workout bar.dart';
import 'measurements page.dart';

class StatsSection extends StatefulWidget {
  final Function expandWhenWk;
  final bool workoutInProg;
  const StatsSection(
      {super.key, required this.expandWhenWk, required this.workoutInProg});

  @override
  State<StatsSection> createState() => _StatsSectionState();
}

class _StatsSectionState extends State<StatsSection> with RouteAware {
  final routineInputController = TextEditingController();

  final userID = FirebaseAuth.instance.currentUser!.uid;
  late DatabaseReference database =
      FirebaseDatabase.instance.ref().child("users").child(userID);

  late DatabaseReference ref = FirebaseDatabase.instance
      .ref()
      .child("users")
      .child(userID)
      .child("easiergym")
      .child("measurements");

  @override
  void didChangeDependencies() {
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() async {
    //await ref.set(userDataMap!["measurements"]);
    setState(() {});
    super.didPopNext();
  }

  Map? userDataMap = DataGestion.userDataMap;
  List<GraphPoint> data = [];

  double? minX = 0;
  double? maxX = 10;
  double? minY = 0;
  double? maxY = 100;

  int daysSinceEpoch(int msSinceEpoch) {
    DateTime datenow = DateTime.fromMillisecondsSinceEpoch(msSinceEpoch);
    Duration date = Duration(
        milliseconds: msSinceEpoch + datenow.timeZoneOffset.inMilliseconds);
    return date.inDays;
  }

  kFormat(String value) {
    if (num.parse(value) >= 10000) {
      //return "${(num.parse(value) / 1000).toStringAsFixed(1)}K";
      if ((num.parse(value) / 1000).toStringAsFixed(1).length < 5) {
        return "${(num.parse(value) / 1000).toStringAsFixed(1)}K";
      } else {
        return "${(num.parse(value) / 1000).toStringAsFixed(0)}K";
      }
    } else {
      /* if (num.parse(value) == num.parse(value).toInt()) {
        return num.parse(value).toStringAsFixed(0);
      } else {
        return "o";
      } */
      return num.parse(value).toStringAsFixed(0);
    }
  }

  String determineDecimals(num val) {
    RegExp dec = RegExp(r'^([0-9]?)+([\.][0-9]+)$');
    RegExp oneDec = RegExp(r'^([0-9]?)+([\.][0-9])$');
    RegExp zeros = RegExp(r'^([0-9]?)+([\.][0][0]?)$');

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

  getGraphPoints(int timespan, Map? dataMap, String ttype) {
    data = [];
    if (ttype == "measurements") {
      List dataList = [];
      List timeSpanValues = [];

      if (dataMap != null) {
        dataList = dataMap.values.toList();
      }
      dataList.sort((a, b) => a["date"].compareTo(b["date"]));
      for (var element in dataList) {
        num value;

        if (selectedBlock == "body weight") {
          weightImperial == false
              ? value = element["value"]
              : value = element["value"] * 2.2;
        } else if (selectedBlock == "body fat") {
          value = element["value"];
        } else if (selectedBlock == "calories") {
          value = element["value"];
        } else {
          sizeImperial == false
              ? value = element["value"]
              : value = element["value"] * 0.394;
        }
        /* Duration dateNow =
            Duration(milliseconds: DateTime.now().millisecondsSinceEpoch);
        Duration dateOfElement = Duration(milliseconds: element["date"]); */
        /* if (daysSinceEpoch(DateTime.now().millisecondsSinceEpoch) -
                daysSinceEpoch(element["date"]) <=
            5 * timespan) { */
        data.add(GraphPoint(
            x: double.parse(daysSinceEpoch(element["date"]).toString()),
            y: double.parse((value).toString())));
        //}
        //print(daysSinceEpoch(DateTime.now().millisecondsSinceEpoch));
      }
      data.sort(((a, b) => a.x.compareTo(b.x)));
      maxX = daysSinceEpoch(DateTime.now().millisecondsSinceEpoch).toDouble();
      minX = daysSinceEpoch(DateTime.now().millisecondsSinceEpoch).toDouble() -
          timespan;

      for (var element in dataList) {
        if (daysSinceEpoch(DateTime.now().millisecondsSinceEpoch) -
                daysSinceEpoch(element["date"]) <=
            timespan) {
          num value;

          if (selectedBlock == "body weight") {
            weightImperial == false
                ? value = element["value"]
                : value = element["value"] * 2.2;
          } else if (selectedBlock == "body fat") {
            value = element["value"];
          } else if (selectedBlock == "calories") {
            value = element["value"];
          } else {
            sizeImperial == false
                ? value = element["value"]
                : value = element["value"] * 0.394;
          }
          timeSpanValues.add(value);
        }
      }
      //dataList.sort((a, b) => a["value"].compareTo(b["value"]));
      timeSpanValues.sort((a, b) => a.compareTo(b));

      if (timeSpanValues.isNotEmpty) {
        minY = timeSpanValues[0] - (1 / 10) * timeSpanValues[0];
        maxY = timeSpanValues[timeSpanValues.length - 1] +
            (1 / 10) * timeSpanValues[timeSpanValues.length - 1] +
            5;
      }

      /* if (dataList.isNotEmpty) {
        minY = dataList[0]["value"] - (1 / 10) * dataList[0]["value"];
        maxY = dataList[dataList.length - 1]["value"] +
            (1 / 10) * dataList[dataList.length - 1]["value"] +
            5;
      } */
      setState(() {});
    }
    //
    else if (ttype == "perfsreps") {
      List repsList = [];
      List timeSpanValues = [];
      dataMap!["history"].forEach((hk, hv) {
        int bestRep = 0;
        hv["sets"].forEach((sk, sv) {
          if (sv["reps"] != null && sv["reps"] > bestRep) {
            bestRep = sv["reps"];
          }
        });
        data.add(GraphPoint(
            x: daysSinceEpoch(hv["date"]).toDouble(), y: bestRep.toDouble()));

        repsList.add({"date": hv["date"], "value": bestRep});
      });
      data.sort(((a, b) => a.x.compareTo(b.x)));
      maxX = daysSinceEpoch(DateTime.now().millisecondsSinceEpoch).toDouble();
      minX = daysSinceEpoch(DateTime.now().millisecondsSinceEpoch).toDouble() -
          timespan;

      for (var element in repsList) {
        if (daysSinceEpoch(DateTime.now().millisecondsSinceEpoch) -
                daysSinceEpoch(element["date"]) <=
            timespan) {
          timeSpanValues.add(element["value"]);
        }
      }

      timeSpanValues.sort((a, b) => a.compareTo(b));

      if (timeSpanValues.isNotEmpty) {
        minY = timeSpanValues[0] - (1 / 10) * timeSpanValues[0];
        maxY = timeSpanValues[timeSpanValues.length - 1] +
            (1 / 10) * timeSpanValues[timeSpanValues.length - 1] +
            5;
      }

      /* repsList.sort((a, b) => a.compareTo(b));

      if (repsList.isNotEmpty) {
        minY = repsList[0] - (1 / 10) * repsList[0];
        maxY = repsList[repsList.length - 1] +
            (1 / 10) * repsList[repsList.length - 1] +
            2;
      } */
      setState(() {});
    }
    //
    else if (ttype == "perfsweight") {
      List weightList = [];
      List timeSpanValues = [];
      dataMap!["history"].forEach((hk, hv) {
        num bestWeight = 0;
        hv["sets"].forEach((sk, sv) {
          if (sv["weightinkg"] != null && sv["weightinkg"] > bestWeight) {
            if (category != "c") {
              (weightImperial == false)
                  ? bestWeight = sv["weightinkg"] //kg
                  : bestWeight = sv["weightinkg"] * 2.2; //lbs
            } else {
              (distanceImperial == false)
                  ? bestWeight = sv["weightinkg"] //km
                  : bestWeight = sv["weightinkg"] * 0.6214; //miles
            }
            //bestWeight = sv["weightinkg"];
          }
        });
        data.add(GraphPoint(
            x: daysSinceEpoch(hv["date"]).toDouble(),
            y: bestWeight.toDouble()));
        weightList.add({"date": hv["date"], "value": bestWeight});
      });
      data.sort(((a, b) => a.x.compareTo(b.x)));
      maxX = daysSinceEpoch(DateTime.now().millisecondsSinceEpoch).toDouble();
      minX = daysSinceEpoch(DateTime.now().millisecondsSinceEpoch).toDouble() -
          timespan;

      for (var element in weightList) {
        if (daysSinceEpoch(DateTime.now().millisecondsSinceEpoch) -
                daysSinceEpoch(element["date"]) <=
            timespan) {
          timeSpanValues.add(element["value"]);
        }
      }

      timeSpanValues.sort((a, b) => a.compareTo(b));

      if (timeSpanValues.isNotEmpty) {
        minY = timeSpanValues[0] - (1 / 10) * timeSpanValues[0];
        maxY = timeSpanValues[timeSpanValues.length - 1] +
            (1 / 10) * timeSpanValues[timeSpanValues.length - 1] +
            5;
      }

      /* weightList.sort((a, b) => a.compareTo(b));
      if (weightList.isNotEmpty) {
        minY = weightList[0] - (1 / 10) * weightList[0];
        maxY = weightList[weightList.length - 1] +
            (1 / 10) * weightList[weightList.length - 1] +
            2;
      } */
      setState(() {});
    }
    //
    else if (ttype == "perfsvolume") {
      List volumeList = [];
      List timeSpanValues = [];
      dataMap!["history"].forEach((hk, hv) {
        if (category != "c") {
          num bestVolume = 0;
          hv["sets"].forEach((sk, sv) {
            if (sv["reps"] != null &&
                sv["weightinkg"] != null &&
                sv["reps"] * sv["weightinkg"] > bestVolume) {
              (weightImperial == false)
                  ? bestVolume = sv["reps"] * sv["weightinkg"] //kg
                  : bestVolume = sv["reps"] * sv["weightinkg"] * 2.2; //lbs

              //bestVolume = sv["reps"] * sv["weightinkg"];
            }
          });
          data.add(GraphPoint(
              x: daysSinceEpoch(hv["date"]).toDouble(),
              y: bestVolume.toDouble()));
          volumeList.add({"date": hv["date"], "value": bestVolume});
        } else {
          num bestPace = 0;
          hv["sets"].forEach((sk, sv) {
            if (sv["reps"] != null &&
                sv["reps"] != 0 &&
                sv["weightinkg"] != null &&
                sv["weightinkg"] / sv["reps"] > bestPace) {
              (distanceImperial == false)
                  ? bestPace = sv["weightinkg"] / (sv["reps"] / 3600) //km
                  : bestPace =
                      sv["weightinkg"] / (sv["reps"] / 3600) * 0.6214; //miles

              //bestPace = sv["weightinkg"] / sv["reps"];
            }
          });
          data.add(GraphPoint(
              x: daysSinceEpoch(hv["date"]).toDouble(),
              y: bestPace.toDouble()));
          volumeList.add({"date": hv["date"], "value": bestPace});
        }
      });

      data.sort(((a, b) => a.x.compareTo(b.x)));
      maxX = daysSinceEpoch(DateTime.now().millisecondsSinceEpoch).toDouble();
      minX = daysSinceEpoch(DateTime.now().millisecondsSinceEpoch).toDouble() -
          timespan;

      for (var element in volumeList) {
        if (daysSinceEpoch(DateTime.now().millisecondsSinceEpoch) -
                daysSinceEpoch(element["date"]) <=
            timespan) {
          timeSpanValues.add(element["value"]);
        }
      }

      timeSpanValues.sort((a, b) => a.compareTo(b));

      if (timeSpanValues.isNotEmpty) {
        minY = timeSpanValues[0] - (1 / 10) * timeSpanValues[0];
        maxY = timeSpanValues[timeSpanValues.length - 1] +
            (1 / 10) * timeSpanValues[timeSpanValues.length - 1] +
            5;
      }

      setState(() {});
    }
    //
    else if (ttype == "perfssets") {
      List setsList = [];
      List timeSpanValues = [];
      dataMap!["history"].forEach((hk, hv) {
        int setLength = hv["sets"].length;

        data.add(GraphPoint(
            x: daysSinceEpoch(hv["date"]).toDouble(), y: setLength.toDouble()));
        setsList.add({"date": hv["date"], "value": setLength});
      });

      data.sort(((a, b) => a.x.compareTo(b.x)));
      maxX = daysSinceEpoch(DateTime.now().millisecondsSinceEpoch).toDouble();
      minX = daysSinceEpoch(DateTime.now().millisecondsSinceEpoch).toDouble() -
          timespan;

      for (var element in setsList) {
        if (daysSinceEpoch(DateTime.now().millisecondsSinceEpoch) -
                daysSinceEpoch(element["date"]) <=
            timespan) {
          timeSpanValues.add(element["value"]);
        }
      }

      timeSpanValues.sort((a, b) => a.compareTo(b));

      if (timeSpanValues.isNotEmpty) {
        minY = 0; //timeSpanValues[0] - (1 / 10) * timeSpanValues[0];
        maxY = timeSpanValues[timeSpanValues.length - 1] +
            (1 / 10) * timeSpanValues[timeSpanValues.length - 1] +
            2;
      }

      setState(() {});
    }
  }

  daysToMonth(int days) {
    DateTime date =
        DateTime.fromMillisecondsSinceEpoch(days * 24 * 3600 * 1000);
    if (DateTime.now().year == date.year) {
      return "${date.month}/${date.day}";
    } else {
      return "${date.month}/${date.day}";
    }
  }

  dayOfTheWeekOfDay(int day) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(day * 24 * 3600 * 1000);
    return "${DateFormater.dayOfTheWeek(date)[0].toUpperCase()}${DateFormater.dayOfTheWeek(date)[1]}${DateFormater.dayOfTheWeek(date)[2]}";
  }

  yearOfDay(int day) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(day * 24 * 3600 * 1000);
    return "${date.year}";
  }

  getTitlesData(timeSpan) {
    return SideTitles(
      interval: 1,
      showTitles: true,
      getTitlesWidget: (value, meta) {
        if (timeSpan == 30) {
          if (value == maxX) {
            return Text(daysToMonth(maxX!.toInt()));
          } else if (value == maxX! - 5) {
            return Text(daysToMonth(maxX!.toInt() - 5));
          } else if (value == maxX! - 10) {
            return Text(daysToMonth(maxX!.toInt() - 10));
          } else if (value == maxX! - 15) {
            return Text(daysToMonth(maxX!.toInt() - 15));
          } else if (value == maxX! - 20) {
            return Text(daysToMonth(maxX!.toInt() - 20));
          } else if (value == maxX! - 25) {
            return Text(daysToMonth(maxX!.toInt() - 25));
          } else if (value == maxX! - 30) {
            return Text(daysToMonth(maxX!.toInt() - 30));
          } else {
            return const Text('');
          }
        } else if (timeSpan == 6) {
          if (value == maxX) {
            return Text(dayOfTheWeekOfDay(maxX!.toInt()));
          } else if (value == maxX! - 1) {
            return Text(dayOfTheWeekOfDay(maxX!.toInt() - 1));
          } else if (value == maxX! - 2) {
            return Text(dayOfTheWeekOfDay(maxX!.toInt() - 2));
          } else if (value == maxX! - 3) {
            return Text(dayOfTheWeekOfDay(maxX!.toInt() - 3));
          } else if (value == maxX! - 4) {
            return Text(dayOfTheWeekOfDay(maxX!.toInt() - 4));
          } else if (value == maxX! - 5) {
            return Text(dayOfTheWeekOfDay(maxX!.toInt() - 5));
          } else if (value == maxX! - 6) {
            return Text(dayOfTheWeekOfDay(maxX!.toInt() - 6));
          } else {
            return const Text('');
          }
        } else if (timeSpan == 90) {
          if (value == maxX) {
            return Text(daysToMonth(maxX!.toInt()));
          } else if (value == maxX! - 15) {
            return Text(daysToMonth(maxX!.toInt() - 15));
          } else if (value == maxX! - 30) {
            return Text(daysToMonth(maxX!.toInt() - 30));
          } else if (value == maxX! - 45) {
            return Text(daysToMonth(maxX!.toInt() - 45));
          } else if (value == maxX! - 60) {
            return Text(daysToMonth(maxX!.toInt() - 60));
          } else if (value == maxX! - 75) {
            return Text(daysToMonth(maxX!.toInt() - 75));
          } else if (value == maxX! - 90) {
            return Text(daysToMonth(maxX!.toInt() - 90));
          } else {
            return const Text('');
          }
        } else if (timeSpan == 365) {
          if (value == maxX) {
            return Text(daysToMonth(maxX!.toInt()));
          } else if (value == maxX! - 73) {
            return Text(daysToMonth(maxX!.toInt() - 73));
          } else if (value == maxX! - 146) {
            return Text(daysToMonth(maxX!.toInt() - 146));
          } else if (value == maxX! - 219) {
            return Text(daysToMonth(maxX!.toInt() - 219));
          } else if (value == maxX! - 292) {
            return Text(daysToMonth(maxX!.toInt() - 292));
          } else if (value == maxX! - 365) {
            return Text(daysToMonth(maxX!.toInt() - 365));
          } else {
            return const Text('');
          }
        } else if (timeSpan == 1825) {
          if (value == maxX) {
            return Text(yearOfDay(maxX!.toInt()));
          } else if (value == maxX! - 365) {
            return Text(yearOfDay(maxX!.toInt() - 365));
          } else if (value == maxX! - 730) {
            return Text(yearOfDay(maxX!.toInt() - 730));
          } else if (value == maxX! - 1095) {
            return Text(yearOfDay(maxX!.toInt() - 1095));
          } else if (value == maxX! - 1460) {
            return Text(yearOfDay(maxX!.toInt() - 1460));
          } else if (value == maxX! - 1825) {
            return Text(yearOfDay(maxX!.toInt() - 1825));
          } else {
            return const Text('');
          }
        } else {
          return const Text('');
        }
      },
    );
  }

  chooseExercice(chosenExercice) {
    setState(() {
      type = "perfsreps";
      DataGestion.type = type;
      selectedBlock = "reps";
      DataGestion.selectedBlock = selectedBlock;
      exercice = chosenExercice;
      DataGestion.exercice = exercice;
      mapOfData = DataGestion.exsHistory[exercice];
    });
  }

  String text1 = "Reps";
  String text2 = "Weight";
  String text3 = "Volume";

  containerTexts(category) {
    if (category == "r") {
      text1 = "Reps";
      text2 = "Weight";
      text3 = "Volume";
    }
    if (category == "b") {
      text1 = "Reps";
      text2 = "+ Weight";
      text3 = "+ Volume";
    }
    if (category == "a") {
      text1 = "Reps";
      text2 = "";
      text3 = "";
    }
    if (category == "c") {
      text1 = "Time";
      text2 = "Distance";
      text3 = "Pace";
    }
    if (category == "d") {
      text1 = "Time";
      text2 = "+ Weight";
      text3 = "";
    }
  }

  String calculateUnit2(num val, category) {
    RegExp dec = RegExp(r'^([0-9]?)+([\.][0-9]+)$');
    RegExp oneDec = RegExp(r'^([0-9]?)+([\.][0-9])$');
    RegExp zeros = RegExp(r'^([0-9]?)+([\.][0][0]?)$');

    /* num val = 0;

    if (category != "c") {
      (imperial == false)
          ? val = value //kg
          : val = value * 2.2; //lbs
    } else {
      (imperial == false)
          ? val = value //km
          : val = value * 0.6214; //miles
    } */

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

  Widget displayText(value) {
    if (value == value.toInt()) {
      if (type == "perfsreps") {
        if (category == "c" || category == "d") {
          return Text(
            calculateUnit1(value.toInt(), category),
            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
          );
        } else {
          return Text(kFormat(calculateUnit1(value.toInt(), category)));
        }
      } else if (type == "perfsweight") {
        return Text(kFormat(calculateUnit2(value, category)));
      } else if (type == "perfsvolume") {
        return Text(kFormat(calculateUnit2(value, category)));
      } else {
        return Text(kFormat(value.toString()));
      }
    } else {
      return const Text("");
    }
  }

  updateMap() {
    if (selectedBlock == "body weight") {
      setState(() {
        if (userDataMap != null && userDataMap!["measurements"] != null) {
          mapOfData = userDataMap!["measurements"]["body weight"];
        } else {
          mapOfData = null;
        }
      });
    } else if (selectedBlock == "body fat") {
      setState(() {
        if (userDataMap != null && userDataMap!["measurements"] != null) {
          mapOfData = userDataMap!["measurements"]["body fat"];
        } else {
          mapOfData = null;
        }
      });
    } else if (selectedBlock == "calories") {
      setState(() {
        if (userDataMap != null && userDataMap!["measurements"] != null) {
          mapOfData = userDataMap!["measurements"]["calories"];
        } else {
          mapOfData = null;
        }
      });
    } else if (selectedBlock == "body parts") {
      setState(() {
        if (userDataMap != null &&
            userDataMap!["measurements"] != null &&
            userDataMap!["measurements"]["body parts"] != null) {
          mapOfData =
              userDataMap!["measurements"]["body parts"][selectedBodyPart];
        } else {
          mapOfData = null;
        }
      });
    } else {
      setState(() {
        mapOfData = DataGestion.exsHistory[exercice];
      });
    }
  }

  //bool imperial = false;
  bool weightImperial = DataGestion.weightImperial;
  bool distanceImperial = DataGestion.distanceImperial;
  bool sizeImperial = DataGestion.sizeImperial;

  List units = ["reps", "kg", "time", "+kg", "-kg", "km"];
  late String unit1;
  late String unit2;

  int timeSpan = DataGestion.timeSpan;
  String type = DataGestion.type;
  Map? mapOfData = DataGestion.mapOfData;
  bool bodyParts = DataGestion.bodyParts;
  String selectedBodyPart = DataGestion.selectedBodyPart;
  String exercice = DataGestion.exercice;
  String selectedBlock = DataGestion.selectedBlock;

  late String category = InAppData.exercices[exercice]["category"];

  @override
  void initState() {
    if (mapOfData != null &&
        mapOfData!.isEmpty &&
        userDataMap != null &&
        userDataMap!["measurements"] != null) {
      mapOfData = userDataMap!["measurements"]["body weight"];
    }
    DataGestion.mapOfData = mapOfData;

    associateUnits();
    super.initState();
  }

  Widget card({
    required String text,
    required Function onTap,
    required String cardBlock,
    String? bp,
  }) {
    return Card(
      margin: const EdgeInsets.all(4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: cardBlock == selectedBlock
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).cardColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          onTap();
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
          width: ((MediaQuery.of(context).size.width -
                  (Const.horizontalPagePadding) -
                  32) /
              4),
          height: MediaQuery.of(context).size.height,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                    child: Text(
                  text,
                  textAlign: TextAlign.center,
                )),
                bp != null ? Text(selectedBodyPart) : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget controlButtons({
    required List<PopupMenuEntry<dynamic>> Function(BuildContext)? itemBuilder,
    required Color color,
    required String title,
    required bool popup,
    required Function? onTap,
    required void Function(dynamic)? onSelected,
    IconData? icon,
  }) {
    if (popup == true) {
      return PopupMenuButton(
        itemBuilder: itemBuilder!,
        onSelected: onSelected,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: color,
          ),
          margin: const EdgeInsets.all(5),
          height: 21,
          width: 85,
          child: Center(
              child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title),
              icon != null
                  ? Icon(
                      icon,
                      size: 15,
                    )
                  : Container(),
            ],
          )),
        ),
      );
    } else {
      return InkWell(
        onTap: () {
          onTap!();
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: color,
          ),
          margin: const EdgeInsets.all(5),
          height: 21,
          width: 85,
          child: Center(
              child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title),
              icon != null
                  ? Icon(
                      icon,
                      size: 15,
                    )
                  : Container(),
            ],
          )),
        ),
      );
    }
  }

  String displayUnit() {
    if (selectedBlock == 'body weight') {
      return weightUnit;
    } else if (selectedBlock == 'body fat') {
      return '%';
    } else if (selectedBlock == 'calories') {
      return 'kcal';
    } else if (selectedBlock == 'body parts') {
      return sizeUnit;
    } else if (selectedBlock == 'reps') {
      return '';
    } else if (selectedBlock == 'weight') {
      return unit2;
    } else if (selectedBlock == 'volume') {
      if (category != 'c') {
        return unit2;
      } else {
        return '$unit2/h';
      }
    } else if (selectedBlock == 'sets') {
      return '';
    } else {
      return 'error';
    }
  }

  associateUnits() {
    if (weightImperial == true) {
      units[1] = "lbs";
      units[3] = "+lbs";
      units[4] = "-lbs";
    }
    if (distanceImperial == true) {
      units[5] = "miles";
    }
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
  }

  String weightUnit = "kg";
  String distanceUnit = "km";
  String sizeUnit = "cm";

  @override
  Widget build(BuildContext context) {
    //
    if (DataGestion.weightImperial == true) {
      weightUnit = "lbs";
    }
    if (DataGestion.distanceImperial == true) {
      distanceUnit = "miles";
    }
    if (DataGestion.sizeImperial == true) {
      sizeUnit = "in";
    }
    associateUnits();
    //
    DataGestion.type = type;
    DataGestion.mapOfData = mapOfData;
    DataGestion.bodyParts = bodyParts;
    DataGestion.selectedBodyPart = selectedBodyPart;
    DataGestion.exercice = exercice;
    DataGestion.selectedBlock = selectedBlock;
    category = InAppData.exercices[exercice]["category"];

    updateMap();
    containerTexts(category);
    getGraphPoints(timeSpan, mapOfData, type);
    return Scaffold(
      appBar: customAppBar(
          title: 'Statistics', leading: null, actions: null, context: context),
      body: Padding(
        padding: EdgeInsets
            .zero, //EdgeInsets.symmetric(horizontal: Const.horizontalPagePadding),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: Const.horizontalPagePadding / 2),
              child: Column(
                children: [
                  const Padding(padding: EdgeInsets.only(bottom: 5)),
                  Container(
                    height: 30,
                    child: const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Mesurements:",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        )),
                  ),
                  Container(
                    height: 80,
                    child: Row(
                      children: [
                        card(
                            cardBlock: "body weight",
                            text: 'Bodyweight',
                            onTap: () {
                              setState(() {
                                type = "measurements";
                                DataGestion.type = type;
                                bodyParts = false;
                                if (userDataMap != null &&
                                    userDataMap!["measurements"] != null) {
                                  mapOfData = userDataMap!["measurements"]
                                      ["body weight"];
                                } else {
                                  mapOfData = null;
                                }
                                selectedBlock = "body weight";
                              });
                            }),
                        card(
                          cardBlock: "body fat",
                          text: 'Bodyfat',
                          onTap: () {
                            setState(() {
                              type = "measurements";
                              DataGestion.type = type;
                              bodyParts = false;
                              if (userDataMap != null &&
                                  userDataMap!["measurements"] != null) {
                                mapOfData =
                                    userDataMap!["measurements"]["body fat"];
                              } else {
                                mapOfData = null;
                              }
                              selectedBlock = "body fat";
                            });
                          },
                        ),
                        card(
                          cardBlock: "calories",
                          text: 'Calories',
                          onTap: () {
                            setState(() {
                              type = "measurements";
                              DataGestion.type = type;
                              bodyParts = false;
                              if (userDataMap != null &&
                                  userDataMap!["measurements"] != null) {
                                mapOfData =
                                    userDataMap!["measurements"]["calories"];
                              } else {
                                mapOfData = null;
                              }
                              selectedBlock = "calories";
                            });
                          },
                        ),
                        card(
                          bp: selectedBodyPart,
                          cardBlock: "body parts",
                          text: 'Body parts:',
                          onTap: () {
                            setState(() {
                              type = "measurements";
                              DataGestion.type = type;
                              bodyParts = true;
                              if (userDataMap != null &&
                                  userDataMap!["measurements"] != null &&
                                  userDataMap!["measurements"]["body parts"] !=
                                      null) {
                                mapOfData = userDataMap!["measurements"]
                                    ["body parts"][selectedBodyPart];
                              } else {
                                mapOfData = null;
                              }
                              selectedBlock = "body parts";
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const Padding(padding: EdgeInsets.only(bottom: 5)),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Performance ($exercice):",
                          maxLines: 2,
                          style: const TextStyle(
                            overflow: TextOverflow.ellipsis,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        )),
                  ),
                  Container(
                    height: 80,
                    child: Row(
                      children: [
                        card(
                          cardBlock: "reps",
                          text: text1,
                          onTap: () {
                            setState(() {
                              type = "perfsreps";
                              DataGestion.type = type;
                              bodyParts = false;

                              mapOfData = DataGestion.exsHistory[exercice];
                              selectedBlock = "reps";
                            });
                          },
                        ),
                        category != "a"
                            ? card(
                                cardBlock: "weight",
                                text: text2,
                                onTap: () {
                                  setState(() {
                                    type = "perfsweight";
                                    DataGestion.type = type;
                                    bodyParts = false;

                                    mapOfData =
                                        DataGestion.exsHistory[exercice];
                                    selectedBlock = "weight";
                                  });
                                },
                              )
                            : Container(),
                        category != "a" && category != "d"
                            ? card(
                                cardBlock: "volume",
                                text: text3,
                                onTap: () {
                                  setState(() {
                                    type = "perfsvolume";
                                    DataGestion.type = type;
                                    bodyParts = false;

                                    mapOfData =
                                        DataGestion.exsHistory[exercice];
                                    selectedBlock = "volume";
                                  });
                                },
                              )
                            : Container(),
                        card(
                          cardBlock: "sets",
                          text: 'Sets',
                          onTap: () {
                            setState(() {
                              type = "perfssets";
                              DataGestion.type = type;
                              bodyParts = false;

                              mapOfData = DataGestion.exsHistory[exercice];
                              selectedBlock = "sets";
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const Padding(padding: EdgeInsets.only(bottom: 10)),
                  Row(
                    children: [
                      const SizedBox(
                        width: 20,
                      ),
                      Text(
                        displayUnit() != '' ? '(${displayUnit()})' : '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      const Spacer(),
                      bodyParts == true && type == "measurements"
                          ? controlButtons(
                              onSelected: null,
                              popup: true,
                              onTap: null,
                              itemBuilder: (context) {
                                return List.generate(
                                    InAppData.bodyPartsList.length, (index) {
                                  return PopupMenuItem(
                                    onTap: () {
                                      setState(() {
                                        selectedBodyPart = InAppData
                                            .bodyPartsList[index]
                                            .toLowerCase();
                                        DataGestion.selectedBodyPart =
                                            selectedBodyPart;
                                        if (userDataMap != null &&
                                            userDataMap!["measurements"] !=
                                                null &&
                                            userDataMap!["measurements"]
                                                    ["body parts"] !=
                                                null) {
                                          mapOfData =
                                              userDataMap!["measurements"]
                                                      ["body parts"]
                                                  [selectedBodyPart];
                                        } else {
                                          mapOfData = null;
                                        }
                                      });
                                    },
                                    child: Text(InAppData.bodyPartsList[index]),
                                  );
                                });
                              },
                              color: const Color.fromARGB(255, 255, 26, 26),
                              title: 'Body part',
                              icon: Icons.arrow_drop_down,
                            )
                          : Container(),
                      type == "measurements"
                          ? controlButtons(
                              onSelected: null,
                              popup: false,
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            MeasurementsPage()));
                              },
                              itemBuilder: null,
                              color: const Color.fromARGB(255, 32, 139, 253),
                              title: 'Add new',
                              icon: Icons.add,
                            )
                          : Container(),
                      type != "measurements"
                          ? controlButtons(
                              onSelected: null,
                              itemBuilder: null,
                              color: const Color.fromARGB(255, 255, 168, 7),
                              title: 'Exercice',
                              popup: false,
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ExerciceChoice(
                                              chooseExercice: chooseExercice,
                                            )));
                              },
                            )
                          : Container(),
                      controlButtons(
                        itemBuilder: (context) {
                          return [
                            const PopupMenuItem(
                                value: "6", child: Text("1 week")),
                            const PopupMenuItem(
                                value: "30", child: Text("1 month")),
                            const PopupMenuItem(
                                value: "90", child: Text("3 months")),
                            const PopupMenuItem(
                                value: "365", child: Text("1 year")),
                            const PopupMenuItem(
                                value: "1825", child: Text("5 years")),
                          ];
                        },
                        onSelected: (value) {
                          setState(() {
                            timeSpan = int.parse(value);
                            DataGestion.timeSpan = timeSpan;
                          });
                        },
                        icon: Icons.arrow_drop_down,
                        color: const Color.fromARGB(255, 206, 1, 189),
                        title: 'Period',
                        popup: true,
                        onTap: null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Padding(padding: EdgeInsets.only(bottom: 20)),
            Flexible(
              flex: 50,
              child: Padding(
                padding: const EdgeInsets.only(
                    right: 30, left: 10, bottom: 0, top: 10),
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          strokeWidth: 1.5,
                          color: const Color.fromARGB(82, 158, 158, 158),
                        );
                      },
                      getDrawingVerticalLine: (value) {
                        return FlLine(
                          strokeWidth: 1.5,
                          color: const Color.fromARGB(82, 158, 158, 158),
                        );
                      },
                      show: true,
                      drawHorizontalLine: true,
                      drawVerticalLine: false,
                    ),
                    lineTouchData: LineTouchData(
                      enabled: true,
                      touchTooltipData: LineTouchTooltipData(
                          tooltipRoundedRadius: 10,
                          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                            return touchedBarSpots.map((barSpot) {
                              return LineTooltipItem(
                                '''${determineDecimals(barSpot.y)} ${displayUnit()} 
${daysToMonth(barSpot.x.toInt())}''',
                                const TextStyle(
                                  color: Colors.white,
                                ),
                              );
                            }).toList();
                          }),
                    ),
                    clipData: FlClipData.horizontal(),
                    lineBarsData: [
                      LineChartBarData(
                        color: Theme.of(context).colorScheme.primary,
                        spots: data
                            .map((point) => FlSpot(point.x, point.y))
                            .toList(),
                      ),
                    ],
                    borderData: FlBorderData(
                        border: const Border(
                            bottom: BorderSide(), left: BorderSide())),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: getTitlesData(timeSpan),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 37,
                          getTitlesWidget: (value, meta) {
                            if (value == meta.max || value == meta.min) {
                              return Container();
                            } else {
                              return Row(
                                children: [
                                  const Spacer(),
                                  //Text("${kFormat(value)}"),
                                  displayText(value),
                                  //Padding(padding: EdgeInsets.only(left: 2)),
                                  const Spacer(),
                                ],
                              );
                            }
                          },
                        ),
                      ),
                      topTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    minX: minX,
                    maxX: maxX,
                    minY: minY,
                    maxY: maxY,
                    /* minY: 10000,
                    maxY: 100000, */
                  ),
                ),
              ),
            ),
            const Padding(padding: EdgeInsets.only(bottom: 15)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: (widget.workoutInProg == true)
                  ? [
                      GestureDetector(
                        onTap: () => widget.expandWhenWk(),
                        child: const ResumeWourkout(),
                      ),
                    ]
                  : [],
            ),
          ],
        ),
      ),
    );
  }
}

class GraphPoint {
  final double x;
  final double y;
  GraphPoint({required this.x, required this.y});
}
