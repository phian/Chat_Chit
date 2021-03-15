class RoomModel {
  String roomId;
  String sendUserId;
  String receiveUserId;

  RoomModel({this.roomId, this.sendUserId, this.receiveUserId});

  RoomModel.fromJson(Map<String, dynamic> json) {
    roomId = json['room_id'];
    sendUserId = json['send_user_id'];
    receiveUserId = json['receive_user_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['room_id'] = this.roomId;
    data['send_user_id'] = this.sendUserId;
    data['receive_user_id'] = this.receiveUserId;
    return data;
  }
}