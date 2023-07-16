import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:messanger_app/Widgets/cusWidgets.dart';
import 'package:messanger_app/navigation_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Class Files/color.dart';
import '../Class Files/textstyle.dart';
import '../Models/user_model.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override 
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  bool isLoading = false;
  String? tokenId;
  @override
  void initState() {
    super.initState();
    FirebaseMessaging _fbMessaging = FirebaseMessaging.instance; // Change here
    _fbMessaging.getToken().then((token) {
      print("token is::: $token");
      tokenId = token;
    });
  }

  signIn() async {
    GoogleSignIn gSignIN = GoogleSignIn();
    try {
      var result = await gSignIN.signIn();
      if (result == null) {
        return;
      } else {
        final userData = await result.authentication;
        final credential = GoogleAuthProvider.credential(
            accessToken: userData.accessToken, idToken: userData.idToken);
        var finalResult =
            await FirebaseAuth.instance.signInWithCredential(credential);

        String uids = FirebaseAuth.instance.currentUser!.uid;
        UserModel newUser = UserModel(
            uid: uids,
            email: result.email,
            fullname: result.displayName,
            img: result.photoUrl,
            deviceToken: tokenId);

        await FirebaseFirestore.instance
            .collection("users")
            .doc(uids)
            .set(newUser.toMap())
            .then((value) async {
          CusWidgets.snakBar(context, 'SignIn Successfully', AColor.success);

          final prefs = await SharedPreferences.getInstance();
          prefs.setBool('isLog', true);
          setState(() {
            isLoading = false;
          });
          Navigator.pushAndRemoveUntil(context,
              MaterialPageRoute(builder: (BuildContext context) {
            return const NavigationPage();
          }), (route) => false);
        });
      }
    } catch (e) {
      CusWidgets.snakBar(context, e.toString(), AColor.warn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AColor.backgroundColor,
      body: isLoading == true
          ? const Loader()
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset('assets/signin.svg',
                      height: MediaQuery.of(context).size.height * 0.25),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.07,
                  ),
                  const Text(
                    'Welcome To',
                    textAlign: TextAlign.center,
                    style: appTitle,
                  ),
                  const Text(
                    'WeChat',
                    textAlign: TextAlign.center,
                    style: appTitle,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.03,
                  ),
                  FloatingActionButton.extended(
                    icon: SvgPicture.asset(
                      'assets/google.svg',
                      height: 35,
                    ),
                    label: const Text(
                      'SignUp with Google',
                      style: textStyle18w500,
                    ),
                    backgroundColor: AColor.white,
                    foregroundColor: AColor.black,
                    onPressed: () {
                      setState(() {
                        isLoading = true;
                      });
                      signIn();
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
