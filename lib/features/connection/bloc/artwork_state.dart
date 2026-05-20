import 'package:freezed_annotation/freezed_annotation.dart';

part 'artwork_state.freezed.dart';

/// The minimum a widget needs to address a server-hosted artwork URI:
/// the absolute MCWS base address and the current auth token (or null
/// when neither is available, i.e. the session isn't authenticated).
@freezed
sealed class ArtworkState with _$ArtworkState {
  const ArtworkState._();

  const factory ArtworkState({
    required String? serverAddress,
    required String? token,
  }) = _ArtworkState;

  /// Composes a `File/GetImage` URL for [fileKey]. Returns null when no
  /// authenticated session is available — the widget then renders its
  /// placeholder.
  String? urlFor(int? fileKey) {
    if (fileKey == null || fileKey < 0) return null;
    final address = serverAddress;
    if (address == null || address.isEmpty) return null;
    final t = token;
    final tokenParam = (t != null && t.isNotEmpty) ? '&Token=$t' : '';
    return '$address/MCWS/v1/File/GetImage?File=$fileKey$tokenParam';
  }
}
