import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider to track if a screen has handled a back-button press internally.
/// This prevents the global [MainScaffold] PopScope from redirecting to Home
/// when a sub-screen (like Hadith or Azkar) just wanted to revert its internal selection.
final backButtonInterceptorProvider =
    NotifierProvider<BackButtonInterceptor, bool>(BackButtonInterceptor.new);

class BackButtonInterceptor extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool value) => state = value;
}
