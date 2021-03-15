import 'package:flutter/material.dart';

class MessageModel {
  String userId, content, messageTime;

  MessageModel({this.userId, this.content, this.messageTime});

  MessageModel.fromJson(Map<String, dynamic> json) {
    this.userId = json['user_id'];
    this.content = json['content'];
    this.messageTime = json['message_time'];
  }

  Map<String, dynamic> ToJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();

    data['user_id'] = this.userId;
    data['content'] = this.content;
    data['message_time'] = this.messageTime;

    return data;
  }
}
