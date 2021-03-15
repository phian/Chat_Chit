import 'package:chat_chit/base/base_state_bloc.dart';
import 'package:chat_chit/constant/app_color.dart';
import 'package:chat_chit/constant/sns_constant/message_types.dart';
import 'package:chat_chit/models/sns_models/message_model.dart';
import 'package:chat_chit/presentation/send_icon.dart';
import 'package:chat_chit/utils/extensions.dart';
import 'package:chat_chit/widgets/padding_widgets.dart';
import 'package:chat_chit/widgets/screen_content_container.dart';
import 'package:chat_chit/widgets/text_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
    getBloc().initChatData();
    // getBloc().getChatRoom();
    // getBloc().messages = getBloc().getMessagesFromFirebase(getBloc().room?.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalleteColor.PURPLE_COLOR,
      body: Stack(
        children: [
          _chatMessageListView(),
          _chatInputMessageTextField(),
        ],
      ),
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
                      getBloc()
                          .userRepo
                          .firebaseAPI
                          .addMessage(
                            sendUser: getBloc().firebaseUser,
                            content: _messageFieldController.text,
                            time: DateTime.now(),
                            receiveUser: getBloc()
                                .userRepo
                                .firebaseAPI
                                .receiveMessageUser,
                          )
                          .then((value) {
                        getBloc().checkAddMessageReturnData(value);
                      });

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
        height: context.getScreenHeight(context) * 0.8,
        child: StreamBuilder(
          stream: getBloc().userRepo.firebaseAPI.getAllMessageFromFirebase(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                  child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.red)));
            }

            return StreamBuilder(
              stream: getBloc().bhMsg,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                      child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.red)));
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
                        type: MessageType.SENT,
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
      child: Container(
        alignment: Alignment.center,
        child: AppTextWidget(
          textContent: model.content,
        ),
        width: 100.0,
        height: 60.0,
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(
            10,
          ),
        ),
      ),
    );
  }
}
