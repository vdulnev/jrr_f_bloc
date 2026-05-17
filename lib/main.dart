import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show DeviceOrientation, SystemChrome;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker/talker.dart';
import 'package:talker_bloc_logger/talker_bloc_logger.dart';

import 'app.dart';
import 'core/di/injection.dart';
import 'core/logging/file_log_observer.dart';
import 'core/network/ssl_trust.dart';
import 'features/player/data/models/local_audio_quality.dart';
import 'features/player/services/android_auto_player_service.dart';
import 'features/player/services/jrr_audio_handler.dart';
import 'features/player/services/local_player_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock phones (shortest side < 600dp) to portrait. Tablets/desktop keep
  // all orientations. The check uses the platform view so it runs before
  // any widget tree exists.
  final view = WidgetsBinding.instance.platformDispatcher.views.first;
  final shortestSide = (view.physicalSize / view.devicePixelRatio).shortestSide;
  if (shortestSide < 600) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  // Install before any HttpClient is constructed so saved-server SSL hosts
  // can be added to the trust list as the session is restored.
  JRiverHttpOverrides.install();
  // Truncate-and-open the log file before Talker is constructed so every
  // log from this session lands in the file.
  await FileLogObserver.init();
  await configureDependencies();

  final talker = getIt<Talker>();

  Bloc.observer = TalkerBlocObserver(
    talker: talker,
    settings: const TalkerBlocLoggerSettings(
      printStateFullData: false,
      printEventFullData: false,
    ),
  );

  // Composite audio handler — phone-side playback lives in
  // LocalPlayerService, head-unit playback in AndroidAutoPlayerService.
  // JrrAudioHandler pipes whichever is "active" to the system notification
  // and lock-screen controls. The MediaBrowser overrides always route to
  // the AA player so the head-unit's getChildren / playFromMediaId / etc.
  // hit the right service even when the active zone is local.
  final localAudioPlayer = AudioPlayer();
  final autoAudioPlayer = AudioPlayer();

  LocalAudioQuality resolveQuality() => LocalAudioQuality.fromName(
    getIt<SharedPreferences>().getString('local_audio_quality'),
  );

  final localHandler = LocalPlayerService(
    player: localAudioPlayer,
    talker: talker,
    qualityResolver: resolveQuality,
  );

  final autoHandler = AndroidAutoPlayerService(
    player: autoAudioPlayer,
    talker: talker,
    qualityResolver: resolveQuality,
  );

  final mainHandler = await AudioService.init(
    builder: () =>
        JrrAudioHandler(localPlayer: localHandler, autoPlayer: autoHandler),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.jriver.remote.audio',
      androidNotificationChannelName: 'JRiver Remote playback',
      androidNotificationIcon: 'drawable/ic_audio_service_notification',
      androidNotificationOngoing: true,
    ),
  );

  await localHandler.init();
  await autoHandler.init();

  getIt.registerSingleton<LocalPlayerService>(localHandler);
  getIt.registerSingleton<AndroidAutoPlayerService>(autoHandler);
  getIt.registerSingleton<JrrAudioHandler>(mainHandler);

  // Framework errors (widget build exceptions, layout overflows, etc.)
  FlutterError.onError = (FlutterErrorDetails details) {
    final diagnostics = details.toDiagnosticsNode().toStringDeep(
      minLevel: DiagnosticLevel.debug,
    );
    talker.error(
      'Flutter error: ${details.exceptionAsString()}\n$diagnostics',
      details.exception,
      details.stack,
    );
  };

  // Errors outside the framework (async gaps, platform channels).
  // just_audio reports load cancellations as PlayerInterruptedException;
  // they're handled at the service layer but also surface here.
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    if (error is PlayerInterruptedException) {
      talker.info('just_audio load interrupted: ${error.message}');
      return true;
    }
    talker.error('Uncaught platform error', error, stack);
    return true;
  };

  runApp(const App());
}
