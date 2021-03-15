import 'package:chat_chit/base/base_state_bloc.dart';
import 'package:chat_chit/constant/app_color.dart';
import 'package:chat_chit/constant/app_state.dart';
import 'package:chat_chit/constant/sns_constant/sns_type.dart';
import 'package:chat_chit/ui/messages/messages_route.dart';
import 'package:chat_chit/ui/splash/splash_bloc.dart';
import 'package:chat_chit/utils/extensions.dart';
import 'package:chat_chit/widgets/action_button.dart';
import 'package:chat_chit/widgets/padding_widgets.dart';
import 'package:chat_chit/widgets/screen_content_container.dart';
import 'package:chat_chit/widgets/text_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SplashView extends StatefulWidget {
  @override
  _SplashViewState createState() => _SplashViewState();
}

class _SplashViewState extends BaseStateBloc<SplashView, SplashBloc> {
  final String _imageFolderPath = "assets/images";

  @override
  void initState() {
    super.initState();

    getBloc().splashScreenStreamController.stream.listen((event) {
      switch (event) {
        case UserStates.LOGGED_IN:
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) {
                return messagesRoute;
              },
            ),
          );
          break;
        case UserStates.NOT_LOGGED_IN:
          break;
        case UserStates.WRONG_LOG_INFO:
          break;
        case UserStates.SIGNED_UP:
          break;
        case UserStates.NOT_SIGNED_UP:
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalleteColor.PURPLE_COLOR,
      body: StreamBuilder(
        stream: getBloc().splashScreenStreamController.stream,
        builder: (context, snapshot) {
          return Stack(
            children: [
              _backgroundImage(),
              getBloc().userStates == UserStates.NOT_LOGGED_IN
                  ? _signOptionContent(
                      facebookDisplayText: "SIGN IN WITH FACEBOOK",
                      googleDisplayText: "SIGN IN WITH GOOGLE",
                      appleDisplayText: "SIGN IN WITH APPLE",
                      kakaoDisplayText: "SIGN IN WITH KAKAO",
                    )
                  : _signOptionContent(
                      facebookDisplayText: "SIGN UP WITH FACEBOOK",
                      googleDisplayText: "SIGN UP WITH GOOGLE",
                      appleDisplayText: "SIGN UP WITH APPLE",
                      kakaoDisplayText: "SIGN UP WITH KAKAO",
                    ),
            ],
          );
        },
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

  /// Sign option button
  Widget _signOptionContent({
    String facebookDisplayText,
    String googleDisplayText,
    String appleDisplayText,
    String kakaoDisplayText,
  }) {
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
                  textContent: getBloc().userStates == UserStates.NOT_LOGGED_IN
                      ? "Welcome back"
                      : "Let's join us!",
                  fontWeight: FontWeight.bold,
                  fontSize: 22.0,
                ),
              ),
              AppPaddingWidget(
                paddingTop: 10.0,
                child: AppTextWidget(
                  textContent: getBloc().userStates == UserStates.NOT_LOGGED_IN
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
                  onPressed: () {
                    getBloc().chooseLogInOrSignUpAction(
                        getBloc().userStates, SNSTypes.FACEBOOK);
                  },
                ),
              ),
              AppPaddingWidget(
                paddingTop: 20.0,
                child: AppActionsButton(
                  buttonContent: googleDisplayText,
                  borderSideColor: Color(0xFFE9433A),
                  onPressed: () {},
                ),
              ),
              AppPaddingWidget(
                paddingTop: 20.0,
                child: AppActionsButton(
                  buttonContent: appleDisplayText,
                  borderSideColor: Color(0xFF8A8A8A),
                  onPressed: () {},
                ),
              ),
              AppPaddingWidget(
                paddingTop: 20.0,
                child: AppActionsButton(
                  buttonContent: kakaoDisplayText,
                  borderSideColor: Color(0xFF331919),
                  onPressed: () {},
                ),
              ),
              AppPaddingWidget(
                paddingTop: 20.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppTextWidget(
                      textContent:
                          getBloc().userStates == UserStates.NOT_LOGGED_IN
                              ? "Don't have any account?"
                              : "Already have an account?",
                      fontSize: 20.0,
                    ),
                    InkWell(
                      onTap: () => getBloc().onSplashActionPressed(),
                      child: AppTextWidget(
                        textContent:
                            getBloc().userStates == UserStates.NOT_LOGGED_IN
                                ? " Sign up"
                                : " Sign in",
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
  }
}
