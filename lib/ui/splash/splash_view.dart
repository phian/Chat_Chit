import 'package:chat_chit/base/base_state_bloc.dart';
import 'package:chat_chit/constant/app_color.dart';
import 'package:chat_chit/ui/splash/splash_bloc.dart';
import 'package:chat_chit/widgets/action_button.dart';
import 'package:chat_chit/widgets/padding_widgets.dart';
import 'package:chat_chit/widgets/screen_content_container.dart';
import 'package:chat_chit/widgets/text_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:chat_chit/utils/extensions.dart';

class SplashView extends StatefulWidget {
  @override
  _SplashViewState createState() => _SplashViewState();
}

class _SplashViewState extends BaseStateBloc<SplashView, SplashBloc> {
  final String _imageFolderPath = "assets/images/";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalleteColor.PURPLE_COLOR,
      body: Stack(
        children: [
          _backgroundImage(),
          getBloc().isLogin
              ? _signOptionContent(
                  isSignIn: getBloc().isLogin,
                  facebookDisplayText: "SIGN IN WITH FACEBOOK",
                  googleDisplayText: "SIGN IN WITH GOOGLE",
                  appleDisplayText: "SIGN IN WITH APPLE",
                  kakaoDisplayText: "SIGN IN WITH KAKAO",
                )
              : _signOptionContent(
                  isSignIn: getBloc().isLogin,
                  facebookDisplayText: "SIGN UP WITH FACEBOOK",
                  googleDisplayText: "SIGN UP WITH GOOGLE",
                  appleDisplayText: "SIGN UP WITH APPLE",
                  kakaoDisplayText: "SIGN UP WITH KAKAO",
                ),
        ],
      ),
    );
  }

  /// Background image
  Widget _backgroundImage() {
    return AppPaddingWidget(
      child: Column(
        children: [
          Container(
            alignment: Alignment.center,
            child: Image.asset(
              "$_imageFolderPath/splash_background.png",
              height: MediaQuery.of(context).size.height * 0.48,
            ),
          ),
        ],
      ),
    );
  }

  Widget _signOptionContent({
    bool isSignIn,
    String facebookDisplayText,
    String googleDisplayText,
    String appleDisplayText,
    String kakaoDisplayText,
  }) {
    return StreamBuilder(
      stream: getBloc().splashScreenStream,
      builder: (context, snapshot) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: CustomContainer(
            height: MediaQuery.of(context).size.height * 0.58,
            width: context.getScreenWidth(context),
            child: AppPaddingWidget(
              horizontal: 20.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppPaddingWidget(
                    paddingTop: 20.0,
                    child: AppTextWidget(
                      textContent: isSignIn ? "Welcome back" : "Let's join us!",
                      fontWeight: FontWeight.bold,
                      fontSize: 22.0,
                    ),
                  ),
                  AppPaddingWidget(
                    paddingTop: 10.0,
                    child: AppTextWidget(
                      textContent: isSignIn
                          ? "Sign in to your account"
                          : "Sign up new account",
                      fontSize: 18.0,
                    ),
                  ),
                  AppPaddingWidget(
                    paddingTop: 20.0,
                    child: AppActionsButton(
                      buttonContent: facebookDisplayText,
                      borderSideColor: Colors.blue,
                    ),
                  ),
                  AppPaddingWidget(
                    paddingTop: 20.0,
                    child: AppActionsButton(
                      buttonContent: googleDisplayText,
                      borderSideColor: Color(0xFFE9433A),
                    ),
                  ),
                  AppPaddingWidget(
                    paddingTop: 20.0,
                    child: AppActionsButton(
                      buttonContent: appleDisplayText,
                      borderSideColor: Color(0xFF8A8A8A),
                    ),
                  ),
                  AppPaddingWidget(
                    paddingTop: 20.0,
                    child: AppActionsButton(
                      buttonContent: kakaoDisplayText,
                      borderSideColor: Color(0xFF331919),
                    ),
                  ),
                  AppPaddingWidget(
                    paddingTop: 20.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppTextWidget(
                          textContent: isSignIn
                              ? "Don't have any account?"
                              : "Already have an account?",
                          fontSize: 20.0,
                        ),
                        InkWell(
                          onTap: () {
                            debugPrint(getBloc().isLogin.toString());
                            getBloc().updateIsLogin();
                            setState(() {});
                          },
                          child: AppTextWidget(
                            textContent: isSignIn ? " Sign up" : " Sign in",
                            fontSize: 20.0,
                            textColor: AppPalleteColor.PURPLE_COLOR,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
