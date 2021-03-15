import 'package:chat_chit/base/base_bloc.dart';
import 'package:chat_chit/repo/user_repo.dart';
import 'package:chat_chit/ui/chat/chat_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MessagesBloc extends BaseBloc {
  final UserRepo userRepo;

  MessagesBloc({this.userRepo});

  void navigateToChatScreen(BuildContext context, DocumentSnapshot document) {
    userRepo.firebaseAPI.updateReceiveMessageUser(document);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return chatRoute;
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
