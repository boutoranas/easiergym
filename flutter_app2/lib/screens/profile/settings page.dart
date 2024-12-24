import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/screens/profile/change_email.dart';
import 'package:flutter_app/screens/profile/change_password.dart';
import 'package:flutter_app/screens/profile/policies.dart';
import 'package:flutter_app/services/check_connectivity.dart';
import 'package:flutter_app/services/data_update.dart';
import 'package:flutter_app/services/user_preferences.dart';
import 'package:flutter_app/widgets/custom%20appbar.dart';
import 'package:flutter_app/widgets/snack_bar.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wakelock/wakelock.dart';
import '../../auth/firebase_auth_methods.dart';
import '../../theme/theme.dart';

class Settings extends StatefulWidget {
  final Function signOut;
  const Settings({super.key, required this.signOut});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  ScrollController scrollController = ScrollController();

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

  String weightUnit = "kg";
  String distanceUnit = "km";
  String sizeUnit = "cm";

  String theme = DataGestion.theme;

  bool soundOn = DataGestion.soundOn;

  bool notificationsOn = DataGestion.notificationsOn;

  bool keepScreenOn = DataGestion.keepScreenOn;

  /* removeLocalData() {
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
  } */

  saveLocalData() {
    UserPreferences.saveUserDataMap(json.encode(DataGestion.userDataMap));
  }

  late Image image1;
  late Image image2;
  late Image image3;

  @override
  void initState() {
    if (DataGestion.weightImperial == true) {
      weightUnit = "lbs";
    }
    if (DataGestion.distanceImperial == true) {
      distanceUnit = "miles";
    }
    if (DataGestion.sizeImperial == true) {
      sizeUnit = "in";
    }
    super.initState();

    image1 = Image.asset('assets/images/Instagram_icon.png');
    image2 = Image.asset('assets/images/tiktok_icon.png');
    image3 = Image.asset('assets/images/youtube_icon.png');

    AwesomeNotifications().isNotificationAllowed().then((isAllowed) async {
      if (!isAllowed) {
        DataGestion.notificationsOn = false;
        UserPreferences.setNotificationsOn(false);
      }
    });
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    precacheImage(image1.image, context);
    precacheImage(image2.image, context);
    precacheImage(image3.image, context);
  }

  //Loading dialog
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

  String uid = FirebaseAuth.instance.currentUser!.uid;

  /* removeProfileImage() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = '${dir.path}/$uid';

    bool exists = await File(file).exists();
    imageCache.clear();

    if (exists == true) {
      File(file).delete();
    }
  } */

  /* signOutUser(bool connected) async {
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
        await removeProfileImage();
        await removeLocalData();
        Navigator.pop(context);
        FireBaseAuthMethods(FirebaseAuth.instance).signOut(context);
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
      Navigator.pop(context);
      FireBaseAuthMethods(FirebaseAuth.instance).signOut(context);
    }
  } */

  Future<void> _launchInBrowser(String host, String path) async {
    final Uri uri = Uri(scheme: "https", host: host, path: path);
    if (!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch url');
    }
  }

  Future<PackageInfo> getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo;
  }

  TextStyle titlesStyle = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 18,
  );

  getDeviceInfo() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo deviceInfo;
      deviceInfo = await deviceInfoPlugin.androidInfo;
      return '${deviceInfo.product}, ${deviceInfo.model}';
    } else if (Platform.isIOS) {
      IosDeviceInfo deviceInfo;
      deviceInfo = await deviceInfoPlugin.iosInfo;
      return '${deviceInfo.model}, ${deviceInfo.systemVersion}';
    } else {
      return '';
    }
  }

  downloadProfileImage() async {
    Reference storageRef =
        FirebaseStorage.instance.ref().child('profile_images').child(uid);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$uid');
    await storageRef.writeToFile(file).timeout(Duration(seconds: 15));
    //UserPreferences.setImage(file.path);
  }

  getUserData() async {
    try {
      loadingIndicator(context);
      await downloadProfileImage();

      final DataSnapshot dataSnapshot =
          await ref.get().timeout(Duration(seconds: 15));
      final userData = dataSnapshot.value as Map?;
      DataGestion.userDataMap = userData;
      await UserPreferences.saveUserDataMap(
          json.encode(DataGestion.userDataMap));

      DataSnapshot profileMapSnapshot = await FirebaseDatabase.instance
          .ref()
          .child("users")
          .child(uid)
          .child("profile")
          .get()
          .timeout(Duration(seconds: 15));
      Map? profileMap = profileMapSnapshot.value as Map?;
      DataGestion.profileMap = profileMap;
      await UserPreferences.saveProfileMap(json.encode(profileMap));
      Navigator.pop(context);
      showSnackBar(context, 'Data successfully recovered!');
    } on TimeoutException catch (e) {
      Navigator.pop(context);
      showSnackBar(context, 'An error has occured');
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: customAppBar(
          title: 'Settings', leading: null, actions: null, context: context),
      body: FadingEdgeScrollView.fromSingleChildScrollView(
        child: SingleChildScrollView(
          controller: scrollController,
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              //!units
              const Padding(padding: EdgeInsets.only(bottom: 15)),
              Text(
                "Units",
                style: titlesStyle,
              ),
              const Padding(padding: EdgeInsets.only(bottom: 5)),
              ListTile(
                title: const Text("Weight"),
                trailing: PopupMenuButton(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        weightUnit,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        width: 16,
                        child: Icon(
                          Icons.arrow_drop_down,
                        ),
                      ),
                    ],
                  ),
                  itemBuilder: (context) {
                    return [
                      const PopupMenuItem(
                        value: "kg",
                        child: Text("kg"),
                      ),
                      const PopupMenuItem(
                        value: "lbs",
                        child: Text("lbs"),
                      ),
                    ];
                  },
                  onSelected: (value) {
                    setState(() {
                      weightUnit = value;
                    });

                    if (value == "kg") {
                      DataGestion.weightImperial = false;
                      UserPreferences.setWeightUnit(false);
                    } else {
                      DataGestion.weightImperial = true;
                      UserPreferences.setWeightUnit(true);
                    }
                  },
                ),
              ),
              ListTile(
                title: const Text("Distance"),
                trailing: PopupMenuButton(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        distanceUnit,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        width: 16,
                        child: Icon(
                          Icons.arrow_drop_down,
                        ),
                      ),
                    ],
                  ),
                  itemBuilder: (context) {
                    return [
                      const PopupMenuItem(
                        value: "km",
                        child: Text("km"),
                      ),
                      const PopupMenuItem(
                        value: "miles",
                        child: Text("miles"),
                      ),
                    ];
                  },
                  onSelected: (value) {
                    setState(() {
                      distanceUnit = value;
                    });
                    if (value == "km") {
                      DataGestion.distanceImperial = false;
                      UserPreferences.setDistanceUnit(false);
                    } else {
                      DataGestion.distanceImperial = true;
                      UserPreferences.setDistanceUnit(true);
                    }
                  },
                ),
              ),
              ListTile(
                title: const Text("Size"),
                trailing: PopupMenuButton(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        sizeUnit,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        width: 16,
                        child: Icon(
                          Icons.arrow_drop_down,
                        ),
                      ),
                    ],
                  ),
                  itemBuilder: (context) {
                    return [
                      const PopupMenuItem(
                        value: "cm",
                        child: Text("cm"),
                      ),
                      const PopupMenuItem(
                        value: "in",
                        child: Text("in"),
                      ),
                    ];
                  },
                  onSelected: (value) {
                    setState(() {
                      sizeUnit = value;
                    });
                    if (value == "cm") {
                      DataGestion.sizeImperial = false;
                      UserPreferences.setSizeUnit(false);
                    } else {
                      DataGestion.sizeImperial = true;
                      UserPreferences.setSizeUnit(true);
                    }
                  },
                ),
              ),
              //!preferences
              const Padding(padding: EdgeInsets.only(bottom: 5)),
              Text(
                "Preferences",
                style: titlesStyle,
              ),
              const Padding(padding: EdgeInsets.only(bottom: 5)),
              ListTile(
                title: const Text('Theme'),
                trailing: PopupMenuButton(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        theme,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        width: 16,
                        child: Icon(
                          Icons.arrow_drop_down,
                        ),
                      ),
                    ],
                  ),
                  itemBuilder: (context) {
                    return const [
                      PopupMenuItem(
                        value: 'Default',
                        child: Text('Default (system)'),
                      ),
                      PopupMenuItem(
                        value: 'Light',
                        child: Text('Light theme'),
                      ),
                      PopupMenuItem(
                        value: 'Dark',
                        child: Text('Dark theme'),
                      ),
                    ];
                  },
                  onSelected: (value) {
                    setState(() {
                      theme = value;
                    });
                    DataGestion.theme = theme;
                    UserPreferences.saveTheme(theme);
                    provider.changeTheme(value);
                    //changeTheme(value);
                  },
                ),
              ),
              ListTile(
                title: const Text('Sound effects'),
                trailing: SizedBox(
                  width: 40,
                  child: Switch(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    value: soundOn,
                    onChanged: (value) {
                      setState(() {
                        soundOn = value;
                      });
                      UserPreferences.setSoundOn(value);
                      DataGestion.soundOn = value;
                    },
                  ),
                ),
              ),
              ListTile(
                title: const Text('Notifications'),
                trailing: SizedBox(
                  width: 40,
                  child: Switch(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    value: notificationsOn,
                    onChanged: (value) async {
                      if (value == true) {
                        await AwesomeNotifications()
                            .isNotificationAllowed()
                            .then((isAllowed) async {
                          if (!isAllowed) {
                            await AwesomeNotifications()
                                .requestPermissionToSendNotifications();
                            AwesomeNotifications()
                                .isNotificationAllowed()
                                .then((isAllowed) async {
                              if (isAllowed) {
                                setState(() {
                                  notificationsOn = value;
                                });
                                UserPreferences.setNotificationsOn(value);
                                DataGestion.notificationsOn = value;
                              }
                            });
                          } else {
                            setState(() {
                              notificationsOn = value;
                            });
                            UserPreferences.setNotificationsOn(value);
                            DataGestion.notificationsOn = value;
                          }
                        });
                      } else {
                        setState(() {
                          notificationsOn = value;
                        });
                        UserPreferences.setNotificationsOn(value);
                        DataGestion.notificationsOn = value;
                      }
                    },
                  ),
                ),
              ),
              ListTile(
                title: const Text('Keep screen on'),
                trailing: SizedBox(
                  width: 40,
                  child: Switch(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    value: keepScreenOn,
                    onChanged: (value) async {
                      setState(() {
                        keepScreenOn = value;
                      });
                      UserPreferences.setKeepScreenOn(value);
                      DataGestion.keepScreenOn = value;
                      if (value == true) {
                        Wakelock.enable();
                      } else {
                        Wakelock.disable();
                      }
                    },
                  ),
                ),
              ),
              const Padding(padding: EdgeInsets.only(bottom: 5)),

              //!Account
              Text(
                "Account",
                style: titlesStyle,
              ),
              const Padding(padding: EdgeInsets.only(bottom: 5)),
              const ListTile(
                title: Text(
                  'Manage subscription',
                  style: TextStyle(
                    color: Colors.orange,
                  ),
                ),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
              ListTile(
                onTap: () async {
                  bool connected = await CheckConnectivity.checkConnectivity();
                  saveLocalData();
                  if (connected == true) {
                    try {
                      loadingIndicator(context);
                      await ref
                          .set(DataGestion.userDataMap)
                          .timeout(Duration(seconds: 15));
                      await database
                          .child("profile")
                          .set(DataGestion.profileMap)
                          .timeout(Duration(seconds: 15));
                      await saveImageOnline();
                      Navigator.pop(context);
                      showSnackBar(context, "Data saved successfully!");
                    } on TimeoutException catch (e) {
                      Navigator.pop(context);
                      showSnackBar(context, "An error has occured");
                    }
                  } else {
                    showSnackBar(context, "No internet");
                  }
                },
                title: const Text("Sync data"),
                trailing: const Icon(Icons.sync),
              ),
              ListTile(
                onTap: () async {
                  bool connected = await CheckConnectivity.checkConnectivity();
                  if (connected == true) {
                    // ignore: use_build_context_synchronously
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("Warning!"),
                          content: const Text(
                              '''The data you'll be recovering comes from an online database, which means that it could potentially be different than the one stored on this device. Recovering the data would overwrite the current existing data!'''),
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
                                getUserData();
                              },
                              child: const Text(
                                "Recover",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    showSnackBar(context, "No internet");
                  }
                },
                title: const Text("Recover data"),
                trailing: const Icon(Icons.cloud_download),
              ),
              FirebaseAuth.instance.currentUser!.providerData[0].providerId ==
                      'password'
                  ? ListTile(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ChangeEmail()));
                      },
                      title: const Text('Change email'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                    )
                  : Container(),
              FirebaseAuth.instance.currentUser!.providerData[0].providerId ==
                      'password'
                  ? ListTile(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ChangePassword()));
                      },
                      title: const Text('Change password'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                    )
                  : Container(),
              ListTile(
                onTap: () async {
                  bool connected = await CheckConnectivity.checkConnectivity();
                  if (connected == true) {
                    Navigator.pop(context);
                    widget.signOut(connected);
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
                                  Navigator.pop(context);
                                  widget.signOut(connected);
                                  //signOutUser(connected);
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
                },
                title: const Text(
                  'Sign out',
                  style: TextStyle(color: Colors.red),
                ),
                trailing: const Icon(
                  Icons.logout,
                ),
              ),
              const Padding(padding: EdgeInsets.only(bottom: 5)),
              Text(
                "Info and support",
                style: titlesStyle,
              ),
              const Padding(padding: EdgeInsets.only(bottom: 5)),
              /* ListTile(
                title: Text('Help center'),
                trailing: Icon(Icons.arrow_forward_ios),
              ), */
              ListTile(
                onTap: () async {
                  String? encodeQueryParameters(Map<String, String> params) {
                    return params.entries
                        .map((MapEntry<String, String> e) =>
                            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
                        .join('&');
                  }

                  String? deviceModel = await getDeviceInfo();
                  final String uid = FirebaseAuth.instance.currentUser!.uid;
                  final String version = (await getAppVersion()).version;
                  final Uri emailUri = Uri(
                      scheme: 'mailto',
                      path: 'easiergym@gmail.com',
                      query: encodeQueryParameters(<String, String>{
                        'subject':
                            'Problem report for Easier gym v$version, from $uid, device model: $deviceModel',
                        'body': '''''',
                      }));

                  if (await canLaunchUrl(emailUri)) {
                    try {
                      launchUrl(emailUri);
                    } catch (e) {
                      showSnackBar(context,
                          "Could not launch url, please try to contact us at easiergym@gmail.com");
                    }
                  } else {
                    showSnackBar(context,
                        "Could not launch url, please try to contact us at easiergym@gmail.com");
                  }
                },
                title: const Text(
                  'Report an issue',
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
              ),
              ListTile(
                onTap: () async {
                  String? encodeQueryParameters(Map<String, String> params) {
                    return params.entries
                        .map((MapEntry<String, String> e) =>
                            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
                        .join('&');
                  }

                  final String version = (await getAppVersion()).version;
                  final Uri emailUri = Uri(
                      scheme: 'mailto',
                      path: 'easiergym@gmail.com',
                      query: encodeQueryParameters(<String, String>{
                        'subject':
                            'New feature request for Easier Gym v$version',
                        'body': '',
                      }));
                  if (await canLaunchUrl(emailUri)) {
                    try {
                      launchUrl(emailUri);
                    } catch (e) {
                      showSnackBar(context,
                          "Could not launch url, please try to contact us at easiergym@gmail.com");
                    }
                  } else {
                    showSnackBar(context,
                        "Could not launch url, please try to contact us at easiergym@gmail.com");
                  }
                },
                title: const Text(
                  'Request new feature',
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
              ),
              ListTile(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PoliciesPage(
                                policy: 'Privacy policy',
                              )));
                },
                title: const Text(
                  'Privacy policy',
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
              ),
              ListTile(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PoliciesPage(
                                policy: 'Terms of use',
                              )));
                },
                title: const Text(
                  'Terms of use',
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
              ),
              ListTile(
                title: const Text(
                  'Version',
                ),
                trailing: FutureBuilder(
                  future: getAppVersion(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (snapshot.hasError || !snapshot.hasData) {
                      return Text(snapshot.hasError.toString());
                    } else {
                      return Text(snapshot.data!.version);
                    }
                  },
                ),
              ),
              const Padding(padding: EdgeInsets.only(bottom: 5)),
              Text(
                "Follow us",
                style: titlesStyle,
              ),
              const Padding(padding: EdgeInsets.only(bottom: 15)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  //tiktok
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () async {
                          const host = 'www.tiktok.com';
                          const path = '/@easiergym';
                          _launchInBrowser(host, path);
                        },
                        child: Container(
                          width: 60,
                          height: 60,
                          child: Image(
                            image: image2.image,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      const Text(
                        '@easiergym',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  //insta
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () async {
                          const host = 'www.instagram.com';
                          const path = '/easiergym';
                          _launchInBrowser(host, path);
                        },
                        child: Container(
                          width: 60,
                          height: 60,
                          child: Image(
                            image: image1.image,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      const Text(
                        '@easiergym',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  //YT
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () async {
                          const host = 'www.youtube.com';
                          const path = '/@easiergym';
                          _launchInBrowser(host, path);
                        },
                        child: Container(
                          width: 60,
                          height: 60,
                          child: Image(
                            image: image3.image,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      const Text(
                        'Easier Gym',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),

              const Padding(padding: EdgeInsets.only(bottom: 25)),
            ],
          ),
        ),
      ),
    );
  }
}
