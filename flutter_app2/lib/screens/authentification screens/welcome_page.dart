import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/auth/firebase_auth_methods.dart';
import 'package:flutter_app/const.dart';
import 'package:flutter_app/screens/authentification%20screens/sign_in_emailpassword.dart';
import 'package:flutter_app/screens/authentification%20screens/sign_up_email_and_password.dart';

import '../../services/check_connectivity.dart';
import '../../services/custom_icons.dart';
import '../../widgets/button.dart';
import '../../widgets/snack_bar.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  late Image image1;
  late Image image2;

  @override
  void initState() {
    super.initState();
    image1 =
        Image.asset('assets/images/Authentification_screen_decoration1.png');
    image2 =
        Image.asset('assets/images/Authentification_screen_decoration2.png');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    precacheImage(image1.image, context);
    precacheImage(image2.image, context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            Positioned(
              right: 0,
              top: 0,
              child: Image(
                image: image1.image,
                width: MediaQuery.of(context).size.width / 1.6,
              ),
            ),
            Positioned(
              bottom: 0,
              child: Image(
                image: image2.image,
                width: MediaQuery.of(context).size.width,
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: Const.horizontalPagePadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Align(
                      alignment: Alignment.topCenter,
                      child: Text(
                        "Welcome",
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const Padding(padding: EdgeInsets.only(bottom: 10)),
                    Container(
                      width: MediaQuery.of(context).size.width / 2,
                      child: const Align(
                        alignment: Alignment.topCenter,
                        child: Text(
                          "We're glad to have you with us!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 100,
                    ),
                    /* Flexible(
                    child: SizedBox(
                      height: 400,
                      width: 10,
                    ),
                  ), */
                    button(
                        color: Theme.of(context).primaryColor,
                        context: context,
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const SignInEmailPassword()));
                        },
                        text: 'Sign in'),
                    const SizedBox(
                      height: 20,
                    ),
                    button(
                      context: context,
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const SignUpEmailPassword()));
                      },
                      text: 'Sign up',
                    ),
                    SizedBox(
                      height: Platform.isIOS ? 20 : 0,
                    ),
                    Platform.isIOS
                        ? button(
                            icon: CustomIcons.apple,
                            color: Colors.white,
                            context: context,
                            onPressed: () async {
                              bool connectivity =
                                  await CheckConnectivity.checkConnectivity();
                              if (connectivity == true) {
                                /* FireBaseAuthMethods(FirebaseAuth.instance)
                                .signInWithApple(context); */
                              } else {
                                showSnackBar(context, "No internet connection");
                              }
                            },
                            text: 'Sign in with Apple')
                        : Container(),
                    const SizedBox(
                      height: 20,
                    ),
                    button(
                        icon: CustomIcons.google,
                        color: Colors.blue,
                        context: context,
                        onPressed: () async {
                          bool connectivity =
                              await CheckConnectivity.checkConnectivity();
                          if (connectivity == true) {
                            FireBaseAuthMethods(FirebaseAuth.instance)
                                .signInWithGoogle(context);
                          } else {
                            showSnackBar(context, "No internet connection");
                          }
                        },
                        text: 'Sign in with Google'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
