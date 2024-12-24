import 'dart:convert';
import 'dart:developer';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/screens/history/history.dart';
import 'package:flutter_app/services/data_update.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_app/widgets/resume workout bar.dart';
import 'package:flutter_app/widgets/snack_bar.dart';
import '../../const.dart';
import '../../services/user_preferences.dart';
import '../../widgets/button.dart';
import '../../widgets/custom appbar.dart';
import 'local widgets/routine_card.dart';

class WorkoutSection extends StatefulWidget {
  final Function workoutInProgress;
  final Function expandWhenWk;
  final bool workoutInProg;
  const WorkoutSection(
      {super.key,
      required this.workoutInProgress,
      required this.workoutInProg,
      required this.expandWhenWk});

  @override
  State<WorkoutSection> createState() => _WorkoutSectionState();
}

class _WorkoutSectionState extends State<WorkoutSection> with RouteAware {
  //!controllers
  final routineInputController = TextEditingController();
  ScrollController scrollController = ScrollController();
  TextEditingController searchController = TextEditingController();

  //!database
  final userID = FirebaseAuth.instance.currentUser!.uid;
  late DatabaseReference database =
      FirebaseDatabase.instance.ref().child("users").child(userID);

  late DatabaseReference ref = FirebaseDatabase.instance
      .ref()
      .child("users")
      .child(userID)
      .child("easiergym");

  //!user data
  Map? userDataMap = DataGestion.userDataMap;
  List routinesList = DataGestion.routinesList(DataGestion.userDataMap);

  List foundRoutines = [];

  final GlobalKey<SliverAnimatedListState> _globalKey = GlobalKey();

  @override
  void initState() {
    foundRoutines = routinesList;
    super.initState();
  }

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
  void didPopNext() {
    setState(() {});
    super.didPopNext();
  }

  //!functions
  void updateState() {
    setState(() {});
  }

  startEmptyWorkout() {
    widget.workoutInProgress(true, null, "New routine");
  }

  showRoutineCreationDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text('Create a routine'),
              content: TextField(
                maxLength: 250,
                controller: routineInputController,
                autofocus: true,
                decoration: const InputDecoration(
                    hintText: 'Enter your routine\'s name', counterText: ''),
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    if (routineInputController.text.isNotEmpty) {
                      //create key and map
                      final routineKey = ref.child("routines").push();
                      final newRoutine = <String, dynamic>{
                        'name': routineInputController.text,
                        'id': routineKey.key,
                      };

                      //Create routine locally
                      if (userDataMap != null &&
                          userDataMap!["routines"] != null) {
                        userDataMap!["routines"].addAll(
                            {routineKey.key as String: newRoutine as dynamic});
                      } else if (userDataMap == null) {
                        userDataMap = {
                          "routines": {
                            routineKey.key as String: newRoutine as dynamic
                          }
                        };
                      } else {
                        userDataMap!["routines"] = {
                          routineKey.key as String: newRoutine as dynamic
                        };
                      }
                      DataGestion.userDataMap = userDataMap;
                      UserPreferences.saveUserDataMap(
                          json.encode(DataGestion.userDataMap));

                      setState(() {
                        routinesList =
                            DataGestion.routinesList(DataGestion.userDataMap);
                      });
                      //addItemAnimated();

                      //pop page
                      Navigator.of(context).pop();
                      routineInputController.clear();
                    } else {
                      showSnackBar(context, 'You need to enter a name!');
                    }
                  },
                  child: const Text('Enter'),
                ),
              ],
            ));
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
      for (var element in routinesList) {
        if (removeSpecialCaracters(element["name"]).startsWith(searchTerm)) {
          same1stLetters.add(element);
        }
      }

      results = same1stLetters;

      List notSameLetters = [];
      for (var element in routinesList) {
        if (!removeSpecialCaracters(element["name"]).startsWith(searchTerm)) {
          notSameLetters.add(element);
        }
      }

      results.addAll(notSameLetters.where((element) {
        return removeSpecialCaracters(element["name"]).contains(searchTerm);
      }).toList());
    } else {
      results = routinesList;
    }
    setState(() {
      foundRoutines = results;
    });
  }

  /* addItemAnimated() {
    _globalKey.currentState!.insertItem(routinesList.length - 1,
        duration: const Duration(seconds: 1));
  }

  removeItemAnimated(int index) {
    _globalKey.currentState!.removeItem(
      index,
      (context, animation) {
        return SizeTransition(
          sizeFactor: animation,
          child: FadeTransition(
            opacity: animation,
            child: Container(
              color: Colors.red,
            ),
          ),
        );
      },
      duration: const Duration(milliseconds: 300),
    );
  } */

  @override
  Widget build(BuildContext context) {
    userDataMap = DataGestion.userDataMap;
    routinesList = DataGestion.routinesList(userDataMap);
    getSearchResults();
    log(userDataMap.toString());
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: customAppBar(title: 'Workout', context: context, actions: [
        IconButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => HistorySection(),
            ));
          },
          icon: Icon(Icons.history),
          splashRadius: 22,
          tooltip: 'History',
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.trending_up_rounded),
          splashRadius: 22,
          tooltip: 'Evolution',
        ),
      ]),
      body: Column(
        children: [
          //Quick start
          Expanded(
            child: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: Const.horizontalPagePadding),
              child: FadingEdgeScrollView.fromScrollView(
                child: CustomScrollView(
                  controller: scrollController,
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(top: 7),
                        margin: const EdgeInsets.only(top: 15, bottom: 10),
                        child: const Text(
                          'Quick start',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    //Start empty wk button
                    SliverToBoxAdapter(
                      child: button(
                        context: context,
                        text: 'Start empty workout',
                        icon: Icons.add,
                        onPressed: () {
                          startEmptyWorkout();
                        },
                      ),
                    ),

                    //myprograms
                    SliverToBoxAdapter(
                      child: Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(top: 3),
                        margin: const EdgeInsets.only(top: 15, bottom: 10),
                        child: const Text(
                          'My routines',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    //button adding routines
                    SliverToBoxAdapter(
                      child: Row(
                        children: [
                          Expanded(
                            flex: 11,
                            child: SizedBox(
                              height: 45,
                              child: SearchBar(
                                  controller: searchController,
                                  onChanged: (value) {
                                    getSearchResults();
                                  },
                                  elevation: MaterialStatePropertyAll(2),
                                  leading: Row(
                                    children: [
                                      SizedBox(
                                        width: 3,
                                      ),
                                      Icon(Icons.search),
                                    ],
                                  )),
                            ),
                            /* button(
                              context: context,
                              onPressed: () {},
                              text: 'Search',
                              color: Colors.grey,
                            ), */
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Expanded(
                            flex: 2,
                            child: MaterialButton(
                              height: 45,
                              color: Theme.of(context).primaryColor,
                              //elevation: elevation,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              onPressed: () {
                                showRoutineCreationDialog();
                              },
                              child: Icon(
                                Icons.add,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SliverToBoxAdapter(
                        child: Padding(padding: EdgeInsets.only(top: 10))),
                    //listview builder of map of routines data
                    (routinesList.isNotEmpty)
                        ? SliverList.builder(
                            itemCount: foundRoutines.length,
                            itemBuilder: (context, i) {
                              foundRoutines
                                  .sort((a, b) => b["id"].compareTo(a["id"]));
                              return RoutineCard(
                                  key: UniqueKey(),
                                  workoutInProgress: widget.workoutInProgress,
                                  updateState: updateState,
                                  name: foundRoutines[i]["name"],
                                  id: foundRoutines[i]["id"]);
                            })
                        /* SliverAnimatedList(
                            key: _globalKey,
                            initialItemCount: routinesList.length,
                            itemBuilder: (context, i, animation) {
                              routinesList
                                  .sort((a, b) => b["id"].compareTo(a["id"]));
                              return RoutineCard(
                                  key: UniqueKey(),
                                  workoutInProgress: widget.workoutInProgress,
                                  updateState: updateState,
                                  name: routinesList[i]["name"],
                                  id: routinesList[i]["id"]);
                            },
                          ) */
                        : const SliverToBoxAdapter(
                            child: Center(child: Text("Add a routine"))),
                  ],
                ),
              ),
            ),
          ),

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
          )
        ],
      ),
    );
  }
}
