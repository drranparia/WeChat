import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:messanger_app/Auth%20Screen/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

import 'Class Files/static.dart';
import 'Widgets/app_theme.dart';

bool? isLog;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  final prefs = await SharedPreferences.getInstance();
  isLog = prefs.getBool('isLog');
  ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navigatorKey);

  ZegoUIKit().initLog().then((value) {
    runApp(MyApp(navigatorKey: navigatorKey));
  });
}

class MyApp extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const MyApp({
    required this.navigatorKey,
    Key? key,
  }) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
  // Widget build(BuildContext context) {
  //   return MaterialApp(
  //     title: 'Flutter Demo',
  //     theme: ThemeData(
  //       fontFamily: GoogleFonts.poppins().fontFamily,
  //       primaryColor: AColor.themeColor,
  //     ),
  //     home:
  //         // SignIn(),
  //         const SplashScreen(),
  //     debugShowCheckedModeBanner: false,
  //   );
  // }
}

class _MyAppState extends State<MyApp> with AppThemeMixin {
  String email = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (isLog == true) {
      onUserLogin();
    }
  }

  void onUserLogin() async {
    /// 2.1. initialized ZegoUIKitPrebuiltCallInvitationService
    /// when app's user is logged in or re-logged in
    /// We recommend calling this method as soon as the user logs in to your app.
    await getEmail();
    ZegoUIKitPrebuiltCallInvitationService().init(
      appID: Statics.appID,
      appSign: Statics.appSign,
      /*input your AppSign*/
      userID: FirebaseAuth.instance.currentUser!.uid,
      userName: email,
      plugins: [ZegoUIKitSignalingPlugin()],
      notifyWhenAppRunningInBackgroundOrQuit: true,
      isIOSSandboxEnvironment: false,
      androidNotificationConfig: ZegoAndroidNotificationConfig(
        channelID: "ZegoUIKit",
        channelName: "Call Notifications",
        sound: "zego_incoming",
      ),
    );
  }

  getEmail() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    final data = doc.data();

    email = data!['email'];
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: widget.navigatorKey,
      title: 'Calling App',
      debugShowCheckedModeBanner: false,
      theme: appTheme(context),
      scrollBehavior: const ScrollBehaviorModified(),
      home: const SplashScreen(),
      builder: (BuildContext context, Widget? child) {
        return Stack(
          children: [
            child!,

            /// support minimizing
            ZegoUIKitPrebuiltCallMiniOverlayPage(
              contextQuery: () {
                return widget.navigatorKey.currentState!.context;
              },
            ),
          ],
        );
      },
    );
  }
}

class ScrollBehaviorModified extends ScrollBehavior {
  const ScrollBehaviorModified();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics();
  }
}
