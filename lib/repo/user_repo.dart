import 'package:chat_chit/service/firebase_api/facebook_api.dart';
import 'package:chat_chit/service/firebase_api/firebase_api.dart';
import 'package:chat_chit/service/shared_preference_service.dart';
import 'package:flutter/material.dart';

class UserRepo {
  final SharedPreferenceService sharedPreferenceService;
  final FirebaseAPI firebaseAPI;
  final FacebookAPI facebookAPI;

  UserRepo({@required this.sharedPreferenceService, this.firebaseAPI, this.facebookAPI});
}