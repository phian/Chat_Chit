import 'package:chat_chit/base/base_state_bloc.dart';
import 'package:chat_chit/constant/app_color.dart';
import 'package:chat_chit/ui/messages/messages_bloc.dart';
import 'package:chat_chit/utils/extensions.dart';
import 'package:chat_chit/widgets/padding_widgets.dart';
import 'package:chat_chit/widgets/screen_content_container.dart';
import 'package:chat_chit/widgets/text_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MessagesView extends StatefulWidget {
  @override
  _MessagesViewState createState() => _MessagesViewState();
}

class _MessagesViewState extends BaseStateBloc<MessagesView, MessagesBloc> {
  final String imagePath = "assets/images";

  @override
  void initState() {
    super.initState();
    getBloc().userRepo.firebaseAPI.getFacebookUserFromFireBase(
        getBloc().userRepo.facebookAPI.accessToken);
    getBloc().userRepo.firebaseAPI.getAllUserFromFirebase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalleteColor.PURPLE_COLOR,
      body: Align(
        alignment: Alignment.bottomCenter,
        child: CustomContainer(
          height: context.getScreenHeight(context) * 0.7,
          child: AppPaddingWidget(
            horizontal: 15.0,
            child: StreamBuilder(
              stream: getBloc().userRepo.firebaseAPI.getAllUserFromFirebase(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: AppTextWidget(textContent: "Loading..."),
                  );
                }
                return ListView.separated(
                  physics: AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  itemBuilder: (context, index) {
                    return (getBloc().userRepo.firebaseUser.uid !=
                            snapshot.data.docs[index]['id'])
                        ? _messageDisplayWidget(
                            document: snapshot.data.docs[index],
                          )
                        : Container();
                  },
                  separatorBuilder: (context, index) {
                    return Divider(
                      color: Colors.grey,
                    );
                  },
                  itemCount: snapshot.data.docs.length,
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  /// Message display widget
  Widget _messageDisplayWidget({DocumentSnapshot document}) {
    return Container(
      child: ListTile(
        leading: Image.network(
          document['profile_image'],
          width: 50.0,
          height: 50.0,
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
                      textContent: document['name'],
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
                            textContent:
                                "Chat content heredsdasdasdasdasdasdsadsadsadasdasdasdsadsadsad",
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
          getBloc().navigateToChatScreen(context, document);
        },
      ),
    );
  }
}
