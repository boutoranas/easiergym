import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/services/user_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../widgets/snack_bar.dart';

class FireBaseAuthMethods {
  final FirebaseAuth _auth;
  FireBaseAuthMethods(this._auth);
  //EMAIL SIGNUP
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    loadingIndicator(context);
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!);
    }
    Navigator.pop(context);
  }

  //VERIFY EMAIL
  Future<void> sendEmailVerification(BuildContext context) async {
    try {
      _auth.currentUser!.sendEmailVerification();
      showSnackBar(context, 'Email verification has been sent!');
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!);
    }
  }

  //EMAIL LOGIN
  Future<void> loginWithEmail({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    loadingIndicator(context);
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      //!await getUserData(_auth.currentUser!.uid);

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (e.code == "wrong-password" || e.code == "user-not-found") {
        showSnackBar(context, "Email or password are invalid");
      } else if (e.code == "unknown") {
        showSnackBar(context, "An error has occured");
      } else {
        showSnackBar(context, e.message!);
      }
    }
    Navigator.pop(context);
  }

  //EMAIL RESET PASSWORD
  Future<void> resetPassword({
    required String email,
    required BuildContext context,
  }) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!);
    }
  }

  //GOOGLE SIGN IN
  Future<void> signInWithGoogle(BuildContext context) async {
    loadingIndicator(context);
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        Navigator.pop(context);
        return;
      }

      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      if (googleAuth?.accessToken != null && googleAuth?.idToken != null) {
        //create new credential
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken,
          idToken: googleAuth?.idToken,
        );

        //Navigator.pop(context);
        /* UserCredential userCredential =
            await */
        /* print("now");
        await Future.delayed(Duration(seconds: 10)); */

        await _auth.signInWithCredential(credential);
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      showSnackBar(context, e.message!);
    } on PlatformException catch (e) {
      if (e.code == "network_error") {
        showSnackBar(context, "A network error has occured");
      } else {
        showSnackBar(context, e.message!);
        print(e.code);
      }
      Navigator.pop(context);
    }
  }

  //sign out
  Future<void> signOut(BuildContext context) async {
    try {
      Navigator.pop(context);
      await _auth.signOut();
      UserPreferences.setConnectionState(false);
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!);
    }
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
}
