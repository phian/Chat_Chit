import 'dart:async';

import 'package:chat_chit/base/base_bloc.dart';
import 'package:chat_chit/constant/app_state.dart';
import 'package:chat_chit/repo/user_repo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class SplashBloc extends BaseBloc {
  final UserRepo userRepo;

  StreamController<bool> splashScreenStreamController;

  bool isLogin = true;
  Future<void> updateIsLogin() async {
    isLogin = !isLogin;
    splashScreenStreamController.add(isLogin);
  }

  BehaviorSubject<UserLoginState> psUserLoginState;

  SplashBloc({
    @required this.userRepo,
  }) {
    psUserLoginState = BehaviorSubject();
    splashScreenStreamController = StreamController<bool>();
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

  void checkLogin() {
    Future.delayed(
      Duration(
        milliseconds: 500,
      ),
      () {
        psUserLoginState.add(UserLoginState.LOGGED_IN);
      },
    );
  }

  @override
  void dispose() {
    psUserLoginState.close();
    super.dispose();
  }
}
