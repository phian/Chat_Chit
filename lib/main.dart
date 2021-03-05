import 'package:chat_chit/repo/user_repo.dart';
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
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  SharedPreferenceService sharedPreferenceServices =
      SharedPreferenceService(sharedPreferences);

  runApp(MyApp(
    sharedPreferenceService: sharedPreferenceServices,
  ));
}

class MyApp extends StatelessWidget {
  final SharedPreferenceService sharedPreferenceService;

  MyApp({@required this.sharedPreferenceService});

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
            ProxyProvider<SharedPreferenceService, UserRepo>(
              update: (context, sharedPreferenceService, userRepo) {
                if (userRepo != null)
                  return userRepo;
                else
                  return UserRepo(
                    sharedPreferenceService: sharedPreferenceService,
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
