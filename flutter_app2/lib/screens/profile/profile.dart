import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/const.dart';
import 'package:flutter_app/screens/profile/edit_profile.dart';
import 'package:flutter_app/screens/profile/exercices_profile_page.dart';
import 'package:flutter_app/screens/profile/settings%20page.dart';
import 'package:flutter_app/widgets/button.dart';
import 'package:flutter_app/widgets/custom%20appbar.dart';
import 'package:path_provider/path_provider.dart';

import '../../auth/firebase_auth_methods.dart';
import '../../main.dart';
import '../../services/check_connectivity.dart';
import '../../services/custom_icons.dart';
import '../../services/data_update.dart';
import '../../services/user_preferences.dart';
import '../../widgets/resume workout bar.dart';
import '../../widgets/snack_bar.dart';
import '../stats/measurements page.dart';
import '../subscriptions/subscription_main.dart';

class ProfileSection extends StatefulWidget {
  final Function expandWhenWk;
  final bool workoutInProg;
  const ProfileSection(
      {super.key, required this.expandWhenWk, required this.workoutInProg});

  @override
  State<ProfileSection> createState() => _ProfileSectionState();
}

class _ProfileSectionState extends State<ProfileSection> with RouteAware {
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

  Map? userDataMap = DataGestion.userDataMap;
  Map? profileMap = DataGestion.profileMap;

  String uid = FirebaseAuth.instance.currentUser!.uid;

  String userName = '';
  assignUserName() {
    if (profileMap != null && profileMap!["displayname"] != null) {
      userName = profileMap!["displayname"];
    } else {
      if (FirebaseAuth.instance.currentUser!.displayName != null &&
          FirebaseAuth.instance.currentUser!.displayName! != '') {
        userName = FirebaseAuth.instance.currentUser!.displayName!;
      } else {
        userName = FirebaseAuth.instance.currentUser!.email!.split('@').first;
      }
    }
  }

  late Future<String> imagePath;

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
    userDataMap = DataGestion.userDataMap;
    profileMap = DataGestion.profileMap;
    assignUserName();
    //assignImage();
    imagePath = getImagePath();
    final dir = await getApplicationDocumentsDirectory();
    final file = '${dir.path}/$uid(temporary)';

    bool exists = await File(file).exists();
    imageCache.clear();

    if (exists == true) {
      File(file).delete();
    }
    setState(() {});
    super.didPopNext();
  }

  @override
  void initState() {
    assignUserName();
    imagePath = getImagePath();
    //assignImage();
    super.initState();
  }

  Future<String> getImagePath() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = '${dir.path}/$uid';
    bool exists = await File(file).exists();
    imageCache.clear();

    if (exists == true) {
      FileImage(File(file)).evict();
      return file;
    } else {
      return '';
    }
  }

  Widget optionCard({
    required String title,
    IconData? icon,
    required Function onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(
        left: 4,
        right: 4,
        top: 4,
        bottom: 12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 0,
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () {
          onTap();
        },
        title: Text(title),
        trailing: icon != null ? Icon(icon) : null,
      ),
    );
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

  saveImageOnline() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final dir = await getApplicationDocumentsDirectory();
    final file = '${dir.path}/$uid';
    bool exists = await File(file).exists();

    if (exists == true) {
      await storageRef.putFile(File(file)).timeout(Duration(seconds: 15));
    }
  }

  removeProfileImage() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = '${dir.path}/$uid';

    bool exists = await File(file).exists();
    imageCache.clear();

    if (exists == true) {
      File(file).delete();
    }
  }

  signOutUser(bool connected) async {
    loadingIndicator(context);

    if (connected == true) {
      try {
        showSnackBar(context, "syncing your data...");
        await ref.set(DataGestion.userDataMap).timeout(Duration(seconds: 15));
        await database
            .child("profile")
            .set(DataGestion.profileMap)
            .timeout(Duration(seconds: 15));
        await saveImageOnline();

        FireBaseAuthMethods(FirebaseAuth.instance).signOut(context);
        await removeProfileImage();
        await removeLocalData();
      } on TimeoutException catch (e) {
        Navigator.pop(context);
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("An error has occured!"),
                content: const Text(
                    '''Your data could not be saved online. If you still want to continue, logging out will result in the loss of this data.'''),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      signOutUser(false);
                    },
                    child: const Text(
                      "Sign out",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              );
            });
      }
    } else {
      await removeProfileImage();
      await removeLocalData();
      FireBaseAuthMethods(FirebaseAuth.instance).signOut(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
          title: 'Profile',
          leading: null,
          actions: [
            IconButton(
                tooltip: 'Settings',
                padding: const EdgeInsets.all(5),
                constraints: const BoxConstraints(),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Settings(
                                signOut: signOutUser,
                              )));
                },
                icon: const Icon(Icons.settings)),
          ],
          context: context),
      body: Column(
        children: [
          Expanded(
            flex: 100,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(padding: EdgeInsets.only(bottom: 30)),
                  Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          width: 1,
                        )),
                    child: FutureBuilder(
                      future: imagePath,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState != ConnectionState.done) {
                          return const CircleAvatar(
                              backgroundImage: null,
                              maxRadius: 45,
                              child: CircularProgressIndicator());
                        } else if (!snapshot.hasData ||
                            snapshot.hasError ||
                            snapshot.data == '') {
                          return CircleAvatar(
                            backgroundImage: null,
                            maxRadius: 45,
                            child: Text(
                              userName[0].toUpperCase(),
                              style: const TextStyle(
                                fontSize: 38,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        } else {
                          return CircleAvatar(
                            backgroundImage:
                                Image.file(File(snapshot.data!)).image,
                            maxRadius: 45,
                            child: null,
                          );
                        }
                      },
                    ),
                  ),
                  const Padding(padding: EdgeInsets.only(bottom: 10)),
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    FirebaseAuth.instance.currentUser!.email!,
                    style: const TextStyle(
                      fontWeight: FontWeight.w300,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Padding(padding: EdgeInsets.only(bottom: 20)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 70),
                    child: button(
                      icon: CustomIcons.premium,
                      color: const Color.fromARGB(255, 230, 195, 0),
                      context: context,
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const SubscriptionMain()));
                      },
                      text: "Upgrade to Pro",
                    ),
                  ),
                  const Padding(padding: EdgeInsets.only(bottom: 30)),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: Const.horizontalPagePadding),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        optionCard(
                          title: 'Edit profile',
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const EditProfile()));
                          },
                          icon: Icons.edit,
                        ),
                        optionCard(
                            title: 'Add measurements',
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          MeasurementsPage()));
                            },
                            icon: Icons.add),
                        optionCard(
                            title: 'Exercices',
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const ExercicesProfilePage()));
                            },
                            icon: Icons.arrow_forward_ios),
                        optionCard(
                            title: 'Sign out',
                            onTap: () async {
                              bool connected =
                                  await CheckConnectivity.checkConnectivity();
                              if (connected == true) {
                                signOutUser(connected);
                              } else {
                                // ignore: use_build_context_synchronously
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text("Warning!"),
                                        content: const Text(
                                            '''You are currently offline and your data has not been synced, logging out will result in the loss of this data.'''),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text("Cancel"),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              signOutUser(connected);
                                            },
                                            child: const Text(
                                              "Sign out",
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                          ),
                                        ],
                                      );
                                    });
                              }
                            },
                            icon: Icons.logout),
                      ],
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
