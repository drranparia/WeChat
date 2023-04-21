import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Class Files/color.dart';
import '../navigation_screen.dart';
import 'sign_in.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool? isLog;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getPref();
    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                isLog == true ? const NavigationPage() : const SignIn(),
          ));
    });
  }

  getPref() async {
    final prefs = await SharedPreferences.getInstance();
    isLog = prefs.getBool('isLog');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // color: AColor.themeColor,
        decoration: const BoxDecoration(gradient: AColor.buttonGradientShader),
        child: Center(
          child: Image.asset('assets/AppIcon.png'),
        ),
      ),
    );
  }
}
