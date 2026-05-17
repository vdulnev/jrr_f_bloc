import 'dart:io' show Platform;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker/talker.dart';

import '../db/app_database.dart';
import '../logging/file_log_observer.dart';
import '../network/mcws_xml_parser.dart';

final getIt = GetIt.instance;

/// Phase 1 DI: long-lived singletons that are not tied to a session or
/// feature. Repositories and bloc factories are registered in later phases
/// as their features come online.
Future<void> configureDependencies() async {
  getIt.registerSingleton<Talker>(
    Talker(
      logger: TalkerLogger(
        settings: TalkerLoggerSettings(enableColors: !Platform.isIOS),
      ),
      observer: FileLogObserver(),
    ),
  );

  getIt.registerSingleton<AppDatabase>(AppDatabase());
  getIt.registerSingleton<FlutterSecureStorage>(const FlutterSecureStorage());

  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);

  getIt.registerSingleton<McwsXmlParser>(McwsXmlParser());
}
