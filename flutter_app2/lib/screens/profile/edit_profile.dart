import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/const.dart';
import 'package:flutter_app/services/user_preferences.dart';
import 'package:flutter_app/widgets/button.dart';
import 'package:flutter_app/widgets/snack_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../services/data_update.dart';
import '../../widgets/custom appbar.dart';
import '../authentification screens/sign_in_emailpassword.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  //!database
  final userID = FirebaseAuth.instance.currentUser!.uid;
  late Reference storageRef =
      FirebaseStorage.instance.ref().child("profile_images").child(userID);
  //!Controllers
  TextEditingController userNameController = TextEditingController();
  TextEditingController aboutMeController = TextEditingController();

  Map? profileMap = DataGestion.profileMap;

  String userName = '';
  String aboutMe = '';

  String uid = FirebaseAuth.instance.currentUser!.uid;

  late Future<String> imagePath;

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
    userNameController.text = userName;
  }

  assignAbout() {
    if (profileMap != null && profileMap!["aboutme"] != null) {
      aboutMe = profileMap!["aboutme"];
      aboutMeController.text = aboutMe;
    }
  }

  @override
  void initState() {
    imagePath = getImagePath();
    //assignImage();
    assignUserName();
    assignAbout();

    super.initState();
  }

  /* assignImage() {
    String? imagePath = UserPreferences.getImage();
    if (imagePath != null) {
      image = File(imagePath);
    }
  } */
  saveImageOnline() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final dir = await getApplicationDocumentsDirectory();
    final file = '${dir.path}/$uid';
    bool exists = await File(file).exists();

    if (exists == true) {
      try {
        await storageRef.putFile(File(file));
      } on FirebaseException catch (e) {
        print('error: ${e.message}');
      }
    }
  }

  saveChanges() async {
    //save username
    if (userNameController.text.isNotEmpty) {
      if (profileMap != null) {
        profileMap!["displayname"] = userNameController.text;
      } else {
        profileMap = {'displayname': userNameController.text};
      }
    } else {
      showSnackBar(context, 'You need to enter a username!');
    }
    //save about
    if (aboutMeController.text.isNotEmpty) {
      if (profileMap != null) {
        profileMap!["aboutme"] = aboutMeController.text;
      } else {
        profileMap = {'aboutme': aboutMeController.text};
      }
    } else if (profileMap != null && profileMap!["aboutme"] != null) {
      profileMap!.remove("aboutme");
    }
    //save image
    /* if (image != null) {
      UserPreferences.setImage(image!.path);
    } */
    final dir = await getApplicationDocumentsDirectory();
    final file = '${dir.path}/$uid';
    final fileCopy = '${dir.path}/$uid(temporary)';

    bool exists = await File(fileCopy).exists();
    if (exists == true) {
      await File(fileCopy).copy(file);
    }

    saveImageOnline();
    DataGestion.profileMap = profileMap;
    UserPreferences.saveProfileMap(json.encode(profileMap));

    Navigator.pop(context);
  }

  //File? image;

  Future pickUploadImage() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 40,
        maxHeight: 250,
        maxWidth: 250,
      );
      if (image == null) return;

      imageCache.clear();
      final dir = await getApplicationDocumentsDirectory();
      final temporaryFile = '${dir.path}/$uid(temporary)';

      final imageTemporary = File(image.path);
      await imageTemporary.copy(temporaryFile);

      setState(() {
        imagePath = changeToTemporaryImage();
      });
    } on PlatformException catch (e) {
      showSnackBar(context, e.message ?? 'An error has occured');
    }
  }

  Future<String> getImagePath() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = '${dir.path}/$uid';
    bool exists = await File(file).exists();
    imageCache.clear();

    if (exists == true) {
      return '${dir.path}/$uid';
    } else {
      return '';
    }
  }

  Future<String> changeToTemporaryImage() async {
    final dir = await getApplicationDocumentsDirectory();
    imageCache.clear();
    final tempFile = '${dir.path}/$uid(temporary)';
    FileImage(File(tempFile)).evict();
    return tempFile;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
          title: 'Profile', leading: null, actions: null, context: context),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: Const.horizontalPagePadding),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const Padding(padding: EdgeInsets.only(bottom: 30)),
              Center(
                child: Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        width: 1,
                      )),
                  child: Stack(
                    children: [
                      FutureBuilder(
                        future: imagePath,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState !=
                              ConnectionState.done) {
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
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          height: 36,
                          width: 36,
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                            ),
                            shape: BoxShape.circle,
                            color: Colors.blue,
                          ),
                          child: IconButton(
                            iconSize: 20,
                            tooltip: 'Pick image',
                            onPressed: () {
                              pickUploadImage();
                            },
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(padding: EdgeInsets.only(bottom: 50)),
              inputTextField(
                context: context,
                label: 'Username',
                controller: userNameController,
              ),
              inputTextField(
                keyboardType: TextInputType.multiline,
                maxLength: 500,
                maxLines: 10,
                context: context,
                label: 'About me',
                controller: aboutMeController,
              ),
              const Padding(padding: EdgeInsets.only(bottom: 15)),
              button(
                  context: context,
                  onPressed: () {
                    saveChanges();
                  },
                  text: 'Save changes'),
            ],
          ),
        ),
      ),
    );
  }
}
