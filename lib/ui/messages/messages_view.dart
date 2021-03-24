import 'package:chat_chit/base/base_state_bloc.dart';
import 'package:chat_chit/constant/app_color.dart';
import 'package:chat_chit/models/sns_models/facebook_user_model.dart';
import 'package:chat_chit/ui/messages/messages_bloc.dart';
import 'package:chat_chit/utils/extensions.dart';
import 'package:chat_chit/widgets/loading.dart';
import 'package:chat_chit/widgets/padding_widgets.dart';
import 'package:chat_chit/widgets/screen_content_container.dart';
import 'package:chat_chit/widgets/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MessagesView extends StatefulWidget {
  @override
  _MessagesViewState createState() => _MessagesViewState();
}

class _MessagesViewState extends BaseStateBloc<MessagesView, MessagesBloc> {
  final String imagePath = "assets/images";

  @override
  void initState() {
    super.initState();

    getBloc().getAllLastMessageForUsers();
    getBloc().listenToMessageChange();
    getBloc().userRepo.firebaseAPI.subscribeAllRoomTopic();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: _messageScreenAppBar(),
      backgroundColor: AppPalleteColor.PURPLE_COLOR,
      body: Stack(
        children: [
          _searchBox(),
          _messagesScreenListView(),
        ],
      ),
    );
  }

  /// AppBar
  Widget _messageScreenAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      leading: Row(
        children: [
          Container(
            transform: Matrix4.translationValues(15.0, 0.0, 0.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(10.0),
              onTap: () => _getImageChoiceDialog(),
              child: StreamBuilder(
                stream: getBloc().updateImageStream,
                builder: (context, snapshot) {
                  return ClipRRect(
                    child: Image.network(
                      snapshot.data,
                      fit: BoxFit.contain,
                    ),
                    borderRadius: BorderRadius.circular(90.0),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {},
        ),
      ],
    );
  }

  /// Search Box
  Widget _searchBox() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppPaddingWidget(
          paddingLeft: 15.0,
          paddingTop: 10.0,
          child: AppTextWidget(
            textContent: "Chats",
            fontSize: 30.0,
            textColor: AppPalleteColor.WHITE_COLOR,
            fontWeight: FontWeight.w400,
          ),
        ),
        AppPaddingWidget(
          paddingLeft: 15.0,
          paddingRight: 15.0,
          paddingTop: 10.0,
          child: TextField(
            style: TextStyle(
              fontSize: 15.0,
              color: AppPalleteColor.HINT_TEXT_COLOR,
            ),
            decoration: InputDecoration(
              fillColor: AppPalleteColor.WHITE_COLOR,
              filled: true,
              prefixIcon: Icon(Icons.search),
              hintText: 'Search for chats',
              hintStyle: TextStyle(
                fontSize: 15.0,
                color: AppPalleteColor.HINT_TEXT_COLOR,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Messages ListView
  Widget _messagesScreenListView() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: CustomContainer(
        height: context.getScreenHeight(context) * 0.72,
        child: AppPaddingWidget(
          horizontal: 15.0,
          child: StreamBuilder(
            stream: getBloc().getMessageStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return LoadingWidget(
                  value: 100,
                );
              }

              return ListView.builder(
                padding: EdgeInsets.only(top: 20.0),
                physics: AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                itemBuilder: (context, index) {
                  return (getBloc().userRepo.firebaseAPI.firebaseUser.uid !=
                          (snapshot.data[index] as FacebookUserModel).id)
                      ? _messageDisplayWidget(
                          user: snapshot.data[index],
                        )
                      : Container();
                },
                itemCount: snapshot.data.length,
              );
            },
          ),
        ),
      ),
    );
  }

  /// Message display widget
  Widget _messageDisplayWidget({FacebookUserModel user}) {
    return Container(
      child: Column(
        children: [
          ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(90.0),
              child: Image.network(
                user.profileImage,
                width: 50.0,
                height: 50.0,
              ),
            ),
            title: Column(
              children: [
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: context.getScreenWidth(context) * 0.5,
                        child: AppTextWidget(
                          textContent: user.name,
                          fontWeight: FontWeight.bold,
                          textMaxLine: 2,
                        ),
                      ),
                      AppTextWidget(textContent: "Hour"),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        child: Row(
                          children: [
                            Icon(Icons.check),
                            Container(
                              width: context.getScreenWidth(context) * 0.5,
                              child: AppTextWidget(
                                textContent: user.lastMessage == null
                                    ? "Let's send first message"
                                    : user.lastMessage,
                                textMaxLine: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AppPaddingWidget(
                        paddingRight: 7.0,
                        child: Container(
                          alignment: Alignment.center,
                          width: 20.0,
                          height: 20.0,
                          decoration: BoxDecoration(
                            color: AppPalleteColor.PURPLE_COLOR,
                            borderRadius: BorderRadius.circular(90.0),
                          ),
                          child: AppTextWidget(
                            textContent: "1",
                            textColor: AppPalleteColor.WHITE_COLOR,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
            onTap: () {
              getBloc().navigateToChatScreen(context, user);
            },
          ),
          Divider(
            color: Colors.grey,
          ),
        ],
      ),
    );
  }

  Future<void> _getImageChoiceDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: AppPalleteColor.WHITE_COLOR,
              borderRadius: BorderRadius.circular(10.0),
            ),
            width: context.getScreenWidth(context) * 0.5,
            height: context.getScreenHeight(context) * 0.2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppTextWidget(
                  textContent: "Choose an action you want?",
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
                AppPaddingWidget(
                  paddingTop: 10.0,
                  child: FlatButton(
                    color: AppPalleteColor.BLUE_COLOR,
                    onPressed: () =>
                        getBloc().getAndSaveImageIfCan(ImageSource.camera),
                    child: AppTextWidget(
                      textContent: "Camera",
                      textColor: AppPalleteColor.WHITE_COLOR,
                    ),
                  ),
                ),
                FlatButton(
                  onPressed: () =>
                      getBloc().getAndSaveImageIfCan(ImageSource.gallery),
                  color: AppPalleteColor.PURPLE_COLOR,
                  child: AppTextWidget(
                    textContent: "Device",
                    textColor: AppPalleteColor.WHITE_COLOR,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
