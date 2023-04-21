import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../Auth Screen/sign_in.dart';
import '../Class Files/color.dart';
import '../Class Files/textstyle.dart';
import '../Models/chatroom_model.dart';
import '../Models/user_model.dart';
import '../Widgets/cusWidgets.dart';
import 'chatting_screen.dart';
import 'user_profile.dart';

class UsersList extends StatefulWidget {
  const UsersList({super.key});

  @override
  State<UsersList> createState() => _UsersListState();
}

class _UsersListState extends State<UsersList> {
  var uuid = const Uuid();
  bool isClick = false;
  List<UserModel> datalist = [];
  List<UserModel> searchdata = [];

  final _searchController = TextEditingController();

  Future<ChatRoomModel?> getChatroomModel(UserModel targetUser) async {
    ChatRoomModel? chatRoom;

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("chatrooms")
        .where("participants.${FirebaseAuth.instance.currentUser!.uid}",
            isEqualTo: true)
        .where("participants.${targetUser.uid}", isEqualTo: true)
        .get();

    if (snapshot.docs.isNotEmpty) {
      // Fetch the existing one
      var docData = snapshot.docs[0].data();
      ChatRoomModel existingChatroom =
          ChatRoomModel.fromMap(docData as Map<String, dynamic>);

      chatRoom = existingChatroom;
    } else {
      // Create a new one
      ChatRoomModel newChatroom = ChatRoomModel(
        chatroomid: uuid.v1(),
        lastTime: DateTime.now(),
        lastMessage: "",
        participants: {
          selfUser!.uid.toString(): true,
          targetUser.uid.toString(): true,
        },
      );

      await FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(newChatroom.chatroomid)
          .set(newChatroom.toMap());

      chatRoom = newChatroom;
    }

    return chatRoom;
  }

  var userData;
  UserModel? selfUser;

  getUser() async {
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
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('users')
                .orderBy('fullname', descending: false)
                .snapshots(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              List<UserModel> list;
              if (snapshot.hasData) {
                list = [];
                snapshot.data.docs.forEach((element) {
                  list.add(UserModel.fromMap(element.data()));
                });
                if (isClick == false) {
                  datalist = list;
                  searchdata = list;
                }
                return datalist.isEmpty
                    ? const Center(
                        child: Text(
                          "No Users Found",
                          style: textStyle18w500,
                        ),
                      )
                    : _searchController.text.trim().isEmpty &&
                            datalist.length - 1 == 0
                        ? const Center(
                            child: Text("No Users Found."),
                          )
                        : Container(
                            color: Colors.transparent,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 15),
                            child: Column(children: [
                              ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: datalist.length,
                                  itemBuilder: (ctx, index) {
                                    return datalist[index].uid ==
                                            FirebaseAuth
                                                .instance.currentUser!.uid
                                        ? const SizedBox()
                                        : GestureDetector(
                                            onTap: () async {
                                              getUser();
                                              ChatRoomModel? _chatRoomModel =
                                                  await getChatroomModel(
                                                      datalist[index]);
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ChattingPage(
                                                    token: datalist[index]
                                                        .deviceToken
                                                        .toString(),
                                                    targetUser: datalist[index],
                                                    firebaseUser: FirebaseAuth
                                                        .instance
                                                        .currentUser as User,
                                                    userModel:
                                                        selfUser as UserModel,
                                                    chatRoom: _chatRoomModel
                                                        as ChatRoomModel,
                                                  ),
                                                ),
                                              ).then((value) async {
                                                var snapshot =
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection("chatrooms")
                                                        .get();
                                                List user = [];
                                                snapshot.docs.forEach((value) {
                                                  if (value['chatroomid'] ==
                                                      _chatRoomModel!
                                                          .chatroomid) {
                                                    return user.add(value);
                                                  }
                                                });
                                                if (user[0]
                                                        ['lastMessageSentBy'] !=
                                                    FirebaseAuth.instance
                                                        .currentUser!.uid) {
                                                  _chatRoomModel!
                                                      .unseenMessageCount = 0;

                                                  FirebaseFirestore.instance
                                                      .collection("chatrooms")
                                                      .doc(_chatRoomModel
                                                          .chatroomid)
                                                      .set(_chatRoomModel
                                                          .toMap());
                                                  setState(() {});
                                                }
                                              });
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10),
                                              child: Card(
                                                color: Colors.transparent,
                                                elevation: 0.0,
                                                child: Row(
                                                  children: [
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              23),
                                                      child: SizedBox.fromSize(
                                                        size: const Size
                                                            .fromRadius(23),
                                                        child: Image.network(
                                                          datalist[index]
                                                              .img
                                                              .toString(),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
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
                                                          Text(
                                                            datalist[index]
                                                                .fullname
                                                                .toString(),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 1,
                                                            style:
                                                                textStyle20w500,
                                                          ),
                                                          Text(
                                                            datalist[index]
                                                                .email
                                                                .toString(),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 1,
                                                            style: subTitle,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                  })
                            ]),
                          );
              }
              return Container();
            },
          ),
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
                    ];
                  })
                ],
              ),
              TextField(
                controller: _searchController,
                onChanged: (value) {
                  searchField(value.toString());
                  setState(() {});
                },
                onTap: () {
                  setState(() {
                    isClick = true;
                  });
                },
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

  void searchField(String value) {
    if (value.isEmpty) {
      datalist = searchdata;
      setState(() {});
    } else {
      datalist = searchdata
          .where((element) => element.fullname
              .toString()
              .replaceAll(' ', '')
              .toLowerCase()
              .contains(value.replaceAll(' ', '').toLowerCase()))
          .toList();
    }
    setState(() {});
  }
}
