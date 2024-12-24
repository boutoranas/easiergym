import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/auth/firebase_auth_methods.dart';

import '../../const.dart';
import '../../services/check_connectivity.dart';
import '../../widgets/button.dart';
import '../../widgets/custom appbar.dart';
import '../../widgets/snack_bar.dart';

class ChangeEmail extends StatelessWidget {
  ChangeEmail({super.key});

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

  TextEditingController emailController = TextEditingController(
      text: FirebaseAuth.instance.currentUser != null
          ? FirebaseAuth.instance.currentUser!.email!
          : '');
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
          title: 'Change email',
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
                    label: "New email",
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  inputTextField(
                    context: context,
                    label: "Current password",
                    controller: passwordController,
                    obscureText: true,
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
                            if (emailController.text !=
                                FirebaseAuth.instance.currentUser!.email) {
                              try {
                                loadingIndicator(context);
                                await FirebaseAuth.instance
                                    .signInWithEmailAndPassword(
                                  email:
                                      FirebaseAuth.instance.currentUser!.email!,
                                  password: passwordController.text,
                                );
                                await FirebaseAuth.instance.currentUser!
                                    .updateEmail(emailController.text);
                                showSnackBar(context, 'Changed successfully!');
                                String password = passwordController.text;
                                String email =
                                    FirebaseAuth.instance.currentUser!.email!;
                                FireBaseAuthMethods(FirebaseAuth.instance)
                                    .signOut(context);
                                FireBaseAuthMethods(FirebaseAuth.instance)
                                    .loginWithEmail(
                                        email: email,
                                        password: password,
                                        context: context);
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
                                  context, 'New email must be different');
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
