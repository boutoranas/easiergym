import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/auth/firebase_auth_methods.dart';
import 'package:flutter_app/const.dart';
import 'package:flutter_app/screens/introduction/introduction_main.dart';
import 'package:flutter_app/widgets/bottomnavigbar.dart';
import 'package:flutter_app/widgets/button.dart';
import 'package:path_provider/path_provider.dart';

import '../../services/app_media_query.dart';
import '../../services/user_preferences.dart';
import '../../widgets/snack_bar.dart';

class VerifyEmailPage extends StatefulWidget {
  final BuildContext contxt;
  const VerifyEmailPage({super.key, required this.contxt});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  Timer? timer;

  bool isEmailVerified = false;

  bool canResend = false;

  //Future userData;

  final uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    AppMediaQuerry.setMq(widget.contxt);
    super.initState();
    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    if (!isEmailVerified) {
      sendEmailVerification();

      timer = Timer.periodic(
          const Duration(seconds: 3), (timer) => checkEmailVerified());
    }
  }

  Future sendEmailVerification() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();
      showSnackBar(context, 'Email verification has been sent!');

      setState(() {
        canResend = false;
      });
      await Future.delayed(const Duration(seconds: 10));
      setState(() {
        canResend = true;
      });
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!);
    }
  }

  Future checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser!.reload();

    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    if (isEmailVerified) timer?.cancel();
  }

  Future<DataSnapshot> getUserData() async {
    await downloadProfileImage();
    String? sessionToken = FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(uid)
        .child("token")
        .push()
        .key;
    await FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(uid)
        .child("token")
        .set(sessionToken)
        .timeout(Duration(seconds: 15));
    await UserPreferences.setSessionToken(sessionToken!);
    DataSnapshot profileMapSnapshot = await FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(uid)
        .child("profile")
        .get();
    Map? profileMap = profileMapSnapshot.value as Map?;
    await UserPreferences.saveProfileMap(json.encode(profileMap));
    return FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(uid)
        .child("easiergym")
        .get()
        .timeout(Duration(seconds: 30));
  }

  downloadProfileImage() async {
    Reference storageRef =
        FirebaseStorage.instance.ref().child('profile_images').child(uid);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$uid');
    await storageRef.writeToFile(file).timeout(Duration(seconds: 15));
    //UserPreferences.setImage(file.path);
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

  @override
  Widget build(BuildContext context) {
    if (isEmailVerified == true) {
      //user just connected
      if (UserPreferences.getConnectionState() == false) {
        FirebaseAuth.instance.currentUser!.providerData[0].providerId !=
                'password'
            ? Navigator.popUntil(context, (route) => route.isFirst)
            : null;
        return FutureBuilder(
          future: getUserData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.hasError) {
              return Scaffold(
                body: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: Const.horizontalPagePadding),
                  child: Column(
                    children: [
                      Padding(padding: EdgeInsets.only(bottom: 50)),
                      Center(child: Text('Error: ${snapshot.error}')),
                      Padding(padding: EdgeInsets.only(bottom: 20)),
                      button(
                          width: 200,
                          context: context,
                          onPressed: () {
                            loadingIndicator(context);
                            FireBaseAuthMethods(FirebaseAuth.instance)
                                .signOut(context);
                          },
                          text: 'Sign out')
                    ],
                  ),
                ),
              );
            } else {
              final userData = snapshot.data!.value as Map?;
              UserPreferences.saveUserDataMap(json.encode(userData));

              UserPreferences.setConnectionState(true);
              if (UserPreferences.getFirstTime() == false) {
                return const MainPage();
              } else {
                return const IntroductionScreen();
              }
            }
          },
        );
      }
      //user already connected
      else {
        return const MainPage();
      }
    } else {
      return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(
            'Verify email',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: Theme.of(context)
                  .inputDecorationTheme
                  .border!
                  .borderSide
                  .color,
            ),
          ),
          leading: BackButton(
            color:
                Theme.of(context).inputDecorationTheme.border!.borderSide.color,
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
          ),
          backgroundColor: Theme.of(context).cardColor,
          shape:
              const Border(bottom: BorderSide(width: 1, color: Colors.black)),
          elevation: 0,
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: Const.horizontalPagePadding, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'sent a verification email to ${FirebaseAuth.instance.currentUser!.email!}. If you haven\'t received an email yet, please make sure to check your unwanted or spam inbox.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 30,
              ),
              button(
                  color: Theme.of(context).primaryColor,
                  context: context,
                  onPressed: canResend
                      ? () async {
                          sendEmailVerification();
                        }
                      : null,
                  text: 'Resend email verification'),
              const SizedBox(
                height: 5,
              ),
              TextButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                },
                child: const Text(
                  "Cancel",
                  style: TextStyle(fontSize: 15),
                ),
              )
            ],
          ),
        ),
      );
    }
  }
}
