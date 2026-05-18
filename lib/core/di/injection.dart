import 'dart:io' show Platform;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker/talker.dart';

import '../db/app_database.dart';
import '../logging/file_log_observer.dart';
import '../network/mcws_xml_parser.dart';
import '../../features/connection/data/repositories/connection_repository.dart';
import '../../features/connection/data/repositories/connection_repository_impl.dart';
import '../../features/connection/session_service.dart';
import '../../features/favorites/data/repositories/favorites_repository.dart';
import '../../features/favorites/data/repositories/favorites_repository_impl.dart';
import '../../features/favorites/favorites_service.dart';
import '../../features/library/data/repositories/library_repository.dart';
import '../../features/library/data/repositories/library_repository_impl.dart';
import '../../features/library/track_lookup_service.dart';
import '../../features/offline/data/repositories/downloads_repository.dart';
import '../../features/offline/data/repositories/downloads_repository_impl.dart';
import '../../features/offline/services/download_service.dart';
import '../../features/player/data/repositories/player_repository.dart';
import '../../features/player/data/repositories/player_repository_impl.dart';
import '../../features/player/data/repositories/recently_played_repository.dart';
import '../../features/queue/data/repositories/local_queue_repository.dart';
import '../../features/queue/data/repositories/local_queue_repository_impl.dart';
import '../../features/queue/data/repositories/queue_repository.dart';
import '../../features/queue/data/repositories/queue_repository_impl.dart';
import '../../features/zones/active_zone_service.dart';
import '../../features/zones/data/repositories/zone_repository.dart';
import '../../features/zones/data/repositories/zone_repository_impl.dart';
import '../../features/zones/services/android_auto_session_service.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // Talker — single instance, shared by all loggers. The FileLogObserver
  // mirrors every log line to the on-disk session log.
  getIt.registerSingleton<Talker>(
    Talker(
      logger: TalkerLogger(
        settings: TalkerLoggerSettings(enableColors: !Platform.isIOS),
      ),
      observer: FileLogObserver(),
    ),
  );

  // Persistent storage
  getIt.registerSingleton<AppDatabase>(AppDatabase());
  getIt.registerSingleton<FlutterSecureStorage>(const FlutterSecureStorage());

  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);

  // MCWS XML parser — stateless, safe as singleton.
  getIt.registerSingleton<McwsXmlParser>(McwsXmlParser());

  // Connection repository — manages active session and server persistence.
  getIt.registerSingleton<ConnectionRepository>(
    ConnectionRepositoryImpl(
      db: getIt<AppDatabase>(),
      secureStorage: getIt<FlutterSecureStorage>(),
      parser: getIt<McwsXmlParser>(),
      talker: getIt<Talker>(),
    ),
  );

  // Player, zone, queue, library repositories — resolve McwsClient at
  // call-time via the session scope that ConnectionRepository pushes.
  getIt.registerSingleton<PlayerRepository>(PlayerRepositoryImpl());
  getIt.registerSingleton<ZoneRepository>(ZoneRepositoryImpl());
  getIt.registerSingleton<QueueRepository>(QueueRepositoryImpl());
  getIt.registerSingleton<LocalQueueRepository>(
    LocalQueueRepositoryImpl(getIt<AppDatabase>()),
  );
  getIt.registerSingleton<LibraryRepository>(LibraryRepositoryImpl());

  // Offline / Downloads
  getIt.registerSingleton<DownloadsRepository>(
    DownloadsRepositoryImpl(db: getIt<AppDatabase>(), talker: getIt<Talker>()),
  );
  final downloadService = DownloadService(
    repository: getIt<DownloadsRepository>(),
    connectionRepository: getIt<ConnectionRepository>(),
    talker: getIt<Talker>(),
  );
  downloadService.start();
  getIt.registerSingleton<DownloadService>(downloadService);

  // Recently-played history backs the Android Auto "Recent" browse category
  // and (later) phone-side UI. Stored in SharedPreferences as a capped list
  // of file keys.
  getIt.registerSingleton<RecentlyPlayedRepository>(
    RecentlyPlayedRepository(prefs),
  );

  // Favorites repository — manages favorite items from the browse screen.
  getIt.registerSingleton<FavoritesRepository>(FavoritesRepositoryImpl());

  // Library track lookup — File/GetInfo enrichment for the Now Playing
  // header. Stateless apart from the last-resolved track snapshot.
  getIt.registerSingleton<TrackLookupService>(
    TrackLookupService(repository: getIt<LibraryRepository>()),
  );

  // Favorites — owns the favorited-browse-nodes list.
  getIt.registerSingleton<FavoritesService>(
    FavoritesService(repository: getIt<FavoritesRepository>()),
  );

  // ActiveZone — tracks which zone the user is targeting. Lives in the
  // service container so blocs (player, queue, mcws-player, etc.)
  // observe it without each owning a private subscription chain.
  getIt.registerSingleton<ActiveZoneService>(
    ActiveZoneService(prefs: prefs, talker: getIt<Talker>()),
  );

  // Session — owns the connection lifecycle. Constructed here so its
  // silent-reconnect attempt fires at app boot rather than waiting on a
  // BlocProvider in the widget tree. UI/blocs read it from GetIt.
  getIt.registerSingleton<SessionService>(
    SessionService(
      repository: getIt<ConnectionRepository>(),
      prefs: prefs,
      talker: getIt<Talker>(),
    ),
  );

  // Android Auto session detection — flipped to "connected" the first time
  // Auto calls into the audio handler's browse API and back to
  // "disconnected" after a debounced inactivity timeout. Constructed here
  // so the AA player service can resolve it during its getChildren
  // override.
  getIt.registerSingleton<AndroidAutoSessionService>(
    AndroidAutoSessionService(),
  );
}
