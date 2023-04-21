class ChatRoomModel {
  String? chatroomid;
  Map<String, dynamic>? participants;
  String? lastMessage;
  DateTime? lastTime;
  String? lastMessageSentBy;
  int? unseenMessageCount;

  ChatRoomModel({
    this.chatroomid,
    this.participants,
    this.lastMessage,
    this.lastTime,
    this.lastMessageSentBy,
    this.unseenMessageCount,
  });

  ChatRoomModel.fromMap(Map<String, dynamic> map) {
    chatroomid = map["chatroomid"];
    participants = map["participants"];
    lastMessage = map["lastmessage"];
    lastTime = map["lastTime"].toDate();
    lastMessageSentBy = map["lastMessageSentBy"];
    unseenMessageCount = map["unseenMessageCount"];
  }

  Map<String, dynamic> toMap() {
    return {
      "chatroomid": chatroomid,
      "participants": participants,
      "lastmessage": lastMessage,
      "lastTime": lastTime,
      "lastMessageSentBy": lastMessageSentBy,
      "unseenMessageCount": unseenMessageCount,
    };
  }
}
