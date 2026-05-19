// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'downloaded_album_detail_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DownloadedAlbumDetailState {

 Tracks get tracks;
/// Create a copy of DownloadedAlbumDetailState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DownloadedAlbumDetailStateCopyWith<DownloadedAlbumDetailState> get copyWith => _$DownloadedAlbumDetailStateCopyWithImpl<DownloadedAlbumDetailState>(this as DownloadedAlbumDetailState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DownloadedAlbumDetailState&&(identical(other.tracks, tracks) || other.tracks == tracks));
}


@override
int get hashCode => Object.hash(runtimeType,tracks);

@override
String toString() {
  return 'DownloadedAlbumDetailState(tracks: $tracks)';
}


}

/// @nodoc
abstract mixin class $DownloadedAlbumDetailStateCopyWith<$Res>  {
  factory $DownloadedAlbumDetailStateCopyWith(DownloadedAlbumDetailState value, $Res Function(DownloadedAlbumDetailState) _then) = _$DownloadedAlbumDetailStateCopyWithImpl;
@useResult
$Res call({
 Tracks tracks
});


$TracksCopyWith<$Res> get tracks;

}
/// @nodoc
class _$DownloadedAlbumDetailStateCopyWithImpl<$Res>
    implements $DownloadedAlbumDetailStateCopyWith<$Res> {
  _$DownloadedAlbumDetailStateCopyWithImpl(this._self, this._then);

  final DownloadedAlbumDetailState _self;
  final $Res Function(DownloadedAlbumDetailState) _then;

/// Create a copy of DownloadedAlbumDetailState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tracks = null,}) {
  return _then(_self.copyWith(
tracks: null == tracks ? _self.tracks : tracks // ignore: cast_nullable_to_non_nullable
as Tracks,
  ));
}
/// Create a copy of DownloadedAlbumDetailState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TracksCopyWith<$Res> get tracks {
  
  return $TracksCopyWith<$Res>(_self.tracks, (value) {
    return _then(_self.copyWith(tracks: value));
  });
}
}


/// Adds pattern-matching-related methods to [DownloadedAlbumDetailState].
extension DownloadedAlbumDetailStatePatterns on DownloadedAlbumDetailState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DownloadedAlbumDetailState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DownloadedAlbumDetailState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DownloadedAlbumDetailState value)  $default,){
final _that = this;
switch (_that) {
case _DownloadedAlbumDetailState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DownloadedAlbumDetailState value)?  $default,){
final _that = this;
switch (_that) {
case _DownloadedAlbumDetailState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Tracks tracks)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DownloadedAlbumDetailState() when $default != null:
return $default(_that.tracks);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Tracks tracks)  $default,) {final _that = this;
switch (_that) {
case _DownloadedAlbumDetailState():
return $default(_that.tracks);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Tracks tracks)?  $default,) {final _that = this;
switch (_that) {
case _DownloadedAlbumDetailState() when $default != null:
return $default(_that.tracks);case _:
  return null;

}
}

}

/// @nodoc


class _DownloadedAlbumDetailState implements DownloadedAlbumDetailState {
  const _DownloadedAlbumDetailState({this.tracks = Tracks.empty});
  

@override@JsonKey() final  Tracks tracks;

/// Create a copy of DownloadedAlbumDetailState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DownloadedAlbumDetailStateCopyWith<_DownloadedAlbumDetailState> get copyWith => __$DownloadedAlbumDetailStateCopyWithImpl<_DownloadedAlbumDetailState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DownloadedAlbumDetailState&&(identical(other.tracks, tracks) || other.tracks == tracks));
}


@override
int get hashCode => Object.hash(runtimeType,tracks);

@override
String toString() {
  return 'DownloadedAlbumDetailState(tracks: $tracks)';
}


}

/// @nodoc
abstract mixin class _$DownloadedAlbumDetailStateCopyWith<$Res> implements $DownloadedAlbumDetailStateCopyWith<$Res> {
  factory _$DownloadedAlbumDetailStateCopyWith(_DownloadedAlbumDetailState value, $Res Function(_DownloadedAlbumDetailState) _then) = __$DownloadedAlbumDetailStateCopyWithImpl;
@override @useResult
$Res call({
 Tracks tracks
});


@override $TracksCopyWith<$Res> get tracks;

}
/// @nodoc
class __$DownloadedAlbumDetailStateCopyWithImpl<$Res>
    implements _$DownloadedAlbumDetailStateCopyWith<$Res> {
  __$DownloadedAlbumDetailStateCopyWithImpl(this._self, this._then);

  final _DownloadedAlbumDetailState _self;
  final $Res Function(_DownloadedAlbumDetailState) _then;

/// Create a copy of DownloadedAlbumDetailState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tracks = null,}) {
  return _then(_DownloadedAlbumDetailState(
tracks: null == tracks ? _self.tracks : tracks // ignore: cast_nullable_to_non_nullable
as Tracks,
  ));
}

/// Create a copy of DownloadedAlbumDetailState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TracksCopyWith<$Res> get tracks {
  
  return $TracksCopyWith<$Res>(_self.tracks, (value) {
    return _then(_self.copyWith(tracks: value));
  });
}
}

// dart format on
