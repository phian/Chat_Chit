import 'package:chat_chit/constant/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

class FacebookAPI {
  /// Facebook log in
  FacebookLogin facebookLoginVar;
  String accessToken;

  FacebookAPI() {
    facebookLoginVar = FacebookLogin();
  }

  Future<UserStates> facebookLogin() async {
    FacebookLoginResult result = await facebookLoginVar.logIn(['email']);

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        final FacebookAccessToken accessToken = result.accessToken;
        _updateAccessToken(accessToken.token);

        _showMessage('''
         Logged in!
         
         Token: ${accessToken.token}
         User id: ${accessToken.userId}
         Expires: ${accessToken.expires}
         Permissions: ${accessToken.permissions}
         Declined permissions: ${accessToken.declinedPermissions}
         ''');

        // _getFacebookUserData(accessToken.token);
        return UserStates.LOGGED_IN;
        break;
      case FacebookLoginStatus.cancelledByUser:
        _showMessage('Login cancelled by the user.');
        break;
      case FacebookLoginStatus.error:
        _showMessage('Something went wrong with the login process.\n'
            'Here\'s the error Facebook gave us: ${result.errorMessage}');
        break;
    }

    return UserStates.NOT_LOGGED_IN;
  }

  void _updateAccessToken(String token) {
    this.accessToken = token;
  }

  void _showMessage(String message) {
    debugPrint(message);
  }
}