import 'package:chat_chit/base/base_bloc.dart';
import 'package:chat_chit/constant/sns_constant/message_types.dart';
import 'package:chat_chit/models/sns_models/message_model.dart';
import 'package:chat_chit/repo/user_repo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class ChatBloc extends BaseBloc {
  final UserRepo userRepo;
  String chatContent;
  DocumentSnapshot room;

  BehaviorSubject sendMessageStream;
  BehaviorSubject<List<MessageModel>> bhMsg;

  ChatBloc({this.userRepo}) {
    sendMessageStream = BehaviorSubject();
    bhMsg = BehaviorSubject();
    userRepo.currentScreen = "chat screen";
  }

  void checkAddMessageReturnData(MessageType type) {
    switch (type) {
      case MessageType.SENT:
        sendMessageStream.add(MessageType.SENT);
        break;
      case MessageType.RECEIVED:
        break;
      case MessageType.SEND_FAILED:
        sendMessageStream.add(MessageType.SEND_FAILED);
        break;
      case MessageType.REVOKED:
        break;
    }
  }

  Future<void> getChatRoom() async {
    await userRepo.firebaseAPI
        .getChatRoomFromFirebase(
            userRepo.firebaseUser, userRepo.receiveMessageUser, true)
        .then((value) {
      if (value != null) {
        if (value.docs.length != 0) {
          this.room = value.docs[0];
          getMessagesFromFirebase(this.room.id);

          /// TODO subscribe topic
          // userRepo.firebaseAPI.messaging
          //     .subscribeToTopic(this.room.id)
          //     .then((value) {
          //   debugPrint("subscribeToTopic success ${this.room.id}");
          // });
        } else {
          userRepo.firebaseAPI.getLatestRoom().then((value) {
            if (value != null && value.docs.length != 0) {
              room = value.docs[0];
            }
          });
        }
      }
    });
  }

  List<MessageModel> getMessagesFromFirebase(String roomId) {
    List<MessageModel> models = [];

    userRepo.firebaseAPI.getMessagesFromFirebase(roomId).then((value) {
      if (value != null && value.docs.length != 0) {
        value.docs.forEach((element) {
          models.add(MessageModel.fromJson(element.data()));
        });

        bhMsg.add(models);
      }
    }).catchError((e) {
      debugPrint(e.toString());
    });

    return models;
  }

  Future<MessageType> addMessage(String content) async {
    return await userRepo.firebaseAPI.addMessage(
      roomId: room.id,
      sendUser: userRepo.firebaseUser,
      content: content,
      time: DateTime.now(),
    );
  }

  void onSendMessageButtonClick(String content) {
    debugPrint("content is: $content");
    // userRepo.firebaseAPI.createNotification(userRepo.firebaseUser.uid);
    getChatRoom().then((room) {
      addMessage(content).then((value) {
        checkAddMessageReturnData(value);

        if (value == MessageType.SENT) {
          getChatRoom();
          // getBloc()
          //     .getMessagesFromFirebase(room.id);

          /// TODO send push notification
          userRepo.firebaseAPI.sendTopicPushNotification(
              this.room.id, userRepo.firebaseUser.displayName, content);
          // sendPushMessage(
          //     "flNaheirQbCpXoTmx8DUYS:APA91bGLdm_8amCdd6AQxGDjFbL1nWepIMMtIKoK1NBAUsvWGTFKX20gC2HwM93kogGkwfE-ahVfFhtSn9Ck5-xXzgBWa8eLnhdhhgAnFSvhgMaLW7k-i5ug-83ENdavPUmxIISiugIc");
        }
      });
    });
  }

  void listenToMessageChange() {
    userRepo.firebaseAPI.listenToMessageChangeForNoti(userRepo.firebaseUser, 'chat screen');
  }
}
