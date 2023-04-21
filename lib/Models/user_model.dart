class UserModel {
  String? uid;
  String? fullname;
  String? email;
  String? img;
  String? deviceToken;

  UserModel({
    this.uid,
    this.fullname,
    this.email,
    this.img,
    this.deviceToken,
  });

  UserModel.fromMap(Map<String, dynamic> map) {
    uid = map["uid"];
    fullname = map["fullname"];
    email = map["email"];
    img = map["profilepic"];
    deviceToken = map['deviceToken'];
  }

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "fullname": fullname,
      "email": email,
      "profilepic": img,
      "deviceToken": deviceToken,
    };
  }
}
