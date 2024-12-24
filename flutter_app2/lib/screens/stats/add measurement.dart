import 'dart:convert';

import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/const.dart';
import 'package:flutter_app/services/data_update.dart';
import 'package:flutter_app/services/date%20formater.dart';
import 'package:flutter_app/widgets/button.dart';
import 'package:flutter_app/widgets/custom%20appbar.dart';

import '../../services/app_media_query.dart';
import '../../services/user_preferences.dart';

class AddMeasurement extends StatefulWidget {
  final String measurement;
  const AddMeasurement({super.key, required this.measurement});

  @override
  State<AddMeasurement> createState() => _AddMeasurementState();
}

class _AddMeasurementState extends State<AddMeasurement> {
  final userID = FirebaseAuth.instance.currentUser!.uid;
  late DatabaseReference database =
      FirebaseDatabase.instance.ref().child("users").child(userID);

  late DatabaseReference ref = FirebaseDatabase.instance
      .ref()
      .child("users")
      .child(userID)
      .child("easiergym")
      .child("measurements");

  TextEditingController controller = TextEditingController();
  ScrollController scrollController = ScrollController();

  Map? userDataMap = DataGestion.userDataMap;

  List measurementsList = [];

  List units = ["kg", "%", "kcal", "cm"];
  late String unit;
  //bool imperial = true;

  bool weightImperial = DataGestion.weightImperial;
  bool sizeImperial = DataGestion.sizeImperial;

  @override
  void initState() {
    if (weightImperial == true) {
      units[0] = "lbs";
    }
    if (sizeImperial == true) {
      units[3] = "in";
    }
    if (widget.measurement == "Body weight") {
      unit = units[0];
    } else if (widget.measurement == "Body fat") {
      unit = units[1];
    } else if (widget.measurement == "Calories") {
      unit = units[2];
    } else {
      unit = units[3];
    }
    super.initState();
  }

  String calculateUnit(num value) {
    RegExp dec = RegExp(r'^([0-9]?)+([\.][0-9]+)$');
    RegExp oneDec = RegExp(r'^([0-9]?)+([\.][0-9])$');
    RegExp zeros = RegExp(r'^([0-9]?)+([\.][0][0]?)$');

    num val;

    if (widget.measurement == "Body weight") {
      weightImperial == false ? val = value : val = value * 2.2;
    } else if (widget.measurement == "Body fat") {
      val = value;
    } else if (widget.measurement == "Calories") {
      val = value;
    } else {
      sizeImperial == false ? val = value : val = value * 0.394;
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

  num saveUnit(String text) {
    num textToNum = num.parse(text);
    num val;

    if (widget.measurement == "Body weight") {
      weightImperial == false ? val = textToNum : val = textToNum / 2.2;
    } else if (widget.measurement == "Body fat") {
      val = textToNum;
    } else if (widget.measurement == "Calories") {
      val = textToNum;
    } else {
      sizeImperial == false ? val = textToNum : val = textToNum / 0.394;
    }
    return val;
  }

  int daysSinceEpoch(int msSinceEpoch) {
    DateTime datenow = DateTime.fromMillisecondsSinceEpoch(msSinceEpoch);
    Duration date = Duration(
        milliseconds: msSinceEpoch + datenow.timeZoneOffset.inMilliseconds);
    return date.inDays;
  }

  @override
  Widget build(BuildContext context) {
    if (userDataMap != null && userDataMap!["measurements"] != null) {
      if ((widget.measurement == "Body weight" ||
              widget.measurement == "Body fat" ||
              widget.measurement == "Calories") &&
          userDataMap!["measurements"][widget.measurement.toLowerCase()] !=
              null) {
        measurementsList = userDataMap!["measurements"]
                [widget.measurement.toLowerCase()]
            .values
            .toList();
      } else if (userDataMap!["measurements"]["body parts"] != null &&
          userDataMap!["measurements"]["body parts"]
                  [widget.measurement.toLowerCase()] !=
              null) {
        measurementsList = userDataMap!["measurements"]["body parts"]
                [widget.measurement.toLowerCase()]
            .values
            .toList();
      }
    }
    measurementsList.sort((a, b) => b["date"].compareTo(a["date"]));

    addMeasurement(context) {
      showDialog(
          context: context,
          builder: ((context) {
            return AlertDialog(
              title: const Text("Add a measurement"),
              content: TextField(
                autofocus: true,
                controller: controller,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  LengthLimitingTextInputFormatter(5),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (controller.text.isNotEmpty) {
                      if (userDataMap != null) {
                        if (userDataMap!["measurements"] != null) {
                          //global measurements
                          if (widget.measurement == "Body weight" ||
                              widget.measurement == "Body fat" ||
                              widget.measurement == "Calories") {
                            if (userDataMap!["measurements"]
                                    [widget.measurement.toLowerCase()] !=
                                null) {
                              //verify that its the only measurement of the day
                              int count = 0;
                              userDataMap!["measurements"]
                                      [widget.measurement.toLowerCase()]
                                  .forEach((k, v) {
                                if (daysSinceEpoch(v["date"]) ==
                                    daysSinceEpoch(DateTime.now()
                                        .millisecondsSinceEpoch)) {
                                  v["value"] = saveUnit(controller.text);
                                  v["date"] =
                                      DateTime.now().millisecondsSinceEpoch;
                                  count++;
                                }
                              });
                              if (count == 0) {
                                final keyy = ref
                                    .child(widget.measurement.toLowerCase())
                                    .push();
                                userDataMap!["measurements"]
                                        [widget.measurement.toLowerCase()]
                                    [keyy.key] = {
                                  "date": DateTime.now().millisecondsSinceEpoch,
                                  "value": saveUnit(controller.text),
                                  "id": keyy.key,
                                };
                              }
                            } else {
                              final keyy = ref
                                  .child(widget.measurement.toLowerCase())
                                  .push();
                              userDataMap!["measurements"]
                                  [widget.measurement.toLowerCase()] = {
                                keyy.key as String: {
                                  "date": DateTime.now().millisecondsSinceEpoch,
                                  "value": saveUnit(controller.text),
                                  "id": keyy.key,
                                }
                              };
                            }
                          }
                          //bodypart measurements
                          else {
                            if (userDataMap!["measurements"]["body parts"] !=
                                null) {
                              if (userDataMap!["measurements"]["body parts"]
                                      [widget.measurement.toLowerCase()] !=
                                  null) {
                                //verify that its the only measurement of the day
                                int count = 0;
                                userDataMap!["measurements"]["body parts"]
                                        [widget.measurement.toLowerCase()]
                                    .forEach((k, v) {
                                  if (daysSinceEpoch(v["date"]) ==
                                      daysSinceEpoch(DateTime.now()
                                          .millisecondsSinceEpoch)) {
                                    v["value"] = saveUnit(controller.text);
                                    v["date"] =
                                        DateTime.now().millisecondsSinceEpoch;
                                    count++;
                                  }
                                });
                                if (count == 0) {
                                  final keyy = ref
                                      .child("body parts")
                                      .child(widget.measurement.toLowerCase())
                                      .push();
                                  userDataMap!["measurements"]["body parts"]
                                          [widget.measurement.toLowerCase()]
                                      [keyy.key] = {
                                    "date":
                                        DateTime.now().millisecondsSinceEpoch,
                                    "value": saveUnit(controller.text),
                                    "id": keyy.key,
                                  };
                                }
                              } else {
                                final keyy = ref
                                    .child("body parts")
                                    .child(widget.measurement.toLowerCase())
                                    .push();
                                userDataMap!["measurements"]["body parts"]
                                    [widget.measurement.toLowerCase()] = {
                                  keyy.key as String: {
                                    "date":
                                        DateTime.now().millisecondsSinceEpoch,
                                    "value": saveUnit(controller.text),
                                    "id": keyy.key,
                                  }
                                };
                              }
                            } else {
                              final keyy = ref
                                  .child("body parts")
                                  .child(widget.measurement.toLowerCase())
                                  .push();
                              userDataMap!["measurements"]["body parts"] = {
                                widget.measurement.toLowerCase(): {
                                  keyy.key as String: {
                                    "date":
                                        DateTime.now().millisecondsSinceEpoch,
                                    "value": saveUnit(controller.text),
                                    "id": keyy.key,
                                  }
                                }
                              };
                            }
                          }
                        } else {
                          if (widget.measurement == "Body weight" ||
                              widget.measurement == "Body fat" ||
                              widget.measurement == "Calories") {
                            final keyy = ref
                                .child(widget.measurement.toLowerCase())
                                .push();
                            userDataMap!["measurements"] = {
                              widget.measurement.toLowerCase(): {
                                keyy.key as String: {
                                  "date": DateTime.now().millisecondsSinceEpoch,
                                  "value": saveUnit(controller.text),
                                  "id": keyy.key,
                                }
                              }
                            };
                          } else {
                            final keyy = ref
                                .child("body parts")
                                .child(widget.measurement.toLowerCase())
                                .push();
                            userDataMap!["measurements"] = {
                              "body parts": {
                                widget.measurement.toLowerCase(): {
                                  keyy.key as String: {
                                    "date":
                                        DateTime.now().millisecondsSinceEpoch,
                                    "value": saveUnit(controller.text),
                                    "id": keyy.key,
                                  }
                                }
                              }
                            };
                          }
                        }
                      } else {
                        if (widget.measurement == "Body weight" ||
                            widget.measurement == "Body fat" ||
                            widget.measurement == "Calories") {
                          final keyy = ref
                              .child(widget.measurement.toLowerCase())
                              .push();
                          userDataMap = {
                            "measurements": {
                              widget.measurement.toLowerCase(): {
                                keyy.key as String: {
                                  "date": DateTime.now().millisecondsSinceEpoch,
                                  "value": saveUnit(controller.text),
                                  "id": keyy.key,
                                }
                              }
                            }
                          };
                        } else {
                          final keyy = ref
                              .child("body parts")
                              .child(widget.measurement.toLowerCase())
                              .push();
                          userDataMap = {
                            "measurements": {
                              "body parts": {
                                widget.measurement.toLowerCase(): {
                                  keyy.key as String: {
                                    "date":
                                        DateTime.now().millisecondsSinceEpoch,
                                    "value": saveUnit(controller.text),
                                    "id": keyy.key,
                                  }
                                }
                              }
                            }
                          };
                        }
                      }
                      UserPreferences.saveUserDataMap(
                          json.encode(DataGestion.userDataMap));
                      Navigator.pop(context);
                      controller.clear();
                      setState(() {});
                    }
                  },
                  child: const Text("Enter"),
                )
              ],
            );
          }));
    }

    deleteMeasurement(id) {
      if ((widget.measurement == "Body weight" ||
          widget.measurement == "Body fat" ||
          widget.measurement == "Calories")) {
        userDataMap!["measurements"][widget.measurement.toLowerCase()]
            .remove(id);
      } else {
        userDataMap!["measurements"]["body parts"]
                [widget.measurement.toLowerCase()]
            .remove(id);
      }
      DataGestion.userDataMap = userDataMap;
      UserPreferences.saveUserDataMap(json.encode(DataGestion.userDataMap));
      setState(() {});
    }

    return Scaffold(
      appBar: customAppBar(
          title: '${widget.measurement} measurements',
          leading: null,
          actions: null,
          context: context),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: Const.horizontalPagePadding),
        child: Column(
          children: [
            const Padding(padding: EdgeInsets.only(bottom: 10)),
            Expanded(
              flex: 100,
              child: measurementsList.isNotEmpty
                  ? FadingEdgeScrollView.fromScrollView(
                      child: ListView.builder(
                          controller: scrollController,
                          physics: const BouncingScrollPhysics(),
                          itemCount: measurementsList.length,
                          itemBuilder: (context, i) {
                            DateTime date = DateTime.fromMillisecondsSinceEpoch(
                                measurementsList[i]["date"]);
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 4,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                              child: ListTile(
                                title: Text(
                                    "${DateFormater.month(date)} ${DateFormater.day(date)}${DateFormater.year(date)} (at ${DateFormater.hour(date)}:${DateFormater.minute(date).toString().padLeft(2, "0")})"),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                        "${calculateUnit(measurementsList[i]["value"])} $unit"),
                                    SizedBox(
                                      width: 30,
                                      child: IconButton(
                                        onPressed: () {
                                          deleteMeasurement(
                                              measurementsList[i]["id"]);
                                        },
                                        icon: const Icon(
                                          Icons.delete,
                                        ),
                                        tooltip: 'Remove',
                                        constraints: const BoxConstraints(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                    )
                  : const Text("No measurements"),
            ),
            const Spacer(),
            const Padding(padding: EdgeInsets.only(bottom: 5)),
            Center(
              child: button(
                color: Theme.of(context).primaryColor,
                icon: Icons.add,
                context: context,
                onPressed: () {
                  addMeasurement(context);
                },
                text: 'Add measurement',
              ),
            ),
            Padding(
                padding: EdgeInsets.only(
                    bottom: AppMediaQuerry.mq.padding.bottom + 8)),
          ],
        ),
      ),
    );
  }
}
