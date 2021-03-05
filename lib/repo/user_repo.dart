import 'package:chat_chit/service/shared_preference_service.dart';
import 'package:flutter/cupertino.dart';

class UserRepo {
  final SharedPreferenceService sharedPreferenceService;

  UserRepo({@required this.sharedPreferenceService});
}