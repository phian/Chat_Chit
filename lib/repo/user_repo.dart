import 'package:chat_chit/models/sns_models/facebook_user_model.dart';
import 'package:chat_chit/service/firebase_api/facebook_api.dart';
import 'package:chat_chit/service/firebase_api/firebase_api.dart';
import 'package:chat_chit/service/shared_preference_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserRepo {
  final SharedPreferenceService sharedPreferenceService;
  final FirebaseAPI firebaseAPI;
  final FacebookAPI facebookAPI;
  FacebookUserModel receiveMessageUser;
  String currentScreen;

  void updateReceiveMessageUser(FacebookUserModel user) {
    this.receiveMessageUser = user;
  }

  void updateFirebaseUser(User user) {
    firebaseAPI.firebaseUser = user;
  }

  UserRepo({
    @required this.sharedPreferenceService,
    this.firebaseAPI,
    this.facebookAPI,
  });
}
