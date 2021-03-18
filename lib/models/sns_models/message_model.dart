class MessageModel {
  String roomId, content, sendUserId;
  DateTime messageTime;

  MessageModel({this.roomId, this.content, this.messageTime, this.sendUserId});

  MessageModel.fromJson(Map<String, dynamic> json) {
    this.content = json['content'];
    this.messageTime = DateTime.fromMillisecondsSinceEpoch(int.parse(json['message_time'].toString()) ?? 0);
    this.roomId = json['room_id'];
    this.sendUserId = json['send_user_id'];
  }

  Map<String, dynamic> ToJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['user_id'] = this.roomId;
    data['content'] = this.content;
    data['message_time'] = this.messageTime.millisecondsSinceEpoch;
    data['send_user_id'] = this.sendUserId;

    return data;
  }
}
