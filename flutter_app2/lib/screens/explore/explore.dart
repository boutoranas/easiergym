import 'dart:convert';

import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/const.dart';
import 'package:flutter_app/screens/explore/sort%20page.dart';
import 'package:flutter_app/services/data_update.dart';

import '../../in app data.dart';
import '../../widgets/custom appbar.dart';
import '../../widgets/resume workout bar.dart';
import 'local widegets/routine card in explore.dart';

class ExploreSection extends StatefulWidget {
  final Function navigateBackToWkSection;
  final Function expandWhenWk;
  final bool workoutInProg;
  const ExploreSection(
      {super.key,
      required this.expandWhenWk,
      required this.workoutInProg,
      required this.navigateBackToWkSection});

  @override
  State<ExploreSection> createState() => _ExploreSectionState();
}

class _ExploreSectionState extends State<ExploreSection> {
  List routines = [];
  List filteredRoutines = [];
  List categories = InAppData.categories;
  bool search = false;
  List foundRoutines = [];

  TextEditingController searchController = TextEditingController();
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    routines = InAppData.routines;
    foundRoutines = routines;
    filteredRoutines = routines;
    applyFilters(
        DataGestion.selectedCategories,
        DataGestion.selectedDifficulties,
        DataGestion.selectedMuscles,
        DataGestion.selectedEquipment);

    super.initState();
  }

  /* void getSearchResults() {
    List results = [];
    if (searchController.text.isNotEmpty) {
      results = filteredRoutines
          .where((element) => element["name"]
              .toLowerCase()
              .contains(searchController.text.toLowerCase()))
          .toList();
    } else {
      results = filteredRoutines;
    }
    setState(() {
      foundRoutines = results;
    });
  } */

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
      for (var element in filteredRoutines) {
        if (removeSpecialCaracters(element["name"]).startsWith(searchTerm)) {
          same1stLetters.add(element);
        }
      }

      results = same1stLetters;

      List notSameLetters = [];
      for (var element in filteredRoutines) {
        if (!removeSpecialCaracters(element["name"]).startsWith(searchTerm)) {
          notSameLetters.add(element);
        }
      }

      results.addAll(notSameLetters.where((element) {
        return removeSpecialCaracters(element["name"]).contains(searchTerm);
      }).toList());
    } else {
      results = filteredRoutines;
    }
    setState(() {
      foundRoutines = results;
    });
  }

  void applyFilters(List categories, List difficulties, List selectedMuscles,
      List equipment) {
    List results = [];
    List results1 = [];
    List results2 = [];
    List results3 = [];

    if (categories.isNotEmpty) {
      results = routines
          .where(
              (element) => categories.join(" ").contains(element["category"]))
          .toList();
    } else {
      results = routines;
    }

    if (difficulties.isNotEmpty) {
      results1 = results
          .where((element) =>
              difficulties.join(" ").contains(element["difficulty"].toString()))
          .toList();
    } else {
      results1 = results;
    }

    if (selectedMuscles.isNotEmpty) {
      results2 = results1.where((element) {
        int count = 0;
        for (int i = 0; i <= selectedMuscles.length - 1; i++) {
          if (element["muscles worked"]
              .join(" ")
              .toLowerCase()
              .contains(selectedMuscles[i].toLowerCase())) {
            count++;
          }
        }
        return count > 0;
      }).toList();
    } else {
      results2 = results1;
    }

    if (equipment.length < InAppData.equipment.length) {
      results3 = results2.where((element) {
        int count = 0;
        for (int i = 0; i <= equipment.length - 1; i++) {
          if (element["equipment"]
              .join(" ")
              .toLowerCase()
              .contains(equipment[i].toLowerCase())) {
            count++;
          }
        }
        return count >= element["equipment"].length;
      }).toList();
    } else {
      results3 = results2;
    }

    setState(() {
      filteredRoutines = results3;
    });
    //print(filteredRoutines);
    getSearchResults();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: (search == false)
          ? customAppBar(
              title: 'Explore',
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
              ],
              context: context)
          : AppBar(
              backgroundColor: Colors.white,
              leading: BackButton(
                onPressed: () {
                  searchController.clear();
                  setState(() {
                    foundRoutines = filteredRoutines;
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
                        foundRoutines = filteredRoutines;
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
                                builder: (context) => SortPage(
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
      body: Column(
        children: [
          const Padding(padding: EdgeInsets.only(bottom: 10)),
          Expanded(
            flex: 100,
            child: (foundRoutines == routines)
                ? FadingEdgeScrollView.fromScrollView(
                    child: ListView.builder(
                        controller: scrollController,
                        physics: const BouncingScrollPhysics(),
                        itemCount: categories.length,
                        itemBuilder: (context, i) {
                          List categoryRoutines = [];
                          for (var element in routines) {
                            if (categories[i] == element["category"]) {
                              categoryRoutines.add(element);
                            }
                          }
                          return ListTile(
                            title: Text(
                              categories[i],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                            subtitle: SizedBox(
                              height: 105,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: ListView.builder(
                                    physics: const BouncingScrollPhysics(),
                                    scrollDirection: Axis.horizontal,
                                    itemCount: categoryRoutines.length,
                                    itemBuilder: (context, ii) {
                                      return RoutineCardInExplore(
                                        navigateBackToWkSection:
                                            widget.navigateBackToWkSection,
                                        routineMap: categoryRoutines[ii],
                                      );
                                    }),
                              ),
                            ),
                          );
                        }),
                  )
                : Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: Const.horizontalPagePadding),
                    child: Column(
                      children: [
                        Container(
                            child: (filteredRoutines != routines)
                                ? Chip(
                                    backgroundColor: const Color.fromARGB(
                                        255, 241, 133, 125),
                                    onDeleted: () {
                                      DataGestion.isChecked1 = [];
                                      DataGestion.isChecked2 = [
                                        false,
                                        false,
                                        false
                                      ];
                                      DataGestion.isChecked3 = [];
                                      DataGestion.isChecked4 = [];

                                      DataGestion.selectedCategories = [];
                                      DataGestion.selectedDifficulties = [];
                                      DataGestion.selectedMuscles = [];
                                      DataGestion.selectedEquipment =
                                          json.decode(
                                              json.encode(InAppData.equipment));
                                      setState(() {
                                        filteredRoutines = routines;
                                        getSearchResults();
                                      });
                                    },
                                    deleteIcon: const Icon(Icons.cancel),
                                    label: const Text("Cancel filters"),
                                  )
                                : null),
                        Expanded(
                          child: FadingEdgeScrollView.fromScrollView(
                            child: ListView.builder(
                              controller: scrollController,
                              physics: const BouncingScrollPhysics(),
                              itemCount: foundRoutines.length,
                              itemBuilder: (context, i) {
                                return Padding(
                                  padding: const EdgeInsets.all(0),
                                  child: RoutineCardInExplore(
                                      navigateBackToWkSection:
                                          widget.navigateBackToWkSection,
                                      routineMap: foundRoutines[i]),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          const Spacer(),
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
    );
  }
}
