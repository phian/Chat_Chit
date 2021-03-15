import 'package:chat_chit/base/base_bloc.dart';
import 'package:chat_chit/constant/sns_constant/message_types.dart';
import 'package:chat_chit/models/sns_models/message_model.dart';
import 'package:chat_chit/repo/user_repo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class ChatBloc extends BaseBloc {
  final UserRepo userRepo;
  String chatContent;
  User firebaseUser;
  DocumentSnapshot room;

  BehaviorSubject sendMessageStream;
  BehaviorSubject<List<MessageModel>> bhMsg;

  ChatBloc({this.userRepo}) {
    sendMessageStream = BehaviorSubject();
    bhMsg = BehaviorSubject();
  }

  // Future<void> getUserFromFirebaseForUpdateMessage() async {
  //   // AuthCredential credential =
  //   //     FacebookAuthProvider.credential(userRepo.facebookAPI.accessToken);
  //   // FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  //   // firebaseUser = (await firebaseAuth.signInWithCredential(credential)).user;
  //
  //   userRepo.firebaseAPI.getFacebookUserFromFireBase(userRepo.facebookAPI.accessToken);
  // }

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

  // Future<void> initFirebaseUser() async {
  //   firebaseUser = await userRepo.firebaseAPI
  //       .getFacebookUserFromFireBase(userRepo.facebookAPI.accessToken);
  //
  //   debugPrint("firebaseUser uid: ${firebaseUser.uid}");
  // }

  void getChatRoom() {
    userRepo.firebaseAPI
        .getChatRoomFromFirebase(
            firebaseUser, userRepo.firebaseAPI.receiveMessageUser)
        .then((value) {
      if (value != null) {
        this.room = value.docs[0];
        getMessagesFromFirebase(this.room.id);
      }
    });
  }

  List<MessageModel> getMessagesFromFirebase(String roomId) {
    List<MessageModel> models = [];

    userRepo.firebaseAPI.getMessagesFromFirebase(roomId).then((value) {
      if (value != null) {
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

  void initChatData() {
    userRepo.firebaseAPI
        .getFacebookUserFromFireBase(userRepo.facebookAPI.accessToken)
        .then((value) {
      if (value != null) {
        firebaseUser = value;
        getChatRoom();
        debugPrint(value.toString());
      }
    }).catchError((e) {
      debugPrint(e.toString());
    });
  }
}
