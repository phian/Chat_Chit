import 'package:chat_chit/models/sns_models/error_type.dart';
import 'package:chat_chit/models/sns_models/sns_model.dart';

class FacebookUserModel extends SNSModel {
  String firstName, lastName;
  ErrorType facebookError;
  String errorMessage;
  ///
  String lastMessage;
  String pushToken;

  FacebookUserModel({
    this.firstName,
    this.lastName,
    this.facebookError,
    this.errorMessage,
    this.lastMessage,
    this.pushToken,
    String id,
    String name,
    String email,
    String profileImage,
    String profileThumbnail,
  }) : super(
    id: id,
    name: name,
    email: email,
    profileImage: profileImage,
    profileThumbnail: profileThumbnail,
  );

  FacebookUserModel.fromJSON(Map<String, dynamic> json) {
    // if (json[id] != null) {}
    id = json['id'];
    name = json['name'];
    email = json['email'];
    profileImage = json['profile_image'] ?? '';
    firstName = json['first_name'];
    lastName = json['last name'];
    name = json['name'];
  }

  Map<String, dynamic> toJSON() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['first_name'] = firstName;
    data['lastName'] = lastName;
    data['errorMessage'] = errorMessage;
    data['avatar'] = profileImage;

    return data;
  }
}
