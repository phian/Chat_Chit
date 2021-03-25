import 'dart:io';

import 'package:chat_chit/base/base_bloc.dart';
import 'package:chat_chit/models/sns_models/facebook_user_model.dart';
import 'package:chat_chit/repo/user_repo.dart';
import 'package:chat_chit/ui/chat/chat_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rxdart/rxdart.dart';

class MessagesBloc extends BaseBloc {
  final UserRepo userRepo;
  BehaviorSubject getMessageStream;
  BehaviorSubject<String> updateImageStream;
  List<FacebookUserModel> users;
  var result;

  MessagesBloc({this.userRepo}) {
    getMessageStream = BehaviorSubject();
    updateImageStream = BehaviorSubject<String>();
    users = [];
    userRepo.currentScreen = "messages screen";
    updateImageStream.add(
      userRepo.firebaseAPI.allUserImagePaths
          .singleWhere(
            (element) => element.id == userRepo.firebaseAPI.firebaseUser.uid,
          )
          .profileImage,
    );
  }

  void navigateToChatScreen(
      BuildContext context, FacebookUserModel user) async {
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

  void getAllLastMessageForUsers() async {
    userRepo.firebaseAPI.getAllUserLastMessages().then((value) {
      userRepo.firebaseAPI.getAllUserFromFirebaseStream().listen((event) {
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
        }

        for (int i = 0; i < users.length; i++) {
          debugPrint("user id: ${users[i].id}");
          debugPrint(
              "last message length: ${userRepo.firebaseAPI.allUserLastMessages.length}");
          for (int j = 0;
              j < userRepo.firebaseAPI.allUserLastMessages.length;
              j++) {
            debugPrint(
                "last message id: ${userRepo.firebaseAPI.allUserLastMessages[j].id}");
            if (userRepo.firebaseAPI.allUserLastMessages[j].id
                .contains(users[i].id)) {
              users[i].lastMessage =
                  userRepo.firebaseAPI.allUserLastMessages[j].lastMessage;
            }
          }
        }

        getMessageStream.add(users);
      });
    });
  }

  void listenToMessageChange() {
    userRepo.firebaseAPI.listenToMessageChangeForNoti(
        userRepo.firebaseAPI.firebaseUser, userRepo.currentScreen);
  }

  /// Profile image
  void getAndSaveImageIfCan(ImageSource source) async {
    await _getImage(source).then((value) async {
      if (value != null) {
        await userRepo.firebaseAPI.uploadNewProfileImage(value).then((value) {
          if (value != null) updateImageStream.add(value);
        });
      }
    });
  }

  Future<File> _getImage(ImageSource source) async {
    PickedFile imageFile = await ImagePicker.platform.pickImage(source: source);
    File cropImage;
    File compressImage;

    if (imageFile != null) {
      cropImage = await ImageCropper.cropImage(
        sourcePath: imageFile.path,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 100,
        maxHeight: 700,
        maxWidth: 700,
        androidUiSettings: AndroidUiSettings(
          toolbarColor: Colors.deepOrange,
          toolbarTitle: "Crop your image",
          statusBarColor: Colors.deepOrange.shade900,
          backgroundColor: Colors.white,
        ),
      );

      compressImage = await FlutterImageCompress.compressAndGetFile(
        cropImage.path,
        '${cropImage.path}.jpg',
        quality: 50, // Low quality to reduce image size
      );
    }

    return compressImage;
  }

  @override
  void dispose() {
    super.dispose();
  }
}
