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

  // Initialize audio_service. Phase 10 replaces this with the composite
  // JrrAudioHandler that swaps in AndroidAutoPlayerService for the car;
  // until then LocalPlayerService is the only handler.
  final localAudioPlayer = AudioPlayer();
  final localHandler = LocalPlayerService(
    player: localAudioPlayer,
    talker: talker,
    qualityResolver: () => LocalAudioQuality.fromName(
      getIt<SharedPreferences>().getString('local_audio_quality'),
    ),
  );

  await AudioService.init(
    builder: () => localHandler,
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.jriver.remote.audio',
      androidNotificationChannelName: 'JRiver Remote playback',
      androidNotificationIcon: 'drawable/ic_audio_service_notification',
      androidNotificationOngoing: true,
    ),
  );
  await localHandler.init();

  getIt.registerSingleton<LocalPlayerService>(localHandler);

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
