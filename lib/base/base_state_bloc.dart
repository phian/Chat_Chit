import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'base_bloc.dart';
import 'base_state.dart';

/// base state class with bloc
abstract class BaseStateBloc<T extends StatefulWidget, B extends BaseBloc>
    extends BaseState<T> {
  /// get Bloc
  /// if call this method in [initState] set [listen] = false
  B getBloc({bool listen = false}) => Provider.of<B>(context, listen: listen);

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    getBloc(listen: false)
        .getErrorMessage()
        .distinct((errorPrev, errorNext) => errorPrev == errorNext)
        .listen((e) {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        buildContent(),
        StreamBuilder<ScreenState>(
          initialData: ScreenState.NORMAL,
          stream: getBloc(listen: false).getScreenState(),
          builder: (context, snapshot) {
            switch (snapshot.data) {
              case ScreenState.NORMAL:
                return Container();
              case ScreenState.LOADING:
                return Container();
              case ScreenState.WHITE_LOADING:
                return Container(
                  color: Colors.white,
                );
              default:
                return Container();
            }
          },
        ),
      ],
    );
  }

  /// use this for screen with loading
  Widget buildContent() => Container();
}