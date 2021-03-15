import 'package:chat_chit/models/sns_models/sns_model.dart';

abstract class SNSAuth<T extends SNSModel, A> { // A: Sign in type
  Future<A> getCurrentSignIn();

  Future<A> getNewSignIn();

  Future<T> getCurrentAccount();

  Future<void> logOut();

  Future<String> getCurrentToken();
}