import 'package:chat_chit/service/firebase_api/facebook_api.dart';
import 'package:chat_chit/service/firebase_api/firebase_api.dart';
import 'package:chat_chit/service/shared_preference_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserRepo {
  final SharedPreferenceService sharedPreferenceService;
  final FirebaseAPI firebaseAPI;
  final FacebookAPI facebookAPI;
  User firebaseUser;
  DocumentSnapshot receiveMessageUser;

  void updateReceiveMessageUser(DocumentSnapshot user) {
    this.receiveMessageUser = user;
  }

  void updateFirebaseUser(User user) {
    this.firebaseUser = firebaseUser;
  }

  UserRepo({@required this.sharedPreferenceService, this.firebaseAPI, this.facebookAPI});
}