import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker/talker.dart';

import '../../../core/error/app_exception.dart';
import '../../zones/data/models/zone.dart';
import '../../zones/data/repositories/zone_repository.dart';
import '../data/models/server_info.dart';
import '../data/repositories/connection_repository.dart';
import 'session_state.dart';

/// Owns the connection lifecycle: silent reconnect, manual connect, logout,
/// offline-mode opt-in. State is consumed by the root router to swap between
/// the login screen and the authenticated shell.
class SessionCubit extends Cubit<SessionState> {
  final ConnectionRepository _repo;
  final SharedPreferences _prefs;
  final Talker _talker;

  SessionCubit({
    required ConnectionRepository repository,
    required SharedPreferences prefs,
    required Talker talker,
  }) : _repo = repository,
       _prefs = prefs,
       _talker = talker,
       super(const SessionState.restoring()) {
    _attemptSilentReconnect();
  }

  Future<void> _attemptSilentReconnect() async {
    _talker.info('[Session] Attempting silent reconnect');
    final server = await _repo.getLastServerWithToken();
    final lastZoneGuid = _prefs.getString(kActiveZoneGuidKey);

    if (server == null) {
      if (lastZoneGuid == Zone.offline.guid) {
        _talker.info(
          '[Session] No server but last zone was Offline — entering Offline Mode',
        );
        emit(const SessionState.authenticated(serverInfo: ServerInfo.offline));
      } else {
        _talker.debug('[Session] No saved server with token — showing login');
        emit(const SessionState.unauthenticated());
      }
      return;
    }

    if (lastZoneGuid == Zone.offline.guid) {
      _talker.info('[Session] Last zone was Offline — skipping reconnect');
      await _repo.restoreSession(server);
      final scheme = server.useSsl ? 'https' : 'http';
      final activePort = server.useSsl ? server.sslPort : server.port;
      emit(
        SessionState.authenticated(
          serverInfo: ServerInfo(
            id: 'offline-cached-server',
            name: server.friendlyName ?? 'JRiver (${server.host})',
            version: 'offline',
            platform: 'offline',
            address: '$scheme://${server.host}:$activePort',
          ),
        ),
      );
      return;
    }

    final password = await _repo.getPassword(server.passwordKey);
    if (password == null) {
      _talker.debug('[Session] Saved server has no password — showing login');
      emit(const SessionState.unauthenticated());
      return;
    }

    _talker.info('[Session] Reconnecting to ${server.host}:${server.port}');
    final result = await _repo.connect(
      host: server.host,
      port: server.port,
      username: server.username,
      password: password,
      useSsl: server.useSsl,
      sslPort: server.sslPort,
    );
    result.fold(
      (e) {
        _talker.warning('[Session] Silent reconnect failed: $e');
        emit(const SessionState.unauthenticated());
      },
      (info) {
        _talker.info(
          '[Session] Silent reconnect succeeded: ${info.name} '
          '(${info.version} on ${info.platform})',
        );
        emit(SessionState.authenticated(serverInfo: info));
      },
    );
  }

  Future<void> enterOfflineMode() async {
    _talker.info('[Session] Entering Offline Mode manually');
    await _prefs.setString(kActiveZoneGuidKey, Zone.offline.guid);
    emit(const SessionState.authenticated(serverInfo: ServerInfo.offline));
  }

  /// Manual connect. Returns null on success, [AppException] on failure.
  Future<AppException?> connect({
    required String host,
    required int port,
    required String username,
    required String password,
    bool useSsl = false,
    int sslPort = 52200,
  }) async {
    _talker.info(
      '[Session] Connecting to $host:$port as $username '
      '(ssl=$useSsl, sslPort=$sslPort)',
    );
    final result = await _repo.connect(
      host: host,
      port: port,
      username: username,
      password: password,
      useSsl: useSsl,
      sslPort: sslPort,
    );
    return result.fold(
      (e) {
        _talker.error('[Session] Connect failed', e);
        return e;
      },
      (info) {
        _talker.info(
          '[Session] Connected to ${info.name} '
          '(${info.version} on ${info.platform})',
        );
        emit(SessionState.authenticated(serverInfo: info));
        return null;
      },
    );
  }

  Future<void> logout() async {
    _talker.info('[Session] Logout');
    await _repo.clearSession();
    emit(const SessionState.unauthenticated());
  }
}
