import 'dart:async';

import 'package:chat_chit/constant/sns_constant/message_types.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class FirebaseAPI {
  DocumentSnapshot receiveMessageUser;

  Stream<QuerySnapshot> getAllUserFromFirebase() {
    return FirebaseFirestore.instance.collection("members").snapshots();
  }

  Stream<QuerySnapshot> getAllMessageFromFirebase() {
    return FirebaseFirestore.instance.collection("messages").snapshots();
  }

  Future<QuerySnapshot> getMessagesFromFirebase(String roomId) async {
    return FirebaseFirestore.instance
        .collection("messages")
        .where("room_id", isEqualTo: roomId)
        .orderBy("message_time", descending: true)
        .get();
  }

  // Stream<QuerySnapshot> getMessagesFromFirebase(String roomId) {
  //   return FirebaseFirestore.instance
  //       .collection("messages")
  //       .where("room_id", isEqualTo: roomId)
  //       .orderBy("message_time", descending: true)
  //       .snapshots();
  // }

  Future<User> getFacebookUserFromFireBase(String accessToken) async {
    AuthCredential credential = FacebookAuthProvider.credential(accessToken);
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    User firebaseUser =
        (await firebaseAuth.signInWithCredential(credential)).user;

    // firebaseUser.getIdTokenResult().then((value) {
    //   value.claims['user_id'];
    // }).catchError()
    return firebaseUser;
  }

  /// Chat room
  Future<bool> checkIfRoomExist(
    User sendUser,
    DocumentSnapshot receiveUser,
  ) async {
    var result = await getChatRoomFromFirebase(sendUser, receiveUser);
    final List<DocumentSnapshot> documents = result.docs;

    if (documents.length == 0) {
      _addNewRoom(sendUser, receiveUser);
      return false;
    }

    return true;
  }

  Future<QuerySnapshot> getChatRoomFromFirebase(
    User sendUser,
    DocumentSnapshot receiveUser,
  ) async {
    QuerySnapshot result;
    await FirebaseFirestore.instance
        .collection('room')
        .where('send_user_id', isEqualTo: sendUser.uid)
        .where('receive_user_id', isEqualTo: receiveUser['id'])
        .get()
        .then((value) {
      if (value != null) {
        result = value;
        debugPrint("room id is: ${result.docs[0].id}");
      }
    }).catchError((e) => debugPrint(e.toString()));

    return result;
  }

  void _addNewRoom(User sendUser, DocumentSnapshot receiveUser) async {
    FirebaseFirestore.instance.collection('room').add({
      'send_user_id': sendUser.uid,
      'receive_user_id': receiveUser['id'],
    });
  }

  ///========================================================================///

  /// User
  Future<void> checkAndUpdateUser(User firebaseUser) async {
    if (firebaseUser != null) {
      List<String> userName = firebaseUser.displayName.split(" ");

      // Check is already sign up
      final QuerySnapshot result = await FirebaseFirestore.instance
          .collection('members')
          .where('id', isEqualTo: firebaseUser.uid)
          .get();
      final List<DocumentSnapshot> documents = result.docs;
      if (documents.length == 0) {
        debugPrint("Passed here");
        // Update data to server if new user
        FirebaseFirestore.instance.collection('members').add({
          'name': firebaseUser.displayName,
          'last_name': userName[userName.length - 1],
          'first_name': () {
            String firstName;
            for (int i = 0; i < userName.length - 1; i++) {
              firstName += userName[i] += " ";
            }
            return firstName.trim();
          }(),
          'profile_image': firebaseUser.photoURL,
          'id': firebaseUser.uid,
          'email': firebaseUser.email,
        });
      }
    }
  }

  void updateReceiveMessageUser(DocumentSnapshot user) {
    this.receiveMessageUser = user;
  }

  /// Message
  Future<MessageType> addMessage({
    User sendUser,
    String content,
    DateTime time,
    DocumentSnapshot receiveUser,
  }) async {
    var result = await getChatRoomFromFirebase(sendUser, receiveUser);
    var document = result.docs;

    if (content != null && content.isNotEmpty) {
      debugPrint("Passed here");
      // Update data to server if new user
      await FirebaseFirestore.instance.collection('messages').add({
        'room_id': document[0].id,
        'content': content,
        'message_time': time.toIso8601String(),
      });

      return MessageType.SENT;
    }

    return MessageType.SEND_FAILED;
  }
}
