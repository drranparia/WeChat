import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:messanger_app/Main%20Screens/user_profile.dart';
import 'package:messanger_app/Models/chatroom_model.dart';
import 'package:messanger_app/Models/notify_services.dart';
import 'package:messanger_app/Models/user_model.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

import '../Class Files/color.dart';
import '../Class Files/static.dart';
import '../Class Files/textstyle.dart';
import '../Models/message_model.dart';
import '../Widgets/chat_box.dart';

class ChattingPage extends StatefulWidget {
  final UserModel targetUser;
  final ChatRoomModel chatRoom;
  final UserModel userModel;
  final User firebaseUser;
  final String token;

  const ChattingPage({
    super.key,
    required this.targetUser,
    required this.chatRoom,
    required this.userModel,
    required this.firebaseUser,
    required this.token,
  });

  @override
  State<ChattingPage> createState() => _ChattingPageState();
}

class _ChattingPageState extends State<ChattingPage> {
  late ChatRoomModel _chatRoomModel;
  var date;
  var Date;
  int counter = 0;

  var uuid = const Uuid();
  bool _isMe = true;

  NotificationServices notificationServices = NotificationServices();

  final _chatController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUnread();
    onUserLogin();

    _chatRoomModel = widget.chatRoom;
    if (_chatRoomModel.lastMessageSentBy !=
        FirebaseAuth.instance.currentUser!.uid) {
      _chatRoomModel.unseenMessageCount = 0;
      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(_chatRoomModel.chatroomid)
          .set(_chatRoomModel.toMap());
    }
  }

  void onUserLogin() {
    /// 2.1. initialized ZegoUIKitPrebuiltCallInvitationService
    /// when app's user is logged in or re-logged in
    /// We recommend calling this method as soon as the user logs in to your app.
    ZegoUIKitPrebuiltCallInvitationService().init(
      appID: Statics.appID,
      appSign: Statics.appSign,
      /*input your AppSign*/
      userID: FirebaseAuth.instance.currentUser!.uid,
      userName: widget.userModel.email.toString(),
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

  getUnread() async {
    var snapshot =
        await FirebaseFirestore.instance.collection("chatrooms").get();
    List user = [];
    snapshot.docs.forEach((value) {
      if (value['chatroomid'] == _chatRoomModel.chatroomid) {
        return user.add(value);
      }
    });

    _chatRoomModel.unseenMessageCount = user[0]['unseenMessageCount'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AColor.backgroundColor,
      appBar: cusAppBar() as PreferredSizeWidget,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
          height: MediaQuery.of(context).size.height -
              AppBar().preferredSize.height,
          decoration: const BoxDecoration(
            color: AColor.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25.0),
              topRight: Radius.circular(25.0),
            ),
          ),
          child: Column(children: [
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("chatrooms")
                    .doc(widget.chatRoom.chatroomid)
                    .collection("messages")
                    .orderBy("createdon", descending: true)
                    .snapshots(),
                builder: ((context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    if (snapshot.hasData) {
                      QuerySnapshot dataSnapshot =
                          snapshot.data as QuerySnapshot;

                      return dataSnapshot.docs.isEmpty
                          ? Center(
                              child: GestureDetector(
                                onTap: () {
                                  _chatController.text = "Say Hi 👋";
                                  sendMessage();
                                },
                                child: const Text(
                                  "Say Hi 👋",
                                  style: textStyle25Bold,
                                ),
                              ),
                            )
                          : GestureDetector(
                              onTap: () => FocusScope.of(context).unfocus(),
                              child: ListView.builder(
                                itemCount: dataSnapshot.docs.length,
                                physics: const BouncingScrollPhysics(),
                                reverse: true,
                                shrinkWrap: true,
                                padding: const EdgeInsets.all(20),
                                itemBuilder: ((context, index) {
                                  MessageModel currentMessage =
                                      MessageModel.fromMap(
                                          dataSnapshot.docs[index].data()
                                              as Map<String, dynamic>);
                                  Date = DateTime.parse(
                                      currentMessage.createdon.toString());

                                  // 12 Hour format:
                                  date = DateFormat.jm().format(Date);
                                  currentMessage.sender == widget.userModel.uid
                                      ? _isMe = true
                                      : _isMe = false;
                                  //MESSAGE BOX
                                  return MessageBox(
                                    currentMessage: currentMessage,
                                    // isSeen: currentMessage.seen,
                                    isMe: _isMe,
                                    // message: currentMessage.text.toString(),
                                    timeStamp: date.toString(),
                                  );
                                }),
                              ),
                            );
                    } else {
                      return const Center(
                        child: Text(
                          "An error occured! Please check your internet connection.",
                          style: textStyle18w500,
                        ),
                      );
                    }
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                }),
              ),
            ),
            cusTextField(),
          ]),
        ),
      ),
    );
  }

  Widget cusAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      centerTitle: false,
      automaticallyImplyLeading: false,
      elevation: 0.0,
      title: Row(
        children: [
          GestureDetector(
            onTap: () async {
              var snapshot = await FirebaseFirestore.instance
                  .collection("chatrooms")
                  .get();
              List user = [];
              snapshot.docs.forEach((value) {
                if (value['chatroomid'] == _chatRoomModel.chatroomid) {
                  return user.add(value);
                }
              });
              if (user[0]['lastMessageSentBy'] !=
                  FirebaseAuth.instance.currentUser!.uid) {
                _chatRoomModel.unseenMessageCount = 0;

                FirebaseFirestore.instance
                    .collection("chatrooms")
                    .doc(_chatRoomModel.chatroomid)
                    .set(_chatRoomModel.toMap());
                Navigator.pop(context);
              } else {
                Navigator.pop(context);
              }
            },
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AColor.black,
              size: 23,
            ),
            //replace with our own icon data.
          ),
          const SizedBox(
            width: 10,
          ),
          CircleAvatar(
            backgroundImage: NetworkImage(widget.targetUser.img.toString()),
            radius: 18,
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Text(
              widget.targetUser.fullname.toString(),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: textStyle20w500,
            ),
          ),
        ],
      ),
      actions: <Widget>[
        actionButton(
          false,
          widget.targetUser.uid.toString(),
          widget.targetUser.fullname.toString(),
        ),
        actionButton(
          true,
          widget.targetUser.uid.toString(),
          widget.targetUser.fullname.toString(),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.03,
        ),
      ],
    );
  }

  ZegoSendCallInvitationButton actionButton(
          bool isVideo, String email, String name) =>
      ZegoSendCallInvitationButton(
        buttonSize: const Size(50, 50),
        iconSize: const Size(36, 36),
        unclickableBackgroundColor: isVideo ? AColor.infoBgColor : null,
        clickableTextColor: isVideo ? AColor.infoBgColor : null,

        // clickableBackgroundColor: isVideo?ColorPalette.infoBgColor:null,
        isVideoCall: isVideo,
        resourceID: email,
        invitees: [
          ZegoUIKitUser(
            id: email,
            name: name,
          ),
        ],
        onPressed: onSendCallInvitationFinished,
      );

  void onSendCallInvitationFinished(
    String code,
    String message,
    List<String> errorInvitees,
  ) {
    if (errorInvitees.isNotEmpty) {
      String userIDs = "";
      for (int index = 0; index < errorInvitees.length; index++) {
        if (index >= 5) {
          userIDs += '... ';
          break;
        }

        var userID = errorInvitees.elementAt(index);
        userIDs += userID + ' ';
      }
      if (userIDs.isNotEmpty) {
        userIDs = userIDs.substring(0, userIDs.length - 1);
      }

      var message = 'User doesn\'t exist or is offline: $userIDs';
      if (code.isNotEmpty) {
        message += ', code: $code, message:$message';
      }
      print(message);
      // showToast(
      //   message,
      //   position: StyledToastPosition.top,
      //   context: context,
      // );
    } else if (code.isNotEmpty) {
      print('code: $code, message:$message');
      // showToast(
      //   'code: $code, message:$message',
      //   position: StyledToastPosition.top,
      //   context: context,
      // );
    }
  }

  void sendMessage() async {
    // setState(() {});
    String msg = _chatController.text.trim();
    _chatController.clear();

    if (msg != "") {
      //Send Notification
      // print("TOKEN::::${widget.token}");
      if (widget.targetUser.deviceToken != "") {
        // notificationServices.getDeviceToken().then((value) async {
        var data = {
          'to': widget.targetUser.deviceToken.toString(),
          // 'to': 'd6giDUjTSIKs76P7TQPnaD:APA91bEYrQJaI76LrvEKj98xzBTWhAYj--oAbVUE3YuRLMWcDzJiYwTIyaJTvsRvLFLcnjMDmVf2YKjE1ejS8UgnZUyiVf81_xVZrEjv6YvGHtTEyFSiGAo02DYsxo4Jb5fJYmqOpWOs',
          'priority': 'high',
          'notification': {
            'title': widget.userModel.fullname,
            'body': msg,
          },
          'android': {
            'notification': {
              // 'title': widget.userModel.fullname,
              // 'body': msg,
              // 'android_channel_id': "Messages",
              // 'count': 10,
              // 'notification_count': 12,
              // 'badge': 12,
              // "click_action": 'asif',
              'icon': 'stock_ticker_update',
              'color': '#eeeeee',
            },
          },

          // 'data': {
          // 'type': 'msj',
          //   'id': 'asif1245',
          // }
        };
        // print("data::::::: ${data}");
        await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
            body: jsonEncode(data),
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization':
                  'key=AAAA9c3xl3A:APA91bEMRtf1xndX5f-1npniqwLzccAxrF6oO6WztO4jjV4lyCKtmFcR8FTymIY86jIutP6yya9EKwcw5B_--0Rj5fJ1Jh68_Wn7xa9cnzQ2ZpviJ2a8FwhirO8VbU37QhPwr75Fm_7X'
            });
        // print("NOTIFICATIONSENT:::");
        // });
      }

      // Send Message
      counter = counter + 1;

      MessageModel newMessage = MessageModel(
          messageid: uuid.v1(),
          sender: widget.userModel.uid,
          createdon: DateTime.now(),
          text: msg,
          seen: false);

      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatRoom.chatroomid)
          .collection("messages")
          .doc(newMessage.messageid)
          .set(newMessage.toMap());

      _chatRoomModel.lastMessage = msg;
      _chatRoomModel.lastTime = DateTime.now();

      // var snapshot =
      //     await FirebaseFirestore.instance.collection("chatrooms").get();
      // List user = [];
      // snapshot.docs.forEach((value) {
      //   if (value['chatroomid'] == _chatRoomModel.chatroomid) {
      //     return user.add(value);
      //   }
      // });

      // _chatRoomModel.unseenMessageCount = user[0]['unseenMessageCount'];
      getUnread();
      _chatRoomModel.lastMessageSentBy = FirebaseAuth.instance.currentUser!.uid;

      _chatRoomModel.unseenMessageCount = _chatRoomModel.lastMessageSentBy ==
              FirebaseAuth.instance.currentUser!.uid
          ? (widget.chatRoom.unseenMessageCount ?? 0) + 1
          : 0;
      _chatRoomModel.lastMessageSentBy = widget.userModel.uid;

      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatRoom.chatroomid)
          .set(widget.chatRoom.toMap());

      // print("Message Sent!");
    }

    // setState(() {});
  }

  Widget cusTextField() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 10, right: 20, bottom: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              // height: 60,
              // width: MediaQuery.of(context).size.width * 0.9,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: AColor.backgroundColor,
              ),
              child: Row(
                children: [
                  Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    height: 45,
                    width: 45,
                    decoration: BoxDecoration(
                      gradient: AColor.buttonGradientShader,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: AColor.white,
                      size: 25,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _chatController,
                      maxLines: null,
                      cursorColor: AColor.grey,
                      decoration: const InputDecoration(
                        hintText: 'message...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Icon(
                      Icons.tag_faces_outlined,
                      size: 35,
                      color: AColor.grey,
                    ),
                  )
                ],
              ),
            ),
          ),
          InkWell(
            onTap: () => sendMessage(),
            child: Container(
              margin: const EdgeInsets.only(left: 15),
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: AColor.grey.withOpacity(0.3),
              ),
              child: const Icon(
                Icons.send_rounded,
                color: AColor.grey,
              ),
            ),
          )
        ],
      ),
    );
  }
}
