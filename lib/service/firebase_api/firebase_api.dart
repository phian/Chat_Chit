import 'dart:async';
import 'dart:io';

import 'package:chat_chit/constant/sns_constant/message_types.dart';
import 'package:chat_chit/utils/device_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';

class FirebaseAPI {
  Stream<QuerySnapshot> getAllUserFromFirebase() {
    return FirebaseFirestore.instance.collection("members").snapshots();
  }

  /// Temp
  Stream<QuerySnapshot> getAllMessagesFromFirebase() {
    return FirebaseFirestore.instance.collection("messages").snapshots();
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
  // Future<bool> checkIfRoomExist(
  //   User sendUser,
  //   DocumentSnapshot receiveUser,
  // ) async {
  //   var result = await getChatRoomFromFirebase(sendUser, receiveUser);
  //   final List<DocumentSnapshot> documents = result.docs;
  //
  //   if (documents.length == 0) {
  //     _addNewRoom(sendUser, receiveUser);
  //     return false;
  //   }
  //
  //   return true;
  // }

  Future<QuerySnapshot> getChatRoomFromFirebase(
    User user1,
    DocumentSnapshot user2,
  ) async {
    QuerySnapshot result;
    result = await FirebaseFirestore.instance
        .collection('room')
        .where('user_ids',
            arrayContainsAny: [user1.uid + user2.id, user2.id + user1.uid])
        .get()
        .then((value) {
          if (value != null) {
            if (value.docs.length != 0 && value != null) {
              return value;
            } else {
              _addNewRoom(user1, user2);
              return null;
            }
          }
        })
        .catchError((e) {
          debugPrint(e.toString());
        });
    // result = await FirebaseFirestore.instance
    //     .collection('room')
    //     .where('send_user_id', isEqualTo: user1.uid)
    //     .where('receive_user_id', isEqualTo: user2['id'])
    //     .get()
    //     .then((value) async {
    //   if (value.docs.length == 0) {
    //     result = await FirebaseFirestore.instance
    //         .collection('room')
    //         .where('send_user_id', isEqualTo: user2['id'])
    //         .where('receive_user_id', isEqualTo: user1.uid)
    //         .get()
    //         .then((value) {
    //       if (value.docs.length == 0) {
    //         _addNewRoom(user1, user2);
    //       } else {
    //         result = value;
    //         return;
    //         // debugPrint("room id is: ${result.docs[0].id}");
    //       }
    //     }).catchError((e) => debugPrint(e.toString()));
    //
    //     // _addNewRoom(sendUser, receiveUser);
    //     // return;
    //   } else {
    //     result = value;
    //     return;
    //     // debugPrint("room id is: ${result.docs[0].id}");
    //   }
    // }).catchError((e) => debugPrint(e.toString()));

    return result;
  }

  void _addNewRoom(User user1, DocumentSnapshot user2) async {
    // await FirebaseFirestore.instance.collection('room').add({
    //   'send_user_id': user1.uid,
    //   'receive_user_id': user2.id,
    // });
    await FirebaseFirestore.instance.collection('room').doc().set({
      'user_ids': [(user1.uid + user2.id), (user2.id + user1.uid)],
    });
  }

  Future<QuerySnapshot> getLatestRoom() async {
    return FirebaseFirestore.instance.collection('room').snapshots().last;
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
        // debugPrint("Passed here");
        // Update data to server if new user
        DeviceUtils.getDeviceId().then((value) {
          if (value != null) {
            FirebaseFirestore.instance
                .collection('members')
                .doc(firebaseUser.uid)
                .set({
              'name': firebaseUser.displayName,
              'last_name': userName[userName.length - 1],
              'first_name': () {
                String firstName = '';
                for (int i = 0; i < userName.length - 1; i++) {
                  firstName += userName[i] + " ";
                }
                return firstName.trim();
              }(),
              'profile_image': firebaseUser.photoURL,
              'id': firebaseUser.uid,
              'email': firebaseUser.email,
              'push_token': '',
              'device_token': value,
            });
          }
        });
      }
    }
  }

  /// Message
  Future<QuerySnapshot> getMessagesFromFirebase(String roomId) async {
    return FirebaseFirestore.instance
        .collection("messages")
        .where("room_id", isEqualTo: roomId)
        .orderBy("message_time", descending: true)
        .get();
  }

  Future<MessageType> addMessage({
    User sendUser,
    String content,
    DateTime time,
    DocumentSnapshot receiveUser,
    String roomId,
  }) async {
    // var result = await getChatRoomFromFirebase(sendUser, receiveUser);

    if (content != null && content.isNotEmpty && roomId != null) {
      // debugPrint("Passed here");
      // Update data to server if new user
      await FirebaseFirestore.instance.collection('messages').doc().set({
        'room_id': roomId,
        'send_user_id': sendUser.uid,
        'content': content,
        'message_time': time.millisecondsSinceEpoch,
      });

      return MessageType.SENT;
    }

    return MessageType.SEND_FAILED;
  }

  /// Notification
  void createNotification(FirebaseMessaging messaging, String currentUserId) {
    requestUserPermission(messaging);
    configureMessaging(messaging);
    updateUserToken(messaging, currentUserId);
  }

  void requestUserPermission(FirebaseMessaging messaging) async {
    await messaging.requestNotificationPermissions(
      IosNotificationSettings(
        alert: true,
        sound: debugInstrumentationEnabled,
        badge: true,
        provisional: false,
      ),
    );
  }

  void configureMessaging(FirebaseMessaging messaging) {
    messaging.configure(
      onMessage: (Map<String, dynamic> message) {
        print('onMessage: $message');
        Platform.isAndroid
            ? showNotification(message['notification'])
            : showNotification(message['aps']['alert']);
        return;
      },
      onResume: (Map<String, dynamic> message) {
        debugPrint('onResume: $message');
        return;
      },
      onLaunch: (Map<String, dynamic> message) {
        debugPrint('onLaunch: $message');
        return;
      },
    );
  }

  showNotification(message) {
    debugPrint("message is: $message");
  }

  void updateUserToken(
      FirebaseMessaging messaging, String currentUserId) async {
    await messaging.getToken().then((token) {
      // print('push token: $token');
      FirebaseFirestore.instance
          .collection('members')
          .doc(currentUserId)
          .update({'push_token': token});
    }).catchError((err) {
      Fluttertoast.showToast(msg: err.message.toString());
    });
  }
}
