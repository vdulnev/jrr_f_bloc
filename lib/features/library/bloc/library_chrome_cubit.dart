import 'package:flutter_bloc/flutter_bloc.dart';

/// Controls whether the library chrome (header + tab bar) is visible.
/// [ScrollChromeListener] toggles it to false on scroll-down and back to
/// true on scroll-up so the list area grows when the user is scanning.
class LibraryChromeCubit extends Cubit<bool> {
  LibraryChromeCubit() : super(true);

  void set(bool value) {
    if (state != value) emit(value);
  }
}
