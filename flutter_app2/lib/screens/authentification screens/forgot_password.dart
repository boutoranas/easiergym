import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/const.dart';
import 'package:flutter_app/widgets/button.dart';

import '../../auth/firebase_auth_methods.dart';
import '../../services/check_connectivity.dart';
import '../../widgets/snack_bar.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  void resetPassword() async {
    FireBaseAuthMethods(FirebaseAuth.instance)
        .resetPassword(email: emailController.text.trim(), context: context);
    setState(() {
      canResetPassword = false;
    });
    await Future.delayed(const Duration(seconds: 10));
    setState(() {
      canResetPassword = true;
    });
  }

  bool canResetPassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          'Forgot password',
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
                    label: "Email",
                    controller: emailController,
                    context: context,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  button(
                      context: context,
                      onPressed: canResetPassword == true
                          ? () async {
                              bool connectivity =
                                  await CheckConnectivity.checkConnectivity();
                              if (connectivity == true) {
                                if (emailController.text.isNotEmpty) {
                                  resetPassword();
                                } else {
                                  showSnackBar(
                                      context, "Please enter an email");
                                }
                              } else {
                                showSnackBar(context, "No internet connection");
                              }
                            }
                          : null,
                      text: 'Reset password'),
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
