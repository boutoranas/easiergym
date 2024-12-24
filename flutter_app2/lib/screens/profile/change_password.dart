import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/widgets/button.dart';
import 'package:flutter_app/widgets/custom%20appbar.dart';
import 'package:flutter_app/widgets/snack_bar.dart';

import '../../const.dart';
import '../../services/check_connectivity.dart';
import '../authentification screens/forgot_password.dart';

class ChangePassword extends StatelessWidget {
  ChangePassword({super.key});
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();

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
    return Scaffold(
      appBar: customAppBar(
          title: 'Change password',
          leading: null,
          actions: null,
          context: context),
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
                    label: "Current password",
                    obscureText: true,
                    controller: passwordController,
                  ),
                  inputTextField(
                      context: context,
                      label: "New password",
                      obscureText: true,
                      controller: newPasswordController),
                  inputTextField(
                      context: context,
                      label: "Confirm password",
                      obscureText: true,
                      controller: confirmPasswordController),
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
                          if (passwordController.text.isNotEmpty &&
                              newPasswordController.text.isNotEmpty) {
                            if (newPasswordController.text ==
                                confirmPasswordController.text) {
                              try {
                                loadingIndicator(context);
                                await FirebaseAuth.instance
                                    .signInWithEmailAndPassword(
                                  email:
                                      FirebaseAuth.instance.currentUser!.email!,
                                  password: passwordController.text,
                                );
                                await FirebaseAuth.instance.currentUser!
                                    .updatePassword(newPasswordController.text);
                                showSnackBar(context, 'Changed successfully!');
                                Navigator.pop(context);
                              } on FirebaseAuthException catch (e) {
                                if (e.code == "wrong-password" ||
                                    e.code == "user-not-found") {
                                  showSnackBar(context, "password is invalid");
                                } else if (e.code == "unknown") {
                                  showSnackBar(context, "An error has occured");
                                } else {
                                  showSnackBar(context, e.message!);
                                }
                                Navigator.pop(context);
                              }
                            } else {
                              showSnackBar(
                                  context, 'Please enter the same password');
                            }
                          } else {
                            showSnackBar(context, 'All fields are required');
                          }
                        } else {
                          showSnackBar(context, 'No internet connection');
                        }
                      },
                      text: 'Apply changes'),
                  const SizedBox(
                    height: 5,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ForgotPassword()));
                    },
                    child: const Text("Forgot password?"),
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
