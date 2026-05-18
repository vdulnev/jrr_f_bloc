import 'dart:io' show Platform;

import 'package:audio_service/audio_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:just_audio/just_audio.dart';
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
import '../../features/offline/download_jobs_service.dart';
import '../../features/offline/downloaded_tracks_service.dart';
import '../../features/offline/services/download_service.dart';
import '../../features/player/data/models/local_audio_quality.dart';
import '../../features/player/data/repositories/player_repository.dart';
import '../../features/player/data/repositories/player_repository_impl.dart';
import '../../features/player/data/repositories/recently_played_repository.dart';
import '../../features/player/mcws_player_service.dart';
import '../../features/player/local_playback_service.dart';
import '../../features/player/player_service.dart';
import '../../features/player/services/android_auto_player_service.dart';
import '../../features/player/services/jrr_audio_handler.dart';
import '../../features/player/services/local_player_service.dart';
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

  // Download services — stream pipes off DownloadsRepository. Registered
  // before LocalPlaybackService (Phase 7) which subscribes to the
  // downloaded-tracks stream to reload the local queue on changes.
  getIt.registerSingleton<DownloadJobsService>(
    DownloadJobsService(repository: getIt<DownloadsRepository>()),
  );
  getIt.registerSingleton<DownloadedTracksService>(
    DownloadedTracksService(repository: getIt<DownloadsRepository>()),
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

  // Audio handlers — phone-side and Android Auto playback engines.
  final localAudioPlayer = AudioPlayer();
  final autoAudioPlayer = AudioPlayer();

  LocalAudioQuality resolveQuality() => LocalAudioQuality.fromName(
    prefs.getString('local_audio_quality'),
  );

  final localHandler = LocalPlayerService(
    player: localAudioPlayer,
    talker: getIt<Talker>(),
    qualityResolver: resolveQuality,
  );

  final autoHandler = AndroidAutoPlayerService(
    player: autoAudioPlayer,
    talker: getIt<Talker>(),
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

  // MCWS remote player — owns remote playback polling and commands.
  // Registered eagerly so polling starts at boot. Depends on SessionService.
  getIt.registerSingleton<McwsPlayerService>(
    McwsPlayerService(
      repository: getIt<PlayerRepository>(),
      library: getIt<LibraryRepository>(),
      session: getIt<SessionService>(),
      activeZone: getIt<ActiveZoneService>(),
      talker: getIt<Talker>(),
    ),
  );

  // Local player — owns local playback state, persistence, and downloads
  // listener. Registered eagerly so the per-zone queue restores at boot.
  getIt.registerSingleton<LocalPlaybackService>(
    LocalPlaybackService(
      service: getIt<LocalPlayerService>(),
      activeZone: getIt<ActiveZoneService>(),
      queueRepository: getIt<LocalQueueRepository>(),
      downloadsRepository: getIt<DownloadsRepository>(),
      prefs: prefs,
      talker: getIt<Talker>(),
    ),
  );

  // Player facade — routes snapshots from MCWS / Local based on active zone.
  getIt.registerSingleton<PlayerService>(
    PlayerService(
      mcws: getIt<McwsPlayerService>(),
      local: getIt<LocalPlaybackService>(),
      activeZone: getIt<ActiveZoneService>(),
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
