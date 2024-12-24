import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/auth/firebase_auth_methods.dart';
import 'package:flutter_app/const.dart';
import 'package:flutter_app/screens/authentification%20screens/sign_in_emailpassword.dart';
import 'package:flutter_app/widgets/button.dart';
import 'package:flutter_app/widgets/snack_bar.dart';

import '../../services/check_connectivity.dart';

class SignUpEmailPassword extends StatefulWidget {
  const SignUpEmailPassword({super.key});

  @override
  State<SignUpEmailPassword> createState() => _SignUpEmailPasswordState();
}

class _SignUpEmailPasswordState extends State<SignUpEmailPassword> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmpassController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmpassController.dispose();
    super.dispose();
  }

  void registerUser() async {
    FireBaseAuthMethods(FirebaseAuth.instance).signUpWithEmail(
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
          'Sign up',
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
                  inputTextField(
                      context: context,
                      label: "Confirm password",
                      obscureText: true,
                      controller: confirmpassController),
                  const SizedBox(
                    height: 40,
                  ),
                  button(
                      context: context,
                      onPressed: () async {
                        bool connectivity =
                            await CheckConnectivity.checkConnectivity();
                        if (connectivity == true) {
                          if (emailController.text.isNotEmpty &&
                              passwordController.text.isNotEmpty) {
                            if (passwordController.text ==
                                confirmpassController.text) {
                              registerUser();
                            } else {
                              showSnackBar(
                                  context, "Please enter the same password");
                            }
                          } else {
                            showSnackBar(context, "All fields are required");
                          }
                        } else {
                          showSnackBar(context, "No internet connection");
                        }
                      },
                      text: 'Sign up'),
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
                                  const SignInEmailPassword()));
                    },
                    child: const Text("Already have an account? sign in."),
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
