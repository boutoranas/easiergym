import 'dart:convert';

import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/const.dart';
import 'package:flutter_app/widgets/button.dart';

import '../../in app data.dart';
import '../../services/app_media_query.dart';
import '../../services/data_update.dart';
import '../../services/user_preferences.dart';
import '../../widgets/custom appbar.dart';
import '../workout/create exercice page.dart';
import '../workout/filter exercices.dart';
import 'local widgets/add exercice card in saved log.dart';

class ExercicesPageInSavedLog extends StatefulWidget {
  final String lId;
  const ExercicesPageInSavedLog({super.key, required this.lId});

  @override
  State<ExercicesPageInSavedLog> createState() =>
      _ExercicesPageInSavedLogState();
}

class _ExercicesPageInSavedLogState extends State<ExercicesPageInSavedLog> {
  ScrollController scrollController = ScrollController();

  bool notEmpty = false;

  Map? userDataMap = DataGestion.userDataMap;

  bool search = false;

  List exercices = InAppData.exercices.values.toList();

  List filteredExercices = [];
  List foundExercices = [];

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    exercices.sort(
      (a, b) => a["name"].compareTo(b["name"]),
    );
    DataGestion.selectedExercices = {};
    filteredExercices = exercices;
    foundExercices = exercices;

    //filtering reset
    DataGestion.isChecked5 = [];
    DataGestion.isChecked6 = [];

    DataGestion.isExpanded1 = [true, true];

    DataGestion.selectedTypes = [];
    DataGestion.selectedCategories1 = [];

    super.initState();
  }

  updateState() {
    if (DataGestion.selectedExercices.isNotEmpty) {
      setState(() {
        notEmpty = true;
      });
    } else {
      setState(() {
        notEmpty = false;
      });
    }
    setState(() {
      exercices = InAppData.exercices.values.toList();
      exercices.sort(
        (a, b) => a["name"].compareTo(b["name"]),
      );
      filteredExercices = exercices;
    });
    applyFilters(DataGestion.selectedTypes, DataGestion.selectedCategories1);
  }

  void getSearchResults() {
    String removeSpecialCaracters(String string) {
      String regex =
          r'[^\p{Alphabetic}\p{Mark}\p{Decimal_Number}\p{Connector_Punctuation}\p{Join_Control}\s]+';
      return string
          .replaceAll(RegExp(regex, unicode: true), '')
          .replaceAll(' ', '')
          .toLowerCase();
    }

    List results = [];
    String searchTerm = removeSpecialCaracters(searchController.text.trim());
    if (searchTerm.isNotEmpty) {
      //get first letters first
      List same1stLetters = [];
      for (var element in filteredExercices) {
        if (removeSpecialCaracters(element["name"]).startsWith(searchTerm)) {
          same1stLetters.add(element);
        }
      }

      results = same1stLetters;

      List notSameLetters = [];
      for (var element in filteredExercices) {
        if (!removeSpecialCaracters(element["name"]).startsWith(searchTerm)) {
          notSameLetters.add(element);
        }
      }

      results.addAll(notSameLetters.where((element) {
        return removeSpecialCaracters(element["name"]).contains(searchTerm);
      }).toList());
    } else {
      results = filteredExercices;
    }
    setState(() {
      foundExercices = results;
    });
  }

  void applyFilters(List muscles, List categories) {
    List results = [];
    List results1 = [];

    if (muscles.isNotEmpty) {
      results = exercices
          .where((element) =>
              muscles.join(" ").toLowerCase().contains(element["type"]))
          .toList();
    } else {
      results = exercices;
    }

    if (categories.isNotEmpty) {
      results1 = results
          .where((element) => categories
              .join(" ")
              .toLowerCase()
              .contains(element["category"].toString()))
          .toList();
    } else {
      results1 = results;
    }

    setState(() {
      filteredExercices = results1;
    });
    //print(filteredRoutines);
    getSearchResults();
  }

  addExercices() {
    Map? newSelectedExercices = {};
    DataGestion.selectedExercices.values.toList().forEach((element) {
      newSelectedExercices.addAll(element);
    });

    //recalculate position
    List exercicesList =
        DataGestion.exercicesInLogList(userDataMap, widget.lId);
    exercicesList.sort((a, b) => a["pos"].compareTo(b["pos"]));
    List broadExercicesList =
        DataGestion.broadExsInLogList(userDataMap, widget.lId);

    exercicesList.asMap().forEach((numm, value) {
      String keyy = value["id"];
      if (broadExercicesList[0]["exercices"][keyy] != null) {
        broadExercicesList[0]["exercices"][keyy].addAll({"pos": numm});
      }
    });

    int existingExercices = 0;
    Map? mapp = userDataMap!["logs"][widget.lId]["exercices"];
    mapp != null ? existingExercices = mapp.length : 0;
    newSelectedExercices.forEach((key, value) {
      newSelectedExercices[key]["pos"] = existingExercices;
      existingExercices++;
    });
    if (userDataMap!["logs"][widget.lId]["exercices"] != null) {
      userDataMap!["logs"][widget.lId]["exercices"]
          .addAll(json.decode(json.encode(newSelectedExercices)));
    } else {
      userDataMap!["logs"][widget.lId]["exercices"] =
          json.decode(json.encode(newSelectedExercices));
    }
    UserPreferences.saveUserDataMap(json.encode(DataGestion.userDataMap));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (search == true) {
          setState(() {
            foundExercices = filteredExercices;
            search = false;
          });
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
          appBar: search == false
              ? customAppBar(
                  title: 'Exercices',
                  leading: null,
                  actions: [
                    IconButton(
                        tooltip: 'Search',
                        padding: const EdgeInsets.all(5),
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          setState(() {
                            search = true;
                          });
                        },
                        icon: const Icon(Icons.search)),
                    IconButton(
                        tooltip: 'Create',
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CreateExercicePage(
                                        updateState: updateState,
                                      )));
                        },
                        icon: const Icon(Icons.add)),
                  ],
                  context: context)
              : AppBar(
                  backgroundColor: Colors.white,
                  leading: BackButton(
                    onPressed: () {
                      searchController.clear();
                      setState(() {
                        foundExercices = filteredExercices;
                        search = false;
                      });
                    },
                    color: Colors.black,
                  ),
                  title: Container(
                    color: Colors.white,
                    height: 55,
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 220,
                          child: TextField(
                            style: const TextStyle(
                              color: Colors.black,
                            ),
                            controller: searchController,
                            autofocus: true,
                            onChanged: (value) {
                              getSearchResults();
                            },
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            searchController.clear();
                            foundExercices = filteredExercices;
                            setState(() {});
                          },
                          child: const Icon(
                            Icons.cancel_sharp,
                            color: Colors.black,
                          ),
                        ),
                        const Padding(padding: EdgeInsets.all(10)),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => FilterExercices(
                                          applyFilters: applyFilters,
                                        )));
                          },
                          child: const Icon(
                            Icons.sort,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          body: Padding(
            padding:
                EdgeInsets.symmetric(horizontal: Const.horizontalPagePadding),
            child: Column(
              children: [
                const Padding(padding: EdgeInsets.all(5)),
                Container(
                    child: (filteredExercices != exercices)
                        ? Chip(
                            backgroundColor:
                                const Color.fromARGB(255, 241, 133, 125),
                            onDeleted: () {
                              DataGestion.isChecked5 = [];
                              DataGestion.isChecked6 = [];

                              DataGestion.isExpanded1 = [true, true];

                              DataGestion.selectedTypes = [];
                              DataGestion.selectedCategories1 = [];
                              setState(() {
                                filteredExercices = exercices;
                                getSearchResults();
                              });
                            },
                            deleteIcon: const Icon(Icons.cancel),
                            label: const Text("Cancel filters"),
                          )
                        : null),
                //listview builder of exercices list
                Expanded(
                  child: FadingEdgeScrollView.fromScrollView(
                    child: ListView.builder(
                      controller: scrollController,
                      physics: const BouncingScrollPhysics(),
                      itemCount: foundExercices.length,
                      itemBuilder: (context, i) {
                        return AddExerciceCardInSavedLog(
                          updateState: updateState,
                          name: foundExercices[i]["name"],
                          type: foundExercices[i]["type"],
                          lId: widget.lId,
                        );
                      },
                    ),
                  ),
                ),
                Center(
                  child: notEmpty == true
                      ? button(
                          color: Theme.of(context).primaryColor,
                          context: context,
                          onPressed: () {
                            addExercices();
                          },
                          text:
                              'Add exercices (${DataGestion.selectedExercices.length})',
                        )
                      : null,
                ),
                Padding(
                    padding: EdgeInsets.only(
                        bottom: AppMediaQuerry.mq.padding.bottom + 8)),
              ],
            ),
          )),
    );
  }
}
