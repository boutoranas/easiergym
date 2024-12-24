import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/const.dart';
import 'package:flutter_app/screens/authentification%20screens/forgot_password.dart';
import 'package:flutter_app/screens/authentification%20screens/sign_up_email_and_password.dart';
import 'package:flutter_app/services/check_connectivity.dart';
import 'package:flutter_app/widgets/button.dart';

import '../../auth/firebase_auth_methods.dart';
import '../../widgets/snack_bar.dart';

class SignInEmailPassword extends StatefulWidget {
  const SignInEmailPassword({super.key});

  @override
  State<SignInEmailPassword> createState() => _SignInEmailPasswordState();
}

class _SignInEmailPasswordState extends State<SignInEmailPassword> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  signInUser() {
    FireBaseAuthMethods(FirebaseAuth.instance).loginWithEmail(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        context: context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          'Sign in',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color:
                Theme.of(context).inputDecorationTheme.border!.borderSide.color,
          ),
        ),
        leading: BackButton(
          color:
              Theme.of(context).inputDecorationTheme.border!.borderSide.color,
        ),
        backgroundColor: Theme.of(context).cardColor,
        shape: const Border(bottom: BorderSide(width: 1, color: Colors.black)),
        elevation: 0,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Align(
          alignment: Alignment.center,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: Const.horizontalPagePadding, vertical: 10),
              child: Column(
                children: [
                  inputTextField(
                      context: context,
                      label: "Email",
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress),
                  inputTextField(
                      context: context,
                      label: "Password",
                      obscureText: true,
                      controller: passwordController),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ForgotPassword()));
                      },
                      child: const Text("Forgot password?"),
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  button(
                      color: Theme.of(context).primaryColor,
                      context: context,
                      onPressed: () async {
                        bool connectivity =
                            await CheckConnectivity.checkConnectivity();
                        if (connectivity == true) {
                          if (emailController.text.isNotEmpty &&
                              passwordController.text.isNotEmpty) {
                            signInUser();
                          } else {
                            showSnackBar(context, "All fields are required");
                          }
                        } else {
                          showSnackBar(context, "No internet connection");
                        }
                      },
                      text: 'Sign in'),
                  const SizedBox(
                    height: 5,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const SignUpEmailPassword()));
                    },
                    child: const Text("Don't have an account yet? sign up."),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget inputTextField({
  required BuildContext context,
  required String label,
  required TextEditingController controller,
  int maxLength = 250,
  int maxLines = 1,
  bool obscureText = false,
  keyboardType = TextInputType.text,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 10, left: 5),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 13,
          ),
        ),
      ),
      TextField(
        maxLength: maxLength,
        minLines: 1,
        maxLines: maxLines,
        keyboardType: keyboardType,
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
            counterText: '',
            contentPadding:
                const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: const BorderSide(color: Colors.grey),
            )),
      ),
      const SizedBox(
        height: 30,
      )
    ],
  );
}
