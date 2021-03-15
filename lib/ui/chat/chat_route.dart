import 'package:chat_chit/repo/user_repo.dart';
import 'package:provider/provider.dart';

import 'chat_bloc.dart';
import 'chat_view.dart';

var chatRoute = ProxyProvider<UserRepo, ChatBloc>(
  create: (context) {
    return ChatBloc(
      userRepo: Provider.of<UserRepo>(context, listen: false),
    );
  },
  update: (context, userRepo, chatBloc) {
    return chatBloc;
  },
  dispose: (context, chatBloc) => chatBloc.dispose(),
  child: ChatView(),
);
