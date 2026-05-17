import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/local_audio_quality.dart';

const _kQualityKey = 'local_audio_quality';

/// Holds the user-selected MCWS conversion preset for the local zone.
/// Persists to SharedPreferences so the choice survives restarts.
class LocalAudioQualityCubit extends Cubit<LocalAudioQuality> {
  final SharedPreferences _prefs;

  LocalAudioQualityCubit({required SharedPreferences prefs})
    : _prefs = prefs,
      super(LocalAudioQuality.fromName(prefs.getString(_kQualityKey)));

  Future<void> set(LocalAudioQuality quality) async {
    await _prefs.setString(_kQualityKey, quality.name);
    emit(quality);
  }
}
