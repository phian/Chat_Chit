import 'package:chat_chit/repo/user_repo.dart';
import 'package:chat_chit/service/firebase_api/facebook_api.dart';
import 'package:chat_chit/service/firebase_api/firebase_api.dart';
import 'package:chat_chit/service/shared_preference_service.dart';
import 'package:chat_chit/ui/splash/splash_route.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  initApp();
}

void initApp() async {
  /// shared preferences init
  // SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  SharedPreferences sharedPreferences;
  SharedPreferenceService sharedPreferenceServices =
      SharedPreferenceService(sharedPreferences);

  /// Firebase init
  FirebaseAPI firebaseAPI = FirebaseAPI();

  /// Facebook API init
  FacebookAPI facebookAPI = FacebookAPI();

  runApp(MyApp(
    sharedPreferenceService: sharedPreferenceServices,
    firebaseAPI: firebaseAPI,
    facebookAPI: facebookAPI,
  ));
}

class MyApp extends StatelessWidget {
  final SharedPreferenceService sharedPreferenceService;
  final FirebaseAPI firebaseAPI;
  final FacebookAPI facebookAPI;

  MyApp({@required this.sharedPreferenceService, this.firebaseAPI, this.facebookAPI});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        return MultiProvider(
          providers: [
            Provider<SharedPreferenceService>.value(
              value: sharedPreferenceService,
            ),
            Provider<FirebaseAPI>.value(value: firebaseAPI),
            Provider<FacebookAPI>.value(value: facebookAPI),
            ProxyProvider3<SharedPreferenceService, FirebaseAPI, FacebookAPI, UserRepo>(
              update: (context, sharedPreferenceService, firebaseAPI, facebookAPI, userRepo) {
                if (userRepo != null)
                  return userRepo;
                else
                  return UserRepo(
                    sharedPreferenceService: sharedPreferenceService,
                    firebaseAPI: firebaseAPI,
                    facebookAPI: facebookAPI,
                  );
              },
            ),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            home: splashRoute,
          ),
        );
      },
    );
  }
}
