import 'package:chat_chit/base/base_bloc.dart';
import 'package:chat_chit/models/sns_models/facebook_user_model.dart';
import 'package:chat_chit/repo/user_repo.dart';
import 'package:chat_chit/ui/chat/chat_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class MessagesBloc extends BaseBloc {
  final UserRepo userRepo;
  BehaviorSubject getMessageStream;
  List<FacebookUserModel> users;
  var result;

  MessagesBloc({this.userRepo}) {
    getMessageStream = BehaviorSubject();
    users = [];
    userRepo.currentScreen = "messages screen";
  }

  void navigateToChatScreen(BuildContext context, FacebookUserModel user) async {
    userRepo.updateReceiveMessageUser(user);
    result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          this.result = null;
          return chatRoute;
        },
      ),
    );

    resetCurrentScreen();
    checkResultData();
    debugPrint("Result: $result");
  }

  void checkResultData() async {
    if (result != null) {
      userRepo.firebaseAPI.subscribeAllRoomTopic();
      getAllLastMessageForUsers();
      listenToMessageChange();
    }
  }

  void resetCurrentScreen() async {
    userRepo.currentScreen = "messages screen";
  }

  void getLastMessageFromFirebase(String roomId) async {
    await userRepo.firebaseAPI.getLastMessageFromFirebase(roomId).then((value) {
      if (value.docs.length != 0 && value != null) {
        String lastMessage;
        lastMessage = value.docs[value.docs.length - 1]['content'];
        debugPrint("last message is: $lastMessage");
        getMessageStream.add(lastMessage);
      }
    });
  }

  void getAllLastMessageForUsers() {
    userRepo.firebaseAPI.getAllUserFromFirebase().listen((event) {
      users = [];
      for (int i = 0; i < event.docs.length; i++) {
        users.add(
          FacebookUserModel(
            name: event.docs[i]['name'],
            profileImage: event.docs[i]['profile_image'],
            id: event.docs[i].id,
            lastName: event.docs[i]['last_name'],
          ),
        );

        userRepo.firebaseAPI
            .getChatRoomFromFirebase(userRepo.firebaseUser, users[i], false)
            .then((value) {
          if (value != null && value.docs.length != 0) {
            userRepo.firebaseAPI
                .getLastMessageFromFirebase(value.docs[0].id)
                .then((value) {
              if (value != null && value.docs.length != 0) {
                users[users.length - 1].lastMessage = value.docs[0]['content'];
              }
            });
          }
        });
      }

      getMessageStream.add(users);
    });
  }

  void listenToMessageChange() {
    userRepo.firebaseAPI
        .listenToMessageChangeForNoti(userRepo.firebaseUser, userRepo.currentScreen);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
