import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show DeviceOrientation, SystemChrome;
import 'package:flutter_bloc/flutter_bloc.dart';
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

  // Bloc observer routes every state transition through Talker — and via
  // FileLogObserver into the on-disk session log.
  Bloc.observer = TalkerBlocObserver(
    talker: talker,
    settings: const TalkerBlocLoggerSettings(
      printStateFullData: false,
      printEventFullData: false,
    ),
  );

  // Flutter framework errors (widget build exceptions, layout overflows, etc.)
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

  // Errors thrown outside the Flutter framework (async gaps, platform channels)
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    talker.error('Uncaught platform error', error, stack);
    return true;
  };

  runApp(const App());
}
