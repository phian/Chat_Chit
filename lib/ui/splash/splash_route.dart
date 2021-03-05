import 'package:chat_chit/repo/user_repo.dart';
import 'package:chat_chit/ui/splash/splash_bloc.dart';
import 'package:chat_chit/ui/splash/splash_view.dart';
import 'package:provider/provider.dart';

var splashRoute = ProxyProvider<UserRepo, SplashBloc>(
  update: (context, userRepo, splashBloc) {
    if (splashBloc != null)
      return splashBloc;
    else
      return SplashBloc(userRepo: userRepo);
  },
  create: (context) {
    SplashBloc splashBloc = SplashBloc(
      userRepo: Provider.of<UserRepo>(context, listen: false),
    );
    splashBloc.checkLogin();

    return splashBloc;
  },
  dispose: (context, splashBloc) => splashBloc.dispose(),
  child: SplashView(),
);
