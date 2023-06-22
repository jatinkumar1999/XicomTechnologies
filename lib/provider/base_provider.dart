import 'package:flutter/material.dart';
import '../enums/app_state.dart';

class BaseProvider extends ChangeNotifier {
  ViewState _state = ViewState.Idle;
  bool isDispose = false;

  ViewState get state => _state;

  void setState(ViewState viewState) {
    _state = viewState;
    customNotify();
  }

  customNotify() {
    if (isDispose == false) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    isDispose = true;
    notifyListeners();
    super.dispose();
  }
}
