// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'now_playing_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NowPlayingState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NowPlayingState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'NowPlayingState()';
}


}

/// @nodoc
class $NowPlayingStateCopyWith<$Res>  {
$NowPlayingStateCopyWith(NowPlayingState _, $Res Function(NowPlayingState) __);
}


/// Adds pattern-matching-related methods to [NowPlayingState].
extension NowPlayingStatePatterns on NowPlayingState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( NowPlayingLoading value)?  loading,TResult Function( NowPlayingData value)?  data,required TResult orElse(),}){
final _that = this;
switch (_that) {
case NowPlayingLoading() when loading != null:
return loading(_that);case NowPlayingData() when data != null:
return data(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( NowPlayingLoading value)  loading,required TResult Function( NowPlayingData value)  data,}){
final _that = this;
switch (_that) {
case NowPlayingLoading():
return loading(_that);case NowPlayingData():
return data(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( NowPlayingLoading value)?  loading,TResult? Function( NowPlayingData value)?  data,}){
final _that = this;
switch (_that) {
case NowPlayingLoading() when loading != null:
return loading(_that);case NowPlayingData() when data != null:
return data(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  loading,TResult Function( Zone zone,  PlayerStatus? status,  Track? track)?  data,required TResult orElse(),}) {final _that = this;
switch (_that) {
case NowPlayingLoading() when loading != null:
return loading();case NowPlayingData() when data != null:
return data(_that.zone,_that.status,_that.track);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  loading,required TResult Function( Zone zone,  PlayerStatus? status,  Track? track)  data,}) {final _that = this;
switch (_that) {
case NowPlayingLoading():
return loading();case NowPlayingData():
return data(_that.zone,_that.status,_that.track);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  loading,TResult? Function( Zone zone,  PlayerStatus? status,  Track? track)?  data,}) {final _that = this;
switch (_that) {
case NowPlayingLoading() when loading != null:
return loading();case NowPlayingData() when data != null:
return data(_that.zone,_that.status,_that.track);case _:
  return null;

}
}

}

/// @nodoc


class NowPlayingLoading implements NowPlayingState {
  const NowPlayingLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NowPlayingLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'NowPlayingState.loading()';
}


}




/// @nodoc


class NowPlayingData implements NowPlayingState {
  const NowPlayingData({required this.zone, required this.status, required this.track});
  

 final  Zone zone;
 final  PlayerStatus? status;
 final  Track? track;

/// Create a copy of NowPlayingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NowPlayingDataCopyWith<NowPlayingData> get copyWith => _$NowPlayingDataCopyWithImpl<NowPlayingData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NowPlayingData&&(identical(other.zone, zone) || other.zone == zone)&&(identical(other.status, status) || other.status == status)&&(identical(other.track, track) || other.track == track));
}


@override
int get hashCode => Object.hash(runtimeType,zone,status,track);

@override
String toString() {
  return 'NowPlayingState.data(zone: $zone, status: $status, track: $track)';
}


}

/// @nodoc
abstract mixin class $NowPlayingDataCopyWith<$Res> implements $NowPlayingStateCopyWith<$Res> {
  factory $NowPlayingDataCopyWith(NowPlayingData value, $Res Function(NowPlayingData) _then) = _$NowPlayingDataCopyWithImpl;
@useResult
$Res call({
 Zone zone, PlayerStatus? status, Track? track
});


$ZoneCopyWith<$Res> get zone;$PlayerStatusCopyWith<$Res>? get status;$TrackCopyWith<$Res>? get track;

}
/// @nodoc
class _$NowPlayingDataCopyWithImpl<$Res>
    implements $NowPlayingDataCopyWith<$Res> {
  _$NowPlayingDataCopyWithImpl(this._self, this._then);

  final NowPlayingData _self;
  final $Res Function(NowPlayingData) _then;

/// Create a copy of NowPlayingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? zone = null,Object? status = freezed,Object? track = freezed,}) {
  return _then(NowPlayingData(
zone: null == zone ? _self.zone : zone // ignore: cast_nullable_to_non_nullable
as Zone,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PlayerStatus?,track: freezed == track ? _self.track : track // ignore: cast_nullable_to_non_nullable
as Track?,
  ));
}

/// Create a copy of NowPlayingState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ZoneCopyWith<$Res> get zone {
  
  return $ZoneCopyWith<$Res>(_self.zone, (value) {
    return _then(_self.copyWith(zone: value));
  });
}/// Create a copy of NowPlayingState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlayerStatusCopyWith<$Res>? get status {
    if (_self.status == null) {
    return null;
  }

  return $PlayerStatusCopyWith<$Res>(_self.status!, (value) {
    return _then(_self.copyWith(status: value));
  });
}/// Create a copy of NowPlayingState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TrackCopyWith<$Res>? get track {
    if (_self.track == null) {
    return null;
  }

  return $TrackCopyWith<$Res>(_self.track!, (value) {
    return _then(_self.copyWith(track: value));
  });
}
}

// dart format on
