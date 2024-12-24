import 'package:flutter/material.dart';
import 'package:flutter_app/const.dart';
import 'package:flutter_app/in%20app%20data.dart';
import 'package:flutter_app/widgets/custom%20appbar.dart';

import '../../services/data_update.dart';

class FilterExercices extends StatefulWidget {
  final Function applyFilters;
  const FilterExercices({super.key, required this.applyFilters});

  @override
  State<FilterExercices> createState() => _FilterExercicesState();
}

class _FilterExercicesState extends State<FilterExercices> {
  List muscles = InAppData.muscles;
  List categories = InAppData.exerciceCategories;

  List<bool> isExpanded = DataGestion.isExpanded1;

  List isChecked = [];
  List isChecked1 = [];

  List selectedTypes = DataGestion.selectedTypes;
  List selectedCategories = DataGestion.selectedCategories1;

  @override
  void initState() {
    isChecked = DataGestion.isChecked5;
    if (isChecked.isEmpty) {
      for (var element in muscles) {
        isChecked.add(false);
      }
    }

    isChecked1 = DataGestion.isChecked6;
    if (isChecked1.isEmpty) {
      for (var element in categories) {
        isChecked1.add(false);
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
                  DataGestion.isExpanded1 = isExpanded;
                },
                children: [
                  ExpansionPanel(
                    headerBuilder: (context, isExpandeddd) {
                      return const ListTile(
                        title: Text(
                          "Muscle worked",
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
                            tileColor: isChecked[index] == false
                                ? Theme.of(context).listTileTheme.tileColor
                                : Colors.green,
                            title: Text(muscles[index]),
                            trailing: Checkbox(
                                value: isChecked[index],
                                onChanged: (val) {
                                  setState(() {
                                    isChecked[index] = !isChecked[index];
                                    DataGestion.isChecked5 = isChecked;
                                    if (isChecked[index] == true) {
                                      selectedTypes.add(muscles[index]);
                                    } else {
                                      selectedTypes.remove(muscles[index]);
                                    }
                                  });
                                  DataGestion.selectedTypes = selectedTypes;
                                  widget.applyFilters(
                                    selectedTypes,
                                    selectedCategories,
                                  );
                                }),
                          );
                        })),
                    isExpanded: isExpanded[0],
                  ),
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
                        itemCount: categories.length,
                        itemBuilder: ((context, index) {
                          return ListTile(
                            tileColor: isChecked1[index] == false
                                ? Theme.of(context).listTileTheme.tileColor
                                : Colors.green,
                            title: Text(categories[index]),
                            trailing: Checkbox(
                                value: isChecked1[index],
                                onChanged: (val) {
                                  setState(() {
                                    isChecked1[index] = !isChecked1[index];
                                    DataGestion.isChecked6 = isChecked1;
                                    if (isChecked1[index] == true) {
                                      selectedCategories
                                          .add(categories[index][0]);
                                    } else {
                                      selectedCategories
                                          .remove(categories[index][0]);
                                    }
                                  });
                                  DataGestion.selectedCategories1 =
                                      selectedCategories;
                                  widget.applyFilters(
                                    selectedTypes,
                                    selectedCategories,
                                  );
                                }),
                          );
                        })),
                    isExpanded: isExpanded[1],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
