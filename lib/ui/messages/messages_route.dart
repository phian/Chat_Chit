import 'package:chat_chit/repo/user_repo.dart';
import 'package:chat_chit/ui/messages/messages_view.dart';
import 'package:provider/provider.dart';

import 'messages_bloc.dart';

var messagesRoute = ProxyProvider<UserRepo, MessagesBloc>(
  create: (context) {
    MessagesBloc messagesBloc = MessagesBloc(userRepo: Provider.of<UserRepo>(context, listen: false));

    return messagesBloc;
  },
  update: (context, userRepo, messagesBloc) {
    return messagesBloc;
  },
  dispose: (context, messagesBloc) => messagesBloc.dispose(),
  child: MessagesView(),
);