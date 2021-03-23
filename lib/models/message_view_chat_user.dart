import 'package:chat_chit/models/sns_models/facebook_user_model.dart';

class FacebookFirebaseUser extends FacebookUserModel {
  String content, pushToken;

  FacebookFirebaseUser({String name, String lastName, String profileImage, this.content, this.pushToken}) : super(name: name, lastName: lastName, profileImage: profileImage,);
}
