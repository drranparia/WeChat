import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:messanger_app/Models/user_model.dart';
import 'package:messanger_app/Widgets/cusWidgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Auth Screen/sign_in.dart';
import '../Class Files/color.dart';
import '../Class Files/textstyle.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  Future<void> signOut() async {
    await GoogleSignIn().disconnect();
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('isLog');
    CusWidgets.snakBar(context, 'SignOut Successfully', AColor.success);

    FirebaseFirestore.instance
        .collection("users")
        .doc(selfUser!.uid)
        .update({"deviceToken": ''});
    setState(() {
      getUserData();
    });

    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (BuildContext context) {
      return const SignIn();
    }), (route) => false);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserData();
  }

  var userData;
  UserModel? selfUser;

  getUserData() async {
    userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    selfUser = UserModel.fromMap(userData.data());

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AColor.backgroundColor,
      appBar: cusAppBar() as PreferredSizeWidget,
      body: selfUser == null
          ? const Center(
              child: Text(
              'UserData are Empty from FireStore',
              style: textStyle18w500,
            ))
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(selfUser!.img.toString()),
                    radius: 75,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.04,
                  ),
                  Text(
                    selfUser!.fullname.toString(),
                    style: textStyle25Bold,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.01,
                  ),
                  Text(
                    selfUser!.email.toString(),
                    style: textStyle20w500,
                  )
                ],
              ),
            ),
    );
  }

  Widget cusAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25.0),
          bottomRight: Radius.circular(25.0),
        ),
      ),
      elevation: 0.0,
      toolbarHeight: MediaQuery.of(context).size.height * 0.1,
      backgroundColor: AColor.white,
      flexibleSpace: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select UserProfile',
                    style: textStyle25Bold,
                  ),
                  InkWell(
                    onTap: () => signOut(),
                    child: const Icon(
                      Icons.logout_rounded,
                      color: AColor.black,
                      size: 27,
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
