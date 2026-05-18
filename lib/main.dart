import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show DeviceOrientation, SystemChrome;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:talker/talker.dart';
import 'package:talker_bloc_logger/talker_bloc_logger.dart';

import 'app.dart';
import 'core/di/injection.dart';
import 'core/logging/file_log_observer.dart';
import 'core/network/ssl_trust.dart';

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

  // Note: TalkerBlocLoggerSettings defaults `printChanges` to false, which
  // silences every Cubit.emit() — and most of our state machines are
  // Cubits. Flip it on (plus creations/closings) so the observer is
  // actually useful in the log file.
  Bloc.observer = TalkerBlocObserver(
    talker: talker,
    settings: const TalkerBlocLoggerSettings(
      printChanges: true,
      printCreations: true,
      printClosings: true,
      printStateFullData: false,
      printEventFullData: false,
    ),
  );

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
