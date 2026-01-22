import 'package:flutter/foundation.dart';
import 'base_state.dart';

abstract class BaseViewModel extends ChangeNotifier {
  BaseState _state = const BaseState();

  BaseState get state => _state;

  bool get isLoading => _state.isLoading;
  String? get error => _state.error;

  void setLoading(bool value) {
    _state = _state.copyWith(isLoading: value);
    notifyListeners();
  }

  void setError(String? message) {
    _state = _state.copyWith(error: message);
    notifyListeners();
  }

  void clearError() {
    _state = _state.copyWith(error: null);
    notifyListeners();
  }
}
