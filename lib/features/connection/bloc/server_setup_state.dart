import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/error/app_exception.dart';

part 'server_setup_state.freezed.dart';

@freezed
sealed class ServerSetupState with _$ServerSetupState {
  const factory ServerSetupState.idle() = ServerSetupIdle;
  const factory ServerSetupState.connecting() = ServerSetupConnecting;
  const factory ServerSetupState.failed({required AppException error}) =
      ServerSetupFailed;
}
