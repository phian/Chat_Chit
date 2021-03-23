import 'package:chat_chit/base/base_state_bloc.dart';
import 'package:chat_chit/constant/app_color.dart';
import 'package:chat_chit/constant/sns_constant/message_types.dart';
import 'package:chat_chit/models/sns_models/message_model.dart';
import 'package:chat_chit/presentation/send_icon.dart';
import 'package:chat_chit/utils/extensions.dart';
import 'package:chat_chit/widgets/padding_widgets.dart';
import 'package:chat_chit/widgets/screen_content_container.dart';
import 'package:chat_chit/widgets/text_widget.dart';
import 'package:flutter/material.dart';

import 'chat_bloc.dart';

class ChatView extends StatefulWidget {
  @override
  _ChatViewState createState() => _ChatViewState();
}

class _ChatViewState extends BaseStateBloc<ChatView, ChatBloc> {
  TextEditingController _messageFieldController;

  @override
  void initState() {
    super.initState();

    _messageFieldController = TextEditingController();
    // debugPrint("user access token: ${getBloc().userRepo.facebookAPI.accessToken}");
    if (this.mounted) {
      getBloc().listenToMessageChange();
      getBloc().userRepo.firebaseAPI.unSubscribeAllRoomTopic();

      getBloc().getChatRoom().then((value) {
        getBloc()
            .userRepo
            .firebaseAPI
            .messaging
            .subscribeToTopic(getBloc().room.id)
            .then((value) {
          debugPrint("subscribeToTopic success ${getBloc().room.id}");
        });
      });
      getBloc()
          .userRepo
          .firebaseAPI
          .getAllMessagesFromFirebase()
          .listen((event) {
        if (getBloc().userRepo.currentScreen.toLowerCase() == "chat screen") {}
        getBloc().getChatRoom();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // getBloc().userRepo.firebaseAPI.createNotification(getBloc().userRepo.firebaseUser.uid);
    return WillPopScope(
      // ignore: missing_return
      onWillPop: () async {
        Navigator.pop(context, 'Back');
      },
      child: Scaffold(
        appBar: _chatViewAppBar(),
        backgroundColor: AppPalleteColor.PURPLE_COLOR,
        body: Stack(
          children: [
            _chatMessageListView(),
            _chatInputMessageTextField(),
          ],
        ),
      ),
    );
  }

  /// AppBar
  Widget _chatViewAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      title: Row(
        children: [
          ClipRRect(
            child: Image.network(
                getBloc().userRepo.receiveMessageUser.profileImage),
            borderRadius: BorderRadius.circular(90.0),
          ),
          Container(
            margin: EdgeInsets.only(left: 15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextWidget(
                  textContent: getBloc().userRepo.receiveMessageUser.lastName,
                  fontSize: 18.0,
                ),
                Container(
                  width: context.getScreenWidth(context) * 0.24,
                  child: AppTextWidget(
                    textMaxLine: 2,
                    textContent: "Last access time...",
                    fontSize: 15.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        _appBarActionButton(Icons.phone),
        _appBarActionButton(Icons.video_call),
        _appBarActionButton(Icons.info),
      ],
    );
  }

  /// AppBar actions button
  Widget _appBarActionButton(IconData icon) {
    return IconButton(
      icon: Icon(icon),
      onPressed: () {},
    );
  }

  /// Chat input TextField
  Widget _chatInputMessageTextField() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: context.getScreenHeight(context) * 0.1,
        child: AppPaddingWidget(
          paddingLeft: 15.0,
          paddingRight: 15.0,
          paddingBottom: 10.0,
          child: StreamBuilder(
            stream: getBloc().sendMessageStream,
            builder: (context, snapshot) {
              return TextField(
                controller: _messageFieldController,
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    icon: Icon(SendIcon.send),
                    onPressed: () {
                      getBloc().onSendMessageButtonClick(
                          _messageFieldController.text);
                      _messageFieldController = TextEditingController();
                    },
                  ),
                  hintText: "Enter message...",
                  hintStyle: TextStyle(
                    fontSize: 20.0,
                    color: AppPalleteColor.HINT_TEXT_COLOR,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
              );
            },
          ),
        ),
        alignment: Alignment.bottomCenter,
        decoration: BoxDecoration(
          color: AppPalleteColor.WHITE_COLOR,
        ),
      ),
    );
  }

  /// Chat messages ListView
  Widget _chatMessageListView() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: CustomContainer(
        height: context.getScreenHeight(context) * 0.85,
        child: StreamBuilder(
          stream: getBloc().bhMsg,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container();
            }
            return AppPaddingWidget(
              paddingBottom: context.getScreenHeight(context) * 0.1,
              child: ListView.separated(
                physics: AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: EdgeInsets.all(10.0),
                itemBuilder: (context, index) {
                  return _messageBox(
                    type: (snapshot.data[index] as MessageModel).sendUserId ==
                            getBloc().userRepo.firebaseUser.uid
                        ? MessageType.SENT
                        : MessageType.RECEIVED,
                    model: snapshot.data[index],
                  );
                },
                separatorBuilder: (context, index) {
                  return SizedBox(height: 10.0);
                },
                itemCount: snapshot.data.length,
                reverse: true,
                // reverse: true,
              ),
            );
          },
        ),
      ),
    );
  }

  /// Message Box
  Widget _messageBox({
    MessageType type,
    MessageModel model,
  }) {
    return Align(
      alignment: () {
        switch (type) {
          case MessageType.SENT:
            return Alignment.centerRight;
          default:
            return Alignment.centerLeft;
        }
      }(),
      child: Row(
        mainAxisAlignment: type == MessageType.SENT
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          type == MessageType.SENT
              ? _messageContent(model.content, type)
              : _profileImage(type),
          type == MessageType.SENT
              ? _profileImage(type)
              : _messageContent(model.content, type),
        ],
      ),
    );
  }

  /// Profile image
  Widget _profileImage(MessageType type) {
    return ClipRRect(
      child: Image.network(
        type == MessageType.SENT
            ? getBloc().userRepo.firebaseUser.photoURL
            : getBloc().userRepo.receiveMessageUser.profileImage,
      ),
      borderRadius: BorderRadius.circular(90.0),
    );
  }

  /// Message content
  Widget _messageContent(String content, MessageType type) {
    return Container(
      margin: type == MessageType.SENT
          ? EdgeInsets.only(right: 10.0)
          : EdgeInsets.only(left: 10.0),
      alignment: Alignment.center,
      child: AppTextWidget(
        textContent: content,
      ),
      width: 100.0,
      height: 60.0,
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(
          10,
        ),
      ),
    );
  }
}
