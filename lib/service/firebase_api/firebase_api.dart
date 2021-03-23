import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:chat_chit/constant/sns_constant/message_types.dart';
import 'package:chat_chit/models/sns_models/facebook_user_model.dart';
import 'package:chat_chit/utils/device_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class FirebaseAPI {
  FirebaseMessaging messaging = FirebaseMessaging();

  FirebaseAPI() {
    messaging = FirebaseMessaging();
  }

  Stream<QuerySnapshot> getAllUserFromFirebase() {
    return FirebaseFirestore.instance.collection("members").snapshots();
  }

  /// Temp
  Stream<QuerySnapshot> getAllMessagesFromFirebase() {
    return FirebaseFirestore.instance.collection("messages").snapshots();
  }

  Stream<QuerySnapshot> getAllMessageFromFirebaseByTime() {
    return FirebaseFirestore.instance
        .collection('messages')
        .orderBy('message_time', descending: true)
        .snapshots();
  }

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
  Future<QuerySnapshot> getChatRoomFromFirebase(
    User user1,
    FacebookUserModel user2, [
    bool canAddRoom,
  ]) async {
    QuerySnapshot result;
    result = await FirebaseFirestore.instance
        .collection('room')
        .where('user_ids',
            arrayContainsAny: [user1.uid + user2.id, user2.id + user1.uid])
        .get()
        .then((value) {
          if (value != null) {
            if (value != null && value.docs.length != 0) {
              return value;
            } else {
              canAddRoom ? _addNewRoom(user1, user2) : null;
              return null;
            }
          }
        })
        .catchError((e) {
          debugPrint(e.toString());
        });

    return result;
  }

  void _addNewRoom(User user1, FacebookUserModel user2) async {
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

  Future<QuerySnapshot> getAllChatRoomFromFirebase() async {
    return FirebaseFirestore.instance.collection('room').get();
  }

  void subscribeAllRoomTopic() async {
    debugPrint("Subscribe to chat rooms");
    await getAllChatRoomFromFirebase().then((value) {
      if (value != null && value.docs.length != 0) {
        for (int i = 0; i < value.docs.length; i++) {
          messaging.subscribeToTopic(value.docs[i].id);
        }
      }
    });
  }

  void unSubscribeAllRoomTopic() async {
    await getAllChatRoomFromFirebase().then((value) {
      if (value != null && value.docs.length != 0) {
        for (int i = 0; i < value.docs.length; i++) {
          messaging.unsubscribeFromTopic(value.docs[i].id);
        }
      }
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

  Future<QuerySnapshot> getLastMessageFromFirebase(String roomId) async {
    return await FirebaseFirestore.instance
        .collection('messages')
        .where('room_id', isEqualTo: roomId)
        .get();
  }

  Future<DocumentSnapshot> getAllUserPushTokenFromFirebase() async {
    return await FirebaseFirestore.instance
        .collection('members')
        .doc('push_token')
        .get();
  }

  Future<MessageType> addMessage({
    User sendUser,
    String content,
    DateTime time,
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

  void listenToMessageChangeForNoti(User firebaseUser, String currentScreen) {
    getAllMessageFromFirebaseByTime().listen((event) {
      createNotification(firebaseUser.uid, event, currentScreen);
    });
  }

  /// Notification
  void createNotification(String currentUserId, QuerySnapshot messages, String currentScreen) {
    requestUserPermission();
    configureMessaging(currentUserId, messages, currentScreen);
  }

  void requestUserPermission() async {
    await messaging.requestNotificationPermissions(
      IosNotificationSettings(
        alert: true,
        sound: debugInstrumentationEnabled,
        badge: true,
        provisional: false,
      ),
    );
  }

  void configureMessaging(String sendUserId, QuerySnapshot messages, String currentScreen) {
    messaging.configure(
      onMessage: (Map<String, dynamic> message) {
        print('onMessage: $message');
          if (messages.docs.first['send_user_id'] != sendUserId && currentScreen.toLowerCase() != 'chat screen') {
            debugPrint("current screen: $currentScreen");
            Platform.isAndroid
                ? showNotification(
                    message['notification'], messages.docs.first['content'])
                : showNotification(
                    message['aps']['alert'], messages.docs.first['content']);
          }

        // Platform.isAndroid
        //     ? showNotification(message['notification'])
        //     : showNotification(message['aps']['alert']);
        return;
      },
      onResume: (Map<String, dynamic> message) {
        debugPrint('onResume: $message');
        // Platform.isAndroid
        //     ? showNotification(message['notification'], )
        //     : showNotification(message['aps']['alert']);
        return;
      },
      onLaunch: (Map<String, dynamic> message) {
        debugPrint('onLaunch: $message');
        // Platform.isAndroid
        //     ? showNotification(message['notification'])
        //     : showNotification(message['aps']['alert']);
        return;
      },
    );
  }

  showNotification(message, String content) async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    initNotificationPlugin(flutterLocalNotificationsPlugin);
    initAndroidChannel(flutterLocalNotificationsPlugin);

    await flutterLocalNotificationsPlugin.show(
        0,
        'Chat Chit',
        content,
        initPlatFormNotificationDetails(
          'ChatChitChannel',
          "Chat Chit Android channel",
          "This is Android channel description",
        ),
        payload: 'Welcome to the Local Notification demo');

    debugPrint("message is: $message");
  }

  void initAndroidChannel(FlutterLocalNotificationsPlugin plugin) {
    AndroidNotificationChannel androidChannel = AndroidNotificationChannel(
      'ChatChitChannel',
      "Chat Chit Android channel",
      "This is Android channel description",
      importance: Importance.max,
    );

    plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  NotificationDetails initPlatFormNotificationDetails(
      String id, String name, String description) {
    var android = AndroidNotificationDetails(
      id,
      name,
      description,
      priority: Priority.high,
      importance: Importance.max,
    );
    var iOS = IOSNotificationDetails();
    var platform = NotificationDetails(android: android, iOS: iOS);

    return platform;
  }

  void initNotificationPlugin(FlutterLocalNotificationsPlugin plugin) {
    var initializationSettingsAndroid =
        AndroidInitializationSettings('launch_background');
    var initializationSettingsIOS = IOSInitializationSettings();
    var initSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    plugin.initialize(initSettings, onSelectNotification: onSelectNotification);
  }

  Future<void> onSelectNotification(String payload) {
    debugPrint("payload is: $payload");
  }

  ///========================================================================///

  void updateUserToken(String currentUserId) async {
    messaging.getToken().then((token) {
      // print('push token: $token');
      FirebaseFirestore.instance
          .collection('members')
          .doc(currentUserId)
          .update({'push_token': token});
    }).catchError((err) {
      Fluttertoast.showToast(msg: err.message.toString());
    });
  }

  /// Send notification
  Future<void> sendTopicPushNotification(
      String topic, String sendUserName, String messageContent) async {
    if (topic == null) {
      print('Topic can not null');
      return;
    }

    try {
      await http.post(
        Uri.parse(
            'https://fcm.googleapis.com/v1/projects/chat-chit-522f9/messages:send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer ya29.a0AfH6SMAe4AGTsOJB2zYhbGTS87Eveamfbvnu-5FL8oouBeCEj85PMWxy_BijmY8D3a-f6ZHzyE4aB5EvCpUebmCb35HsF1uZ7BcOSC6LQNJQHuH8rwuZu3m4k_3ArbWFreOyMvRHgCjyewPiQE0YCsTJUtBv',
        },
        body: jsonEncode({
          'message': {
            'topic': topic,
            'notification': {
              // 'title': 'Title $topic',
              // 'body': 'This is body $topic',
              'title': sendUserName,
              'body': messageContent,
            },
          }
        }),
      );
      print('FCM request for device sent!');
    } catch (e) {
      print(e);
    }
  }

  Future<void> sendPushMessage(
      String fcmToken, String sendUserName, String content) async {
    if (fcmToken == null) {
      print('Unable to send FCM message, no token exists.');
      return;
    }

    try {
      await http.post(
        Uri.parse(
            'https://fcm.googleapis.com/v1/projects/chat-chit-522f9/messages:send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer ya29.a0AfH6SMAe4AGTsOJB2zYhbGTS87Eveamfbvnu-5FL8oouBeCEj85PMWxy_BijmY8D3a-f6ZHzyE4aB5EvCpUebmCb35HsF1uZ7BcOSC6LQNJQHuH8rwuZu3m4k_3ArbWFreOyMvRHgCjyewPiQE0YCsTJUtBv',
        },
        body: constructFCMPayload(fcmToken, sendUserName, content),
      );
      print('FCM request for device sent!');
    } catch (e) {
      print(e);
    }
  }

  String constructFCMPayload(
      String token, String sendUserName, String content) {
    return jsonEncode({
      'message': {
        'token': token,
        'notification': {
          'title': sendUserName,
          'body': content,
        },
      }
    });
  }
}
