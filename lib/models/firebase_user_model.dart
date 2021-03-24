class FirebaseUserModel {
  String deviceToken, email, firstName, id, lastName, name, profileImage, pushToken;

  FirebaseUserModel({this.deviceToken, this.email, this.firstName, this.lastName, this.name, this.profileImage, this.pushToken});

  FirebaseUserModel.fromJson(Map<String, dynamic> json) {
    this.deviceToken = json['device_token'];
    this.email = json['email'];
    this.firstName = json['first_name'];
    this.id = json['id'];
    this.lastName = json['last_name'];
    this.name = json['name'];
    this.profileImage = json['profile_image'];
    this.pushToken = json['push_token'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = Map<String, dynamic>();
    data['device_token'] = this.deviceToken;
    data['email'] = this.email;
    data['first_name'] = this.firstName;
    data['id'] = this.id;
    data['last_name'] = this.lastName;
    data['name'] = this.name;
    data['profile_image'] = this.profileImage;
    data['push_token'] = this.pushToken;

    return data;
  }
}