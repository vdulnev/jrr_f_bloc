import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/app_exception.dart';
import '../data/repositories/connection_repository.dart';
import 'server_setup_state.dart';
import 'session_cubit.dart';

/// Drives the submit button on [ServerSetupScreen]: resolves an access key
/// (when applicable), then delegates the actual connect to [SessionCubit].
/// Owns only the per-screen form submission state — credentials live in
/// `TextEditingController`s on the screen itself.
class ServerSetupCubit extends Cubit<ServerSetupState> {
  final ConnectionRepository _repo;
  final SessionCubit _session;

  ServerSetupCubit({
    required ConnectionRepository repository,
    required SessionCubit session,
  }) : _repo = repository,
       _session = session,
       super(const ServerSetupState.idle());

  Future<void> connectWithAccessKey({
    required String accessKey,
    required String username,
    required String password,
    bool useSsl = false,
  }) async {
    emit(const ServerSetupState.connecting());

    final lookup = await _repo.lookupAccessKey(accessKey);
    final resolved = lookup.match((_) => null, (r) => r);
    if (resolved == null) {
      final err = lookup.fold(
        (e) => e,
        (_) => const AppException.unknown(error: 'lookup failed'),
      );
      emit(ServerSetupState.failed(error: err));
      return;
    }

    await _connect(
      host: resolved.host,
      port: resolved.port,
      username: username,
      password: password,
      useSsl: useSsl,
      sslPort: resolved.httpsPort ?? 52200,
    );
  }

  Future<void> connectWithHost({
    required String host,
    required int port,
    required String username,
    required String password,
    bool useSsl = false,
    int sslPort = 52200,
  }) async {
    emit(const ServerSetupState.connecting());
    await _connect(
      host: host,
      port: port,
      username: username,
      password: password,
      useSsl: useSsl,
      sslPort: sslPort,
    );
  }

  Future<void> _connect({
    required String host,
    required int port,
    required String username,
    required String password,
    required bool useSsl,
    required int sslPort,
  }) async {
    final error = await _session.connect(
      host: host,
      port: port,
      username: username,
      password: password,
      useSsl: useSsl,
      sslPort: sslPort,
    );
    emit(
      error != null
          ? ServerSetupState.failed(error: error)
          : const ServerSetupState.idle(),
    );
  }
}
