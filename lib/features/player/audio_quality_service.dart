import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import 'data/models/local_audio_quality.dart';

const _kQualityKey = 'local_audio_quality';

/// Owns the user-selected MCWS conversion preset for the local zone.
/// Persists to SharedPreferences so the choice survives restarts and
/// exposes a stream so the [LocalAudioQualityCubit] companion can mirror
/// it into widget rebuilds. Audio handlers read [state] when constructing
/// each new stream URL.
class AudioQualityService {
  final SharedPreferences _prefs;
  final _controller = StreamController<LocalAudioQuality>.broadcast();

  LocalAudioQuality _state;

  AudioQualityService({required SharedPreferences prefs})
    : _prefs = prefs,
      _state = LocalAudioQuality.fromName(prefs.getString(_kQualityKey));

  LocalAudioQuality get state => _state;
  Stream<LocalAudioQuality> get stream => _controller.stream;

  Future<void> set(LocalAudioQuality quality) async {
    if (_state == quality) return;
    _state = quality;
    await _prefs.setString(_kQualityKey, quality.name);
    _controller.add(quality);
  }

  Future<void> dispose() => _controller.close();
}
