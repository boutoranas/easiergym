import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/auth/firebase_auth_methods.dart';
import 'package:flutter_app/screens/explore/explore.dart';
import 'package:flutter_app/screens/history/history.dart';
import 'package:flutter_app/screens/profile/profile.dart';
import 'package:flutter_app/screens/stats/stats.dart';
import 'package:flutter_app/screens/track/tracking.dart';
import 'package:flutter_app/screens/workout%20in%20progress/workout%20log.dart';
import 'package:flutter_app/screens/workout/workoutsection.dart';
import 'package:flutter_app/services/app_media_query.dart';
import 'package:flutter_app/services/custom_icons.dart';
import 'package:flutter_app/services/data_update.dart';
import 'package:flutter_app/services/notifications.dart';
import 'package:flutter_app/services/user_preferences.dart';
import 'package:flutter_app/widgets/snack_bar.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:path_provider/path_provider.dart';

import '../in app data.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with WidgetsBindingObserver {
  final userID = FirebaseAuth.instance.currentUser!.uid;
  late DatabaseReference database =
      FirebaseDatabase.instance.ref().child("users").child(userID);

  late DatabaseReference ref = FirebaseDatabase.instance
      .ref()
      .child("users")
      .child(userID)
      .child("easiergym");

  late Reference storageRef =
      FirebaseStorage.instance.ref().child("profile_images").child(userID);
  //app life cycle observer
  @override
  void initState() {
    //not first time anymore
    UserPreferences.setFirstTime(false);
    //get users local data
    DataGestion.userDataMap = UserPreferences.getUserDataMap();
    DataGestion.profileMap = UserPreferences.getProfileMap();
    Map? userData = DataGestion.userDataMap;
    //add back created exercices
    if (userData != null && userData["created"] != null) {
      InAppData.exercices.addAll(userData["created"]);
    }
    //retreive exercice history data
    if (userData != null && userData["logs"] != null) {
      Map exsHistory = json.decode(json.encode(InAppData.exercices));
      exsHistory.forEach((key, value) {
        exsHistory[key].addAll({"history": {}});
      });
      exsHistory.forEach((key, value) {
        userData["logs"].forEach((lk, lv) {
          if (userData["logs"][lk]["exercices"] != null) {
            userData["logs"][lk]["exercices"].forEach((ek, ev) {
              if (ev["name"] == key) {
                //int length = exsHistory[key]["history"].length;
                final newId = "$lk${ev["pos"]}";
                exsHistory[key]["history"].addAll({
                  newId: {
                    "id": newId,
                    "date": lv["tdate"],
                    "name": lv["name"],
                    "sets": ev["sets"],
                    "im": ev["im"],
                  }
                });
              }
            });
          }
        });
      });
      //calculate prs
      exsHistory.forEach((k, v) {
        int maxReps = 0;
        num maxWeight = 0;
        int maxVolumeReps = 0;
        num maxVolumeWeight = 0;
        exsHistory[k]["history"].forEach((kk, vv) {
          exsHistory[k]["history"][kk]["sets"].forEach((kkk, vvv) {
            if (vvv["reps"] != null && vvv["reps"] > maxReps) {
              maxReps = vvv["reps"];
            }
            if (vvv["weightinkg"] != null && vvv["weightinkg"] > maxWeight) {
              maxWeight = vvv["weightinkg"];
            }
            if (vvv["reps"] != null &&
                vvv["weightinkg"] != null &&
                vvv["reps"] * vvv["weightinkg"] >
                    maxVolumeReps * maxVolumeWeight) {
              maxVolumeWeight = vvv["weightinkg"];
              maxVolumeReps = vvv["reps"];
            }
          });
        });
        exsHistory[k]["prs"] = {
          "maxReps": maxReps,
          "maxWeight": maxWeight,
          "maxVolumeReps": maxVolumeReps,
          "maxVolumeWeight": maxVolumeWeight
        };
      });

      //most recent performance
      exsHistory.forEach((key, value) {
        List historyList;
        historyList = exsHistory[key]["history"].values.toList();
        historyList.sort(((a, b) => b["id"].compareTo(a["id"])));
        if (historyList.isNotEmpty) {
          Map? recent = historyList[0]["sets"];
          exsHistory[key]["recent"] = recent;
        }
      });
      DataGestion.exsHistory = exsHistory;
    } //no history
    else {
      Map exsHistory = json.decode(json.encode(InAppData.exercices));
      exsHistory.forEach((key, value) {
        exsHistory[key].addAll({"history": {}});
      });
      exsHistory.forEach((k, v) {
        int maxReps = 0;
        num maxWeight = 0;
        int maxVolumeReps = 0;
        num maxVolumeWeight = 0;
        exsHistory[k]["history"].forEach((kk, vv) {
          exsHistory[k]["history"][kk]["sets"].forEach((kkk, vvv) {
            if (vvv["reps"] != null && vvv["reps"] > maxReps) {
              maxReps = vvv["reps"];
            }
            if (vvv["weightinkg"] != null && vvv["weightinkg"] > maxWeight) {
              maxWeight = vvv["weightinkg"];
            }
            if (vvv["reps"] != null &&
                vvv["weightinkg"] != null &&
                vvv["reps"] * vvv["weightinkg"] >
                    maxVolumeReps * maxVolumeWeight) {
              maxVolumeWeight = vvv["weightinkg"];
              maxVolumeReps = vvv["reps"];
            }
          });
        });
        exsHistory[k]["prs"] = {
          "maxReps": maxReps,
          "maxWeight": maxWeight,
          "maxVolumeReps": maxVolumeReps,
          "maxVolumeWeight": maxVolumeWeight
        };
      });
      DataGestion.exsHistory = exsHistory;
    }
    //null protection
    if (DataGestion.userDataMapCopy != null &&
        DataGestion.userDataMapCopy!["routines"] != null &&
        DataGestion.userDataMapCopy!["routines"][rId] == null) {
      setState(() {
        workoutInProg = false;
        DataGestion.initTime = null;
      });
    }
    //observe life cycle
    WidgetsBinding.instance.addObserver(this);

    subscription = database.child("token").onValue.listen((event) async {
      final databaseToken = event.snapshot.value;
      if (UserPreferences.getSessionToken() != databaseToken) {
        signOutUser();
      }
    });

    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    //save userdatamap locally
    UserPreferences.saveUserDataMap(json.encode(DataGestion.userDataMap));

    //save workout in progress
    UserPreferences.saveLogInProgressMap(
        json.encode(DataGestion.userDataMapCopy));

    UserPreferences.setWorkoutInProgress(workoutInProg);

    if (DataGestion.initTime != null) {
      UserPreferences.saveInitTime(DataGestion.initTime!);
    } else {
      UserPreferences.removeInitTime();
    }

    DataGestion.endTime != null
        ? UserPreferences.saveEndTime(DataGestion.endTime!)
        : UserPreferences.removeEndTime();
    UserPreferences.setTimerStarted(DataGestion.timerStarted);
    UserPreferences.setTimerPaused(DataGestion.paused);
    UserPreferences.saveMaxSeconds(DataGestion.maxSeconds);
    UserPreferences.saveSeconds(DataGestion.seconds);

    //save on database
    ref.set(DataGestion.userDataMap);
    saveImageOnline();

    //notifications
    if (state != AppLifecycleState.resumed) {
      if (DataGestion.notificationsOn == true) {
        if (DataGestion.endTime != null &&
            DataGestion.endTime!.difference(DateTime.now()).inSeconds > 5) {
          Notifications.cancelNotifications();
          Notifications.showNotification(
            title: 'CountDown timer finished!',
            body: 'Tap here to contiue your workout',
            scheduled: true,
            interval: DataGestion.endTime!.difference(DateTime.now()).inSeconds,
          );
        } else {
          Notifications.cancelNotifications();
        }
      }
    }
    //check for notification authorization status
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) async {
      if (!isAllowed) {
        DataGestion.notificationsOn = false;
        UserPreferences.setNotificationsOn(false);
      }
    });

    if (state == AppLifecycleState.resumed) {}
    if (state == AppLifecycleState.inactive) {}
    if (state == AppLifecycleState.paused) {}
    if (state == AppLifecycleState.detached) {}
    super.didChangeAppLifecycleState(state);
  }

  /* late var subscription =
      ref.child("token").onChildChanged.listen((event) async {
    print("hdhiudeh");
    final databaseToken = await ref.child("token").get();
    if (UserPreferences.getSessionToken() != databaseToken.value) {
      FireBaseAuthMethods(FirebaseAuth.instance).signOut(context);
    }
  }); */

  saveImageOnline() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final dir = await getApplicationDocumentsDirectory();
    final file = '${dir.path}/$uid';
    bool exists = await File(file).exists();

    if (exists == true) {
      try {
        storageRef.putFile(File(file));
      } on FirebaseException catch (e) {
        print(e.message);
      }
    }
  }

  loadingIndicator(BuildContext context) {
    FocusManager.instance.primaryFocus?.unfocus();
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => WillPopScope(
              onWillPop: () async {
                return false;
              },
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ));
  }

  removeLocalData() {
    UserPreferences.deleteUserDataMap();
    UserPreferences.deleteProfileMap();
    UserPreferences.removeLogInProgress();
    UserPreferences.setWorkoutInProgress(false);
    UserPreferences.removeAssignedId();
    UserPreferences.removeInitTime();
    UserPreferences.removeEndTime();
    UserPreferences.removeSeconds();
    UserPreferences.setTimerStarted(false);
    UserPreferences.setTimerPaused(false);
    //UserPreferences.deleteImage();
  }

  removeProfileImage() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = '${dir.path}/$userID';

    bool exists = await File(file).exists();
    imageCache.clear();

    if (exists == true) {
      File(file).delete();
    }
  }

  signOutUser() async {
    //await UserPreferences.setConnectionState(false);
    Navigator.popUntil(context, (route) => route.isFirst);
    loadingIndicator(context);

    showSnackBar(
        context, "Someone signed in your account from another device!");
    await ref.set(DataGestion.userDataMap);
    await database.child("profile").set(DataGestion.profileMap);
    await saveImageOnline();
    FireBaseAuthMethods(FirebaseAuth.instance).signOut(context);
    await removeProfileImage();
    await removeLocalData();
    print("done");
  }

  late StreamSubscription<DatabaseEvent> subscription;

  @override
  void dispose() {
    subscription.cancel();
    WidgetsBinding.instance.removeObserver(this);
    controller.dispose();
    super.dispose();
  }

  String? rId = UserPreferences.getAssignedId();
  String? rName = "New routine";

  int currentIndex = 0; //horizontally
  int? actualPage = 0; //vertically

  bool workoutInProg = UserPreferences.getWorkoutInProgress();

  bool reduced(b) {
    return b;
  } //!not used

  bool minimized = true;

  late List pages;
  List<Widget> pageViewList(i) {
    if (workoutInProg == true) {
      return [
        pages[i],
        WorkoutLog(
          rId: rId,
          rName: rName,
          workoutEnd: workoutInProgress,
          reduced: reduced,
          reduce: reduce,
        ),
      ];
    } else {
      return [pages[i]];
    }
  }

  late var controller = PageController(
    viewportFraction: 0.999,
    initialPage: 0,
  );

  void workoutInProgress(bool b, String? id, String name) async {
    if (b == false) {
      reduce();
      await Future.delayed(const Duration(milliseconds: 500));
      DataGestion.initTime = null;
      UserPreferences.removeInitTime();
      UserPreferences.setWorkoutInProgress(false);
      //reset timer
      DataGestion.endTime = null;
      DataGestion.paused = false;
      DataGestion.timerStarted = false;
      DataGestion.seconds = DataGestion.maxSeconds;
      UserPreferences.removeEndTime();
      UserPreferences.saveSeconds(DataGestion.maxSeconds);
      UserPreferences.saveMaxSeconds(DataGestion.maxSeconds);
      UserPreferences.setTimerStarted(false);
      UserPreferences.setTimerPaused(false);
      setState(() {
        workoutInProg = b;
      });
    }

    if (b == true) {
      if (workoutInProg == true) {
        openDialog(b, id, name);
      } else {
        DataGestion.userDataMapCopy =
            json.decode(json.encode(DataGestion.userDataMap));
        setState(() {
          rId = id;
          rName = name;
          workoutInProg = b;
        });
        expand();
      }
    }
  }

  void onTap(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  void expand() async {
    await controller.animateToPage(
      1,
      duration: const Duration(milliseconds: 400),
      curve: Curves.linear,
    );
    setState(() {
      minimized = false;
    });
  }

  void reduce() async {
    await controller.animateToPage(
      0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.linear,
    );
    setState(() {
      minimized = true;
    });
  }

  openDialog(b, id, name) {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text("End routine?"),
              content: const Text(
                  "Are you sure you want to end this routine? All changes will be lost!"),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Cancel")),
                TextButton(
                    onPressed: () async {
                      //pop page
                      Navigator.pop(context);
                      //end current routine
                      DataGestion.userDataMapCopy =
                          json.decode(json.encode(DataGestion.userDataMap));
                      setState(() {
                        rId = id;
                        rName = name;
                        workoutInProg = !b;
                      });
                      await Future.delayed(const Duration(milliseconds: 300));
                      DataGestion.initTime = null;
                      DataGestion.endTime = null;
                      DataGestion.paused = false;
                      DataGestion.timerStarted = false;
                      UserPreferences.setTimerStarted(false);
                      UserPreferences.setTimerPaused(false);
                      setState(() {
                        workoutInProg = b;
                      });
                      expand();
                    },
                    child: const Text("End")),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    pages = [
      WorkoutSection(
        expandWhenWk: expand,
        workoutInProg: workoutInProg,
        workoutInProgress: workoutInProgress,
      ),
      Tracking(
        expandWhenWk: expand,
        workoutInProg: workoutInProg,
      ),
      ExploreSection(
        expandWhenWk: expand,
        workoutInProg: workoutInProg,
        navigateBackToWkSection: onTap,
      ),
      /* HistorySection(
        expandWhenWk: expand,
        workoutInProg: workoutInProg,
        navigateBackToWkSection: onTap,
      ), */
      /* StatsSection(
        expandWhenWk: expand,
        workoutInProg: workoutInProg,
      ), */
      ProfileSection(
        expandWhenWk: expand,
        workoutInProg: workoutInProg,
      ),
    ];

    /* //prevent user from staying connected if he is disconnected
    if (UserPreferences.getConnectionState() == false &&
        FirebaseAuth.instance.currentUser != null) {
      FireBaseAuthMethods(FirebaseAuth.instance).signOut(context);
    } */

    return WillPopScope(
      onWillPop: () async {
        if (minimized == true) {
          return true;
        } else {
          reduce();
          return false;
        }
      },
      child: Scaffold(
        //resizeToAvoidBottomInset: false,
        body: PageView(
          physics: const NeverScrollableScrollPhysics(),
          scrollDirection: Axis.vertical,
          padEnds: false,
          controller: controller,
          onPageChanged: (int page) {
            setState(() {
              actualPage = page;
            });
          },
          children: pageViewList(currentIndex),
        ),
        bottomNavigationBar: (actualPage == 0)
            ? Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).bottomAppBarTheme.color!,
                  /* border: const Border(
                      top: BorderSide(
                        width: 1,
                        color: Colors.black,
                      ),
                    ) */
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      spreadRadius: 4,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                padding: EdgeInsets.only(
                  left: 10,
                  right: 10,
                  top: 6,
                  bottom: AppMediaQuerry.mq.padding.bottom + 6,
                ),
                //Color.fromARGB(255, 22, 22, 22),
                child: GNav(
                  selectedIndex: currentIndex,
                  /* color: Colors.white,
                  activeColor: Colors.white, */
                  //tabBackgroundColor: Colors.grey.shade800,
                  /* tabActiveBorder: Border.all(
                    width: 2,
                    color: Theme.of(context)
                        .inputDecorationTheme
                        .border!
                        .borderSide
                        .color,
                  ), */
                  tabBackgroundColor:
                      Theme.of(context).colorScheme.background.withOpacity(0.4),
                  backgroundColor: Theme.of(context).bottomAppBarTheme.color!,
                  gap: 8,
                  padding:
                      const EdgeInsets.symmetric(vertical: 11, horizontal: 14),
                  onTabChange: onTap,
                  tabs: const [
                    GButton(
                      icon: CustomIcons.workout,
                      //Icons.sports_gymnastics,
                      text: 'Workout',
                    ),
                    GButton(
                      icon: Icons.book,
                      text: 'Track',
                    ),
                    GButton(
                      icon: Icons.explore,
                      text: 'Explore',
                    ),
                    /* GButton(
                      icon: Icons.history,
                      text: 'History',
                    ), */
                    /* GButton(
                      icon: Icons.trending_up,
                      text: 'Stats',
                    ), */
                    GButton(
                      icon: Icons.person,
                      text: 'Profile',
                    ),
                  ],
                ),
              )
            : null,
      ),
    );
  }
}
