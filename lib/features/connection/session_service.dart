import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker/talker.dart';

import '../../core/error/app_exception.dart';
import '../zones/data/models/zone.dart';
import '../zones/data/repositories/zone_repository.dart';
import 'bloc/session_state.dart';
import 'data/models/server_info.dart';
import 'data/repositories/connection_repository.dart';

/// Owns the connection lifecycle: silent reconnect, manual connect, logout,
/// offline-mode opt-in.
///
/// Exposes a Cubit-shaped surface ([state] + [stream]) but isn't a Cubit —
/// it lives in the DI container so the rest of the app can observe session
/// state without coupling to the bloc widget tree.
class SessionService {
  final ConnectionRepository _repo;
  final SharedPreferences _prefs;
  final Talker _talker;

  final StreamController<SessionState> _controller =
      StreamController<SessionState>.broadcast();
  SessionState _state = const SessionState.restoring();

  SessionService({
    required ConnectionRepository repository,
    required SharedPreferences prefs,
    required Talker talker,
  }) : _repo = repository,
       _prefs = prefs,
       _talker = talker {
    // Defer the silent reconnect off the construction stack so callers
    // can subscribe to [stream] before the first emit lands.
    scheduleMicrotask(_attemptSilentReconnect);
  }

  /// Current session state — synchronous snapshot.
  SessionState get state => _state;

  /// Broadcast stream of state changes. Late subscribers do not replay
  /// the current value; pair with [state] for the initial snapshot.
  Stream<SessionState> get stream => _controller.stream;

  void _emit(SessionState next) {
    if (_state == next) return;
    _state = next;
    _controller.add(next);
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
        _emit(const SessionState.authenticated(serverInfo: ServerInfo.offline));
      } else {
        _talker.debug('[Session] No saved server with token — showing login');
        _emit(const SessionState.unauthenticated());
      }
      return;
    }

    if (lastZoneGuid == Zone.offline.guid) {
      _talker.info('[Session] Last zone was Offline — skipping reconnect');
      await _repo.restoreSession(server);
      final scheme = server.useSsl ? 'https' : 'http';
      final activePort = server.useSsl ? server.sslPort : server.port;
      _emit(
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
      _emit(const SessionState.unauthenticated());
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
        _emit(const SessionState.unauthenticated());
      },
      (info) {
        _talker.info(
          '[Session] Silent reconnect succeeded: ${info.name} '
          '(${info.version} on ${info.platform})',
        );
        _emit(SessionState.authenticated(serverInfo: info));
      },
    );
  }

  Future<void> enterOfflineMode() async {
    _talker.info('[Session] Entering Offline Mode manually');
    await _prefs.setString(kActiveZoneGuidKey, Zone.offline.guid);
    _emit(const SessionState.authenticated(serverInfo: ServerInfo.offline));
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
        _emit(SessionState.authenticated(serverInfo: info));
        return null;
      },
    );
  }

  Future<void> logout() async {
    _talker.info('[Session] Logout');
    await _repo.clearSession();
    _emit(const SessionState.unauthenticated());
  }

  Future<void> dispose() async => _controller.close();
}
