import 'dart:async';

import 'package:chat_chit/base/base_bloc.dart';
import 'package:chat_chit/constant/app_state.dart';
import 'package:chat_chit/constant/sns_constant/sns_type.dart';
import 'package:chat_chit/repo/user_repo.dart';
import 'package:chat_chit/utils/device_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class SplashBloc extends BaseBloc {
  final UserRepo userRepo;

  ///========================================================================///
  BehaviorSubject<UserStates> splashScreenStreamController;
  UserStates userStates;

  void updateUserState(UserStates newState) {
    userStates = newState;

    splashScreenStreamController.add(userStates);
  }

  Future<void> updateFirebaseUser() async {
    return await userRepo.firebaseAPI
        .getFacebookUserFromFireBase(userRepo.facebookAPI.accessToken)
        .then((value) {
      if (value != null) userRepo.firebaseUser = value;
    });
  }

  Future<void> chooseLogInOrSignUpAction(
      UserStates userStates, SNSTypes snsType) async {
    // FirebaseAuth.instance.signInWithCredential(FacebookAuthProvider.credential(accessToken));
    switch (userStates) {
      case UserStates.LOGGED_IN:
        break;
      case UserStates.NOT_LOGGED_IN:
        switch (snsType) {
          case SNSTypes.FACEBOOK:
            // debugPrint("Passed here");
            userRepo.facebookAPI.facebookLogin().then((value) async {
              if (value == UserStates.LOGGED_IN) {
                updateUserState(UserStates.LOGGED_IN);
                DeviceUtils.getDeviceId().then((value) {
                  if (value != null) {
                    checkAndUpdateUser();
                  }
                });
              }
            });
            break;
          case SNSTypes.GOOGLE:
            break;
          case SNSTypes.APPLE:
            break;
          case SNSTypes.KAKAO:
            break;
        }
        break;
      case UserStates.WRONG_LOG_INFO:
        break;
      case UserStates.SIGNED_UP:
        break;
      case UserStates.NOT_SIGNED_UP:
        break;
    }
  }

  Future<void> checkAndUpdateUser() async {
    await userRepo.firebaseAPI
        .getFacebookUserFromFireBase(userRepo.facebookAPI.accessToken)
        .then((value) {
      if (value != null) userRepo.firebaseAPI.checkAndUpdateUser(value);
    });
  }

  ///========================================================================///

  BehaviorSubject<UserStates> psUserState;

  SplashBloc({
    @required this.userRepo,
  }) {
    psUserState = BehaviorSubject();
    splashScreenStreamController =
        BehaviorSubject.seeded(UserStates.NOT_LOGGED_IN);
    userStates = UserStates.NOT_LOGGED_IN;
  }

  // Future<bool> checkLoginTimeOut() {
  //   return userRepo.sharedPreferenceService
  //       .isBiometricTimeOut()
  //       .then((isTimeOut) {
  //     if (isTimeOut != null) {
  //       return isTimeOut;
  //     } else {
  //       return false;
  //     }
  //   });
  // }

  void onSplashActionPressed() {
    switch (userStates) {
      case UserStates.LOGGED_IN:
        throw 'This case should not be exist';
        //Not exist
        break;
      case UserStates.NOT_LOGGED_IN:
        updateUserState(UserStates.NOT_SIGNED_UP);
        break;
      case UserStates.WRONG_LOG_INFO:
        break;
      case UserStates.SIGNED_UP:
        break;
      case UserStates.NOT_SIGNED_UP:
        updateUserState(UserStates.NOT_LOGGED_IN);
        break;
    }
  }

  void checkLogin() {
    Future.delayed(
      Duration(
        milliseconds: 500,
      ),
      () {
        psUserState.add(UserStates.LOGGED_IN);
      },
    );
  }

  ///========================================================================///

  /// Get facebook user info
  // Future<void> _getFacebookUserData(String token) async {
  //   final graphResponse = await http.get(
  //       'https://graph.facebook.com/v2.12/me?fields=id,name,first_name,last_name,email,picture&access_token=$token');
  //   final profile = jsonDecode(graphResponse.body);
  //
  //   _showMessage('''
  //   ID: ${profile['id']}
  //   Name: ${profile["name"]}
  //   Picture: ${profile['picture']}
  //   First name: ${profile['first_name']}
  //   Last name: ${profile['last_name']}
  //   Email: ${profile['email']}
  //   ''');
  // }

  @override
  void dispose() {
    psUserState.close();
    splashScreenStreamController.close();
    super.dispose();
  }
}
