import 'package:freezed_annotation/freezed_annotation.dart';

import '../data/models/server_info.dart';

part 'server_manager_state.freezed.dart';

/// View-side projection of the session for the Server Manager screen.
/// `serverInfo` is null when the session isn't authenticated (the screen
/// renders a "not authenticated" placeholder in that case).
@freezed
sealed class ServerManagerState with _$ServerManagerState {
  const factory ServerManagerState({required ServerInfo? serverInfo}) =
      _ServerManagerState;
}
