import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/services/data_update.dart';

import '../../../services/time text input formatter.dart';
import '../../../services/user_preferences.dart';

class SetInEditCard extends StatefulWidget {
  final Function updateState;
  final int? reps;
  final num? weightinkg;
  final int number;
  final String exId;
  final String rId;
  final String sId;
  final String category;
  SetInEditCard({
    super.key,
    this.reps,
    this.weightinkg,
    required this.number,
    required this.exId,
    required this.rId,
    required this.sId,
    required this.updateState,
    required this.category,
  });

  @override
  State<SetInEditCard> createState() => _SetInEditCardState();
}

class _SetInEditCardState extends State<SetInEditCard> {
  //!controllers
  TextEditingController weightinkgcontroller = TextEditingController();
  TextEditingController repscontroller = TextEditingController();

  //!userdata
  Map? userDataMap = DataGestion.userDataMap;

  late bool? imperial =
      userDataMap!["routines"][widget.rId]["exercices"][widget.exId]["im"];
  bool weightImperial = DataGestion.weightImperial;
  bool distanceImperial = DataGestion.distanceImperial;

  List units = ["reps", "kg", "time", "+kg", "-kg", "km"];

  late String unit1;
  late String unit2;

  @override
  void initState() {
    associateUnits();
    super.initState();
  }

  //!functions

  Color setTypeColor() {
    if (userDataMap!["routines"][widget.rId]["exercices"][widget.exId]["sets"]
            [widget.sId]["type"] ==
        "W") {
      return Colors.orange;
    } else if (userDataMap!["routines"][widget.rId]["exercices"][widget.exId]
            ["sets"][widget.sId]["type"] ==
        "F") {
      return Colors.red;
    } else if (userDataMap!["routines"][widget.rId]["exercices"][widget.exId]
            ["sets"][widget.sId]["type"] ==
        "D") {
      return const Color.fromARGB(255, 0, 90, 150);
    } else {
      return Theme.of(context).inputDecorationTheme.border!.borderSide.color;
    }
  }

  associateUnits() {
    if (widget.category == "r") {
      unit1 = units[0];
      unit2 = units[1];
    }
    if (widget.category == "b") {
      unit1 = units[0];
      unit2 = units[3];
    }
    if (widget.category == "a") {
      unit1 = units[0];
      unit2 = units[4];
    }
    if (widget.category == "c") {
      unit1 = units[2];
      unit2 = units[5];
    }
    if (widget.category == "d") {
      unit1 = units[2];
      unit2 = units[3];
    }
  }

  num saveUnit2(String text) {
    //exs with weight
    if (widget.category != "c") {
      //in lbs
      if (imperial == true) {
        return double.parse(text) / 2.2;
      } else {
        //in kgs
        return double.parse(text);
      }
    }
    //exs with distances
    else {
      if (imperial == true) {
        //in miles
        return double.parse(text) / 0.6214;
      } else {
        //in km
        return double.parse(text);
      }
    }
  }

  int saveUnit1(String text) {
    if (widget.category == "c" || widget.category == "d") {
      DateTime duration = DateTime.parse("0000-00-00 $text");
      return duration.second + duration.minute * 60 + duration.hour * 3600;
    } else {
      return int.parse(text);
    }
  }

  String calculateUnit2(num val) {
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

  String calculateUnit1(reps) {
    if (widget.category == "c" || widget.category == "d") {
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

  updateUnit2() {
    if (weightinkgcontroller.text.isNotEmpty) {
      userDataMap!["routines"][widget.rId]["exercices"][widget.exId]["sets"]
          [widget.sId]["weightinkg"] = saveUnit2(weightinkgcontroller.text);
    } else {
      userDataMap!["routines"][widget.rId]["exercices"][widget.exId]["sets"]
              [widget.sId]
          .remove("weightinkg");
    }
    DataGestion.userDataMap = userDataMap;
    UserPreferences.saveUserDataMap(json.encode(DataGestion.userDataMap));
  }

  updateUnit1() {
    if (repscontroller.text.isNotEmpty) {
      userDataMap!["routines"][widget.rId]["exercices"][widget.exId]["sets"]
          [widget.sId]["reps"] = saveUnit1(repscontroller.text);
    } else {
      userDataMap!["routines"][widget.rId]["exercices"][widget.exId]["sets"]
              [widget.sId]
          .remove("reps");
    }
    DataGestion.userDataMap = userDataMap;
    UserPreferences.saveUserDataMap(json.encode(DataGestion.userDataMap));
  }

  validateTextFormat1() {
    RegExp duration = RegExp(r'^[0-1][0-9]\:[0-9][0-9]\:[0-9][0-9]$');
    if ((widget.category == "c" || widget.category == "d") &&
        repscontroller.text.isNotEmpty &&
        !duration.hasMatch(repscontroller.text)) {
      repscontroller.clear();
    }
  }

  late String exName =
      userDataMap!["routines"][widget.rId]["exercices"][widget.exId]["name"];

  Widget mostRecentSet(number) {
    List setsList = [];
    if (DataGestion.exsHistory[exName]["recent"] != null) {
      setsList = DataGestion.exsHistory[exName]["recent"].values.toList();
    }
    setsList.sort((a, b) => a["id"].compareTo(b["id"]));
    List nonWsets = [];
    List Wsets = [];
    for (var element in setsList) {
      if (element["type"] != "W") {
        nonWsets.add(element);
      } else {
        Wsets.add(element);
      }
    }
    //for W sets
    if (number == 0) {
      List currentsets = userDataMap!["routines"][widget.rId]["exercices"]
              [widget.exId]["sets"]
          .values
          .toList();
      List currentWsets = [];
      int index = 0;
      for (var element in currentsets) {
        if (element["type"] == "W") {
          currentWsets.add(element);
          if (element["id"] == widget.sId) {
            index = currentWsets.indexOf(element);
          }
        }
      }
      if (index < Wsets.length) {
        String reps;
        if (Wsets[index]["reps"] != null) {
          reps = calculateUnit1(Wsets[index]["reps"]);
        } else {
          reps = '--';
        }
        String weight;
        if (Wsets[index]["weightinkg"] !=
            null) //= setsList[number - 1]["weightinkg"];
        {
          if (widget.category != "c") {
            imperial == false
                ? weight = calculateUnit2(Wsets[index]["weightinkg"])
                : weight = calculateUnit2(Wsets[index]["weightinkg"] * 2.2);
          } else {
            imperial == false
                ? weight = calculateUnit2(Wsets[index]["weightinkg"])
                : weight = calculateUnit2(Wsets[index]["weightinkg"] * 0.6214);
          }
        } else {
          weight = '--';
        }
        return Text("$reps x $weight $unit2");
      } else
        return const Text('');
      //currentWsets.sort((a, b) => a["id"].compareTo(b["id"]));
    } else if (number > 0 && number - 1 < nonWsets.length) {
      String reps;
      if (nonWsets[number - 1]["reps"] != null) {
        reps = calculateUnit1(nonWsets[number - 1]["reps"]);
      } else {
        reps = '--';
      }
      String weight;
      if (nonWsets[number - 1]["weightinkg"] !=
          null) //= setsList[number - 1]["weightinkg"];
      {
        if (widget.category != "c") {
          imperial == false
              ? weight = calculateUnit2(nonWsets[number - 1]["weightinkg"])
              : weight =
                  calculateUnit2(nonWsets[number - 1]["weightinkg"] * 2.2);
        } else {
          imperial == false
              ? weight = calculateUnit2(nonWsets[number - 1]["weightinkg"])
              : weight =
                  calculateUnit2(nonWsets[number - 1]["weightinkg"] * 0.6214);
        }
      } else {
        weight = '--';
      }
      return Text("$reps x $weight $unit2");
    } else {
      return const Text('');
    }
  }

  @override
  Widget build(BuildContext context) {
    //!?!
    String? type = userDataMap!["routines"][widget.rId]["exercices"]
        [widget.exId]["sets"][widget.sId]["type"];
    //set unit from preferences or settings
    imperial =
        userDataMap!["routines"][widget.rId]["exercices"][widget.exId]["im"];

    if (imperial == null) {
      widget.category != "c"
          ? imperial = weightImperial
          : imperial = distanceImperial;
    }

    if (imperial == true) {
      units = ["reps", "lbs", "time", "+lbs", "-lbs", "miles"];
    } else {
      units = ["reps", "kg", "time", "+kg", "-kg", "km"];
    }
    associateUnits();

    if (widget.weightinkg != null) {
      if (widget.category != "c") {
        (imperial == false)
            ? weightinkgcontroller.text =
                calculateUnit2(widget.weightinkg!) //kg
            : weightinkgcontroller.text =
                calculateUnit2(widget.weightinkg! * 2.2); //lbs
      } else {
        (imperial == false)
            ? weightinkgcontroller.text =
                calculateUnit2(widget.weightinkg!) //km
            : weightinkgcontroller.text =
                calculateUnit2(widget.weightinkg! * 0.6214); //miles
      }
    }
    if (widget.reps != null) {
      repscontroller.text = calculateUnit1(widget.reps);
    }
    return Dismissible(
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        child: const Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: EdgeInsets.only(right: 10),
            child: Icon(Icons.delete),
          ),
        ),
      ),
      onDismissed: (DismissDirection direction) {
        //remove set locally
        userDataMap!["routines"][widget.rId]["exercices"][widget.exId]["sets"]
            .remove(widget.sId);
        DataGestion.userDataMap = userDataMap;
        UserPreferences.saveUserDataMap(json.encode(DataGestion.userDataMap));
        widget.updateState();
      },
      key: widget.key!,
      child: Container(
          //decoration: BoxDecoration(color: Colors.white),
          height: 30,
          margin: const EdgeInsets.only(bottom: 5),
          child: Row(
            children: [
              //Text('Set: '),
              PopupMenuButton(
                child: Container(
                  height: 25,
                  width: 25,
                  decoration: BoxDecoration(
                      color: setTypeColor().withOpacity(0.15),
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(
                        width: 2,
                        color: Theme.of(context)
                            .inputDecorationTheme
                            .border!
                            .borderSide
                            .color,
                      )),
                  child: Center(
                    child: (type != null)
                        ? Text(
                            type,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: setTypeColor(),
                            ),
                          )
                        : Text(
                            "${widget.number}",
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                ),
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(
                      value: "W",
                      textStyle: (type == "W")
                          ? const TextStyle(color: Colors.blue)
                          : null,
                      child: const Text("W: Warmup set"),
                    ),
                    PopupMenuItem(
                      value: "D",
                      textStyle: (type == "D")
                          ? const TextStyle(color: Colors.blue)
                          : null,
                      child: const Text("D: Dropset"),
                    ),
                    PopupMenuItem(
                      value: "F",
                      textStyle: (type == "F")
                          ? const TextStyle(color: Colors.blue)
                          : null,
                      child: const Text("F: Failure"),
                    ),
                  ];
                },
                onSelected: (value) {
                  if (value == "W") {
                    if (userDataMap!["routines"][widget.rId]["exercices"]
                            [widget.exId]["sets"][widget.sId]["type"] !=
                        "W") {
                      userDataMap!["routines"][widget.rId]["exercices"]
                          [widget.exId]["sets"][widget.sId]["type"] = "W";
                    } else {
                      userDataMap!["routines"][widget.rId]["exercices"]
                              [widget.exId]["sets"][widget.sId]
                          .remove("type");
                    }
                    widget.updateState();
                  }

                  if (value == "D") {
                    if (userDataMap!["routines"][widget.rId]["exercices"]
                            [widget.exId]["sets"][widget.sId]["type"] !=
                        "D") {
                      userDataMap!["routines"][widget.rId]["exercices"]
                          [widget.exId]["sets"][widget.sId]["type"] = "D";
                    } else {
                      userDataMap!["routines"][widget.rId]["exercices"]
                              [widget.exId]["sets"][widget.sId]
                          .remove("type");
                    }
                  }

                  if (value == "F") {
                    if (userDataMap!["routines"][widget.rId]["exercices"]
                            [widget.exId]["sets"][widget.sId]["type"] !=
                        "F") {
                      userDataMap!["routines"][widget.rId]["exercices"]
                          [widget.exId]["sets"][widget.sId]["type"] = "F";
                    } else {
                      userDataMap!["routines"][widget.rId]["exercices"]
                              [widget.exId]["sets"][widget.sId]
                          .remove("type");
                    }
                  }
                  UserPreferences.saveUserDataMap(
                      json.encode(DataGestion.userDataMap));
                  setState(() {});
                },
              ),
              Expanded(
                child: Center(child: mostRecentSet(widget.number)),
              ),
              Container(
                height: 25,
                width: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey.withOpacity(0.3),
                ),
                child: TextField(
                  style: const TextStyle(
                      //color: Colors.black,
                      ),
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    validateTextFormat1();
                    updateUnit1();
                  },
                  onTap: () {
                    if (widget.category == "c" || widget.category == "d") {
                      repscontroller.selection = TextSelection.fromPosition(
                          TextPosition(offset: repscontroller.text.length));
                    }
                  },
                  controller: repscontroller,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: EdgeInsets.zero,
                    filled: true,
                  ),
                  /* (widget.reps != null &&
                            widget.category != "c" &&
                            widget.category != "d")
                        ? InputDecoration(hintText: '${widget.reps}')
                        :  */

                  keyboardType: TextInputType.number,
                  inputFormatters:
                      (widget.category == "c" || widget.category == "d")
                          ? [
                              TimeTextInputFormatter(),
                            ]
                          : [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(6),
                            ],
                ),
              ),
              const Padding(padding: EdgeInsets.only(left: 10)),
              Container(width: 8, child: const Text('x')),
              const Padding(padding: EdgeInsets.only(left: 10)),
              Container(
                height: 25,
                width: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey.withOpacity(0.3),
                ),
                child: TextField(
                  style: const TextStyle(
                      //color: Colors.black,
                      ),
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    updateUnit2();
                  },
                  controller: weightinkgcontroller,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: EdgeInsets.zero,
                    filled: true,
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}')),
                    LengthLimitingTextInputFormatter(6),
                  ],
                ),
              ),
              //Text(unit2),
            ],
          )),
    );
  }
}
