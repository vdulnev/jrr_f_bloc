import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../audio_quality_service.dart';
import '../data/models/local_audio_quality.dart';

/// Companion of the audio-quality popup. Mirrors [AudioQualityService]
/// state into widget rebuilds and forwards selections back to the
/// service.
class LocalAudioQualityCubit extends Cubit<LocalAudioQuality> {
  final AudioQualityService _service;
  StreamSubscription<LocalAudioQuality>? _sub;

  LocalAudioQualityCubit({required AudioQualityService service})
    : _service = service,
      super(service.state) {
    _sub = _service.stream.listen(emit);
  }

  Future<void> set(LocalAudioQuality quality) => _service.set(quality);

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
