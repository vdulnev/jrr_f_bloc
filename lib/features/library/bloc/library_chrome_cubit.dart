import 'package:flutter_bloc/flutter_bloc.dart';

/// Controls whether the library chrome (parent header + root mini player)
/// is visible. Scroll listeners in tab screens toggle this to maximize the
/// list area on scroll-down and restore it on scroll-up.
class LibraryChromeCubit extends Cubit<bool> {
  LibraryChromeCubit() : super(true);

  void set(bool value) {
    if (state != value) emit(value);
  }
}
