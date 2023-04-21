import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:messanger_app/Main%20Screens/user_profile.dart';
import 'package:messanger_app/Widgets/cusWidgets.dart';
import 'package:messanger_app/Widgets/dialog_box.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Auth Screen/sign_in.dart';
import '../Class Files/color.dart';
import '../Class Files/textstyle.dart';
import '../Models/chatroom_model.dart';
import '../Models/firebase_helper.dart';
import '../Models/notify_services.dart';
import '../Models/user_model.dart';
import 'chatting_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isClick = false;
  List<UserModel> datalist = [];
  List<UserModel> searchdata = [];
  NotificationServices notificationServices = NotificationServices();

  final _searchController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserData();

    notificationServices.requestNotificationPermission();
    notificationServices.initLocalNotifications();
    // notificationServices.setupInteractMessage(context);
    notificationServices.isTokenRefresh();
    // notificationServices.getDeviceToken().then((value) {
    if (kDebugMode) {
      print('device token');
      // print(value);
    }
    // });
  }

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
      resizeToAvoidBottomInset: false,
      backgroundColor: AColor.backgroundColor,
      appBar: cusAppBar() as PreferredSizeWidget,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: selfUser == null
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('chatrooms')
                      .orderBy('lastTime', descending: true)
                      // .where('participants.${FirebaseAuth.instance.currentUser!.uid}',
                      //     isEqualTo: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      if (snapshot.hasData) {
                        QuerySnapshot chatRoomSnapshots =
                            snapshot.data as QuerySnapshot;
                        // print(
                        //     "LENGTH OF CHATROOM:-  :::::${chatRoomSnapshots.docs.length}");

                        if (chatRoomSnapshots.docs.isNotEmpty) {
                          return ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: chatRoomSnapshots.docs.length,
                            itemBuilder: (context, index) {
                              ChatRoomModel chatRoomModel =
                                  ChatRoomModel.fromMap(
                                      chatRoomSnapshots.docs[index].data()
                                          as Map<String, dynamic>);

                              int unseenMessageCount =
                                  chatRoomModel.lastMessageSentBy ==
                                          FirebaseAuth.instance.currentUser!.uid
                                      ? 0
                                      : chatRoomModel.unseenMessageCount ?? 0;

                              Map<String, dynamic> participants =
                                  chatRoomModel.participants!;

                              List<String> participantKeys =
                                  participants.keys.toList();
                              participantKeys.remove(selfUser!.uid);

                              return participantKeys.isEmpty
                                  ? const SizedBox()
                                  : FutureBuilder(
                                      future: FirebaseHelper.getUserModelById(
                                          participantKeys[0]),
                                      builder: (context, userData) {
                                        if (userData.connectionState ==
                                            ConnectionState.done) {
                                          if (chatRoomModel.lastMessage
                                                  .toString() !=
                                              "") {
                                            UserModel targetUser =
                                                userData.data as UserModel;

                                            bool _checkBool =
                                                (chatRoomModel.participants![
                                                        FirebaseAuth.instance
                                                            .currentUser!.uid
                                                            .toString()] ==
                                                    true);

                                            return _checkBool == false
                                                ? const SizedBox()
                                                : GestureDetector(
                                                    onTap: () {
                                                      getUserData();
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              ChattingPage(
                                                            token: targetUser
                                                                .deviceToken
                                                                .toString(),
                                                            targetUser:
                                                                targetUser,
                                                            firebaseUser:
                                                                FirebaseAuth
                                                                        .instance
                                                                        .currentUser
                                                                    as User,
                                                            userModel: selfUser
                                                                as UserModel,
                                                            chatRoom:
                                                                chatRoomModel,
                                                          ),
                                                        ),
                                                      ).then((value) async {
                                                        var snapshot =
                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    "chatrooms")
                                                                .get();
                                                        List user = [];
                                                        snapshot.docs
                                                            .forEach((value) {
                                                          if (value[
                                                                  'chatroomid'] ==
                                                              chatRoomModel
                                                                  .chatroomid) {
                                                            return user
                                                                .add(value);
                                                          }
                                                        });
                                                        if (user[0][
                                                                'lastMessageSentBy'] !=
                                                            FirebaseAuth
                                                                .instance
                                                                .currentUser!
                                                                .uid) {
                                                          chatRoomModel
                                                              .unseenMessageCount = 0;

                                                          FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  "chatrooms")
                                                              .doc(chatRoomModel
                                                                  .chatroomid)
                                                              .set(chatRoomModel
                                                                  .toMap());
                                                          setState(() {});
                                                        }
                                                      });
                                                    },
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 10),
                                                      child: Card(
                                                        color:
                                                            Colors.transparent,
                                                        elevation: 0.0,
                                                        child: Row(
                                                          children: [
                                                            const SizedBox(
                                                              width: 10,
                                                            ),
                                                            InkWell(
                                                              onTap: () {
                                                                showDialog(
                                                                    context:
                                                                        context,
                                                                    builder: (_) =>
                                                                        ProfileDialog(
                                                                          targetUser:
                                                                              targetUser,
                                                                        ));
                                                              },
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            23),
                                                                child: SizedBox
                                                                    .fromSize(
                                                                  size: const Size
                                                                      .fromRadius(23),
                                                                  child: Image
                                                                      .network(
                                                                    targetUser
                                                                        .img
                                                                        .toString(),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.05,
                                                            ),
                                                            Expanded(
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceAround,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Expanded(
                                                                        child:
                                                                            Text(
                                                                          targetUser
                                                                              .fullname
                                                                              .toString(),
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          maxLines:
                                                                              1,
                                                                          style:
                                                                              textStyle20w500,
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding:
                                                                            const EdgeInsets.symmetric(horizontal: 20),
                                                                        child:
                                                                            Text(
                                                                          dateFunction(chatRoomModel)
                                                                              .toString(),
                                                                          // dispalyTD
                                                                          //     .toString(),
                                                                          style:
                                                                              subTitle,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Expanded(
                                                                        child:
                                                                            Text(
                                                                          chatRoomModel
                                                                              .lastMessage
                                                                              .toString(),
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          maxLines:
                                                                              1,
                                                                          style:
                                                                              subTitle,
                                                                        ),
                                                                      ),
                                                                      unseenMessageCount ==
                                                                              0
                                                                          ? Container()
                                                                          : Container(
                                                                              margin: const EdgeInsets.symmetric(horizontal: 20),
                                                                              height: 25,
                                                                              width: 25,
                                                                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), gradient: AColor.buttonGradientShader),
                                                                              child: Center(
                                                                                child: Text(
                                                                                  unseenMessageCount.toString(),
                                                                                  style: messegeCount,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                          } else {
                                            // print("REDBOX:::::1");
                                            return Container();
                                          }
                                        } else {
                                          // print("REDBOX:::::2");
                                          return Container();
                                        }
                                      });
                            },
                          );
                        } else {
                          // print("REDBOX:::::3");
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 20.0),
                              child: Text(
                                'No Chats Available',
                                style: textStyle18w500,
                              ),
                            ),
                          );
                        }
                      }
                      // else if (snapshot.hasError) {
                      //   // print("REDBOX:::::4");
                      //   return Center(
                      //     child: Text(
                      //       snapshot.error.toString(),
                      //     ),
                      //   );
                      // }
                      else {
                        // print("REDBOX:::::5");
                        return const Center(
                          child: Text('No Data'),
                        );
                      }
                    } else {
                      // print("REDBOX:::::6");
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
        ),
      ),
    );
  }

  var selectedItem = '';

  Widget cusAppBar() {
    return AppBar(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25.0),
          bottomRight: Radius.circular(25.0),
        ),
      ),
      elevation: 0.0,
      toolbarHeight: MediaQuery.of(context).size.height * 0.21,
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
                    'Messages',
                    style: textStyle25Bold,
                  ),
                  PopupMenuButton(onSelected: (value) {
                    if (value == 'User Profile') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UserProfile(),
                        ),
                      );
                    } else if (value == 'Log Out') {
                      signOut();
                    } else {
                      CusWidgets.snakBar(
                          context, 'Setting Comming Soon', AColor.success);
                    }
                    // Navigator.pushNamed(context, value.toString());
                  }, itemBuilder: (BuildContext bc) {
                    return const [
                      PopupMenuItem(
                        value: 'Setting',
                        child: Text("Setting"),
                      ),
                      PopupMenuItem(
                        value: 'User Profile',
                        child: Text("User Profile"),
                      ),
                      PopupMenuItem(
                        value: 'Log Out',
                        child: Text("Log Out"),
                      )
                    ];
                  })
                ],
              ),
              TextField(
                controller: _searchController,
                // onChanged: (value) {
                //   searchField(value.toString());
                //   setState(() {});
                // },
                // onTap: () {
                //   setState(() {
                //     isClick = true;
                //   });
                // },
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AColor.grey,
                    size: 30,
                  ),
                  prefixIconColor: AColor.black,
                  hintText: 'Search by name',
                  hintStyle: subTitle,
                  border: InputBorder.none,
                  filled: true,
                  fillColor: AColor.backgroundColor,
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                        color: Colors.transparent), //<-- SEE HERE
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.transparent,
                    ),
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.01,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // void searchField(String value) {
  //   if (value.isEmpty) {
  //     datalist = searchdata;
  //     setState(() {});
  //   } else {
  //     datalist = searchdata
  //         .where((element) => element.fullname
  //             .toString()
  //             .replaceAll(' ', '')
  //             .toLowerCase()
  //             .contains(value.replaceAll(' ', '').toLowerCase()))
  //         .toList();
  //   }
  //   setState(() {});
  // }
}

dateFunction(ChatRoomModel chatRoomModel) {
  var today = DateFormat.yMMMd().format(DateTime.now());

  var lastTime = chatRoomModel.lastTime;
  var chatTime = DateFormat.jm().format(lastTime!);
  var chatDate = DateFormat.yMMMd().format(lastTime);

  var dispalyTD = chatDate == today ? chatTime : chatDate;
  return dispalyTD;
}
