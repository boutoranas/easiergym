import 'package:flutter/material.dart';
import 'package:flutter_app/const.dart';
import 'package:flutter_app/in%20app%20data.dart';
import 'package:flutter_app/services/data_update.dart';

import '../../widgets/custom appbar.dart';

class SortPage extends StatefulWidget {
  final Function applyFilters;
  const SortPage({super.key, required this.applyFilters});

  @override
  State<SortPage> createState() => _SortPageState();
}

class _SortPageState extends State<SortPage> {
  List<bool> isExpanded = DataGestion.isExpanded; //[true, true, false, false];
  List titles = InAppData.categories;
  List muscles = InAppData.muscles;
  List equipment = InAppData.equipment;

  List isChecked1 = [];
  List isChecked2 = DataGestion.isChecked2;
  List isChecked3 = [];
  List isChecked4 = [];

  List selectedCategories = DataGestion.selectedCategories;
  List selectedDifficulties = DataGestion.selectedDifficulties;
  List selectedMuscles = DataGestion.selectedMuscles;
  List selectedEquipment = DataGestion.selectedEquipment;

  @override
  void initState() {
    isChecked1 = DataGestion.isChecked1;
    if (isChecked1.isEmpty) {
      for (var element in titles) {
        isChecked1.add(false);
      }
    }

    isChecked3 = DataGestion.isChecked3;
    if (isChecked3.isEmpty) {
      for (var element in muscles) {
        isChecked3.add(false);
      }
    }

    isChecked4 = DataGestion.isChecked4;
    if (isChecked4.isEmpty) {
      for (var element in equipment) {
        isChecked4.add(true);
      }
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
          title: 'Filter', leading: null, actions: null, context: context),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: Const.horizontalPagePadding),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const Padding(padding: EdgeInsets.only(bottom: 10)),
              const Text(
                "Filter by: ",
                style: TextStyle(fontSize: 16),
              ),
              const Padding(padding: EdgeInsets.only(bottom: 5)),
              ExpansionPanelList(
                expansionCallback: (i, isExpandedd) {
                  setState(() {
                    isExpanded[i] = !isExpanded[i];
                  });
                  DataGestion.isExpanded = isExpanded;
                },
                children: [
                  ExpansionPanel(
                    headerBuilder: (context, isExpandeddd) {
                      return const ListTile(
                        title: Text(
                          "Category",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                    body: ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: titles.length,
                        itemBuilder: ((context, index) {
                          return ListTile(
                            tileColor: isChecked1[index] == false
                                ? Theme.of(context).listTileTheme.tileColor
                                : Colors.green,
                            title: Text(titles[index]),
                            trailing: Checkbox(
                                value: isChecked1[index],
                                onChanged: (val) {
                                  setState(() {
                                    isChecked1[index] = !isChecked1[index];
                                    DataGestion.isChecked1 = isChecked1;
                                    if (isChecked1[index] == true) {
                                      selectedCategories.add(titles[index]);
                                    } else {
                                      selectedCategories.remove(titles[index]);
                                    }
                                  });
                                  DataGestion.selectedCategories =
                                      selectedCategories;
                                  widget.applyFilters(
                                      selectedCategories,
                                      selectedDifficulties,
                                      selectedMuscles,
                                      selectedEquipment);
                                }),
                          );
                        })),
                    isExpanded: isExpanded[0],
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpandeddd) {
                      return const ListTile(
                        title: Text(
                          "Difficulty",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                    body: ListTile(
                      title: Row(
                        children: [
                          ChoiceChip(
                            onSelected: (value) {
                              setState(() {
                                isChecked2[0] = value;
                                if (isChecked2[0] == true) {
                                  selectedDifficulties.add("0");
                                } else {
                                  selectedDifficulties.remove("0");
                                }
                              });
                              DataGestion.isChecked2 = isChecked2;
                              widget.applyFilters(
                                  selectedCategories,
                                  selectedDifficulties,
                                  selectedMuscles,
                                  selectedEquipment);
                            },
                            selected: isChecked2[0],
                            selectedColor: Colors.green,
                            label: const Text("Easy"),
                          ),
                          const Padding(padding: EdgeInsets.all(5)),
                          ChoiceChip(
                            onSelected: (value) {
                              setState(() {
                                isChecked2[1] = value;
                                if (isChecked2[1] == true) {
                                  selectedDifficulties.add("1");
                                } else {
                                  selectedDifficulties.remove("1");
                                }
                              });
                              DataGestion.isChecked2 = isChecked2;
                              widget.applyFilters(
                                  selectedCategories,
                                  selectedDifficulties,
                                  selectedMuscles,
                                  selectedEquipment);
                            },
                            selected: isChecked2[1],
                            selectedColor: Colors.green,
                            label: const Text("Medium"),
                          ),
                          const Padding(padding: EdgeInsets.all(5)),
                          ChoiceChip(
                            onSelected: (value) {
                              setState(() {
                                isChecked2[2] = value;
                                if (isChecked2[2] == true) {
                                  selectedDifficulties.add("2");
                                } else {
                                  selectedDifficulties.remove("2");
                                }
                              });
                              DataGestion.isChecked2 = isChecked2;
                              widget.applyFilters(
                                  selectedCategories,
                                  selectedDifficulties,
                                  selectedMuscles,
                                  selectedEquipment);
                            },
                            selected: isChecked2[2],
                            selectedColor: Colors.green,
                            label: const Text("Hard"),
                          ),
                        ],
                      ),
                    ),
                    isExpanded: isExpanded[1],
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpandeddd) {
                      return const ListTile(
                        title: Text(
                          "Muscles worked",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                    body: ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: muscles.length,
                        itemBuilder: ((context, index) {
                          return ListTile(
                            tileColor: isChecked3[index] == false
                                ? Theme.of(context).listTileTheme.tileColor
                                : Colors.green,
                            title: Text(muscles[index]),
                            trailing: Checkbox(
                                value: isChecked3[index],
                                onChanged: (val) {
                                  setState(() {
                                    isChecked3[index] = !isChecked3[index];
                                    DataGestion.isChecked3 = isChecked3;
                                    if (isChecked3[index] == true) {
                                      selectedMuscles.add(muscles[index]);
                                    } else {
                                      selectedMuscles.remove(muscles[index]);
                                    }
                                  });
                                  DataGestion.selectedMuscles = selectedMuscles;
                                  widget.applyFilters(
                                      selectedCategories,
                                      selectedDifficulties,
                                      selectedMuscles,
                                      selectedEquipment);
                                }),
                          );
                        })),
                    isExpanded: isExpanded[2],
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpandeddd) {
                      return const ListTile(
                        title: Text(
                          "Equipement",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                    body: ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: equipment.length,
                        itemBuilder: ((context, index) {
                          return ListTile(
                            tileColor: isChecked4[index] == true
                                ? Theme.of(context).listTileTheme.tileColor
                                : Colors.red,
                            title: Text(equipment[index]),
                            trailing: Checkbox(
                                value: isChecked4[index],
                                onChanged: (val) {
                                  setState(() {
                                    isChecked4[index] = !isChecked4[index];
                                    DataGestion.isChecked4 = isChecked4;
                                    if (isChecked4[index] == true) {
                                      selectedEquipment.add(equipment[index]);
                                    } else {
                                      selectedEquipment
                                          .remove(equipment[index]);
                                    }
                                  });
                                  DataGestion.selectedEquipment =
                                      selectedEquipment;
                                  widget.applyFilters(
                                      selectedCategories,
                                      selectedDifficulties,
                                      selectedMuscles,
                                      selectedEquipment);
                                }),
                          );
                        })),
                    isExpanded: isExpanded[3],
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
