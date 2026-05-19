// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'downloaded_artists_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DownloadedArtistsState {

 List<ArtistGroup> get groups;
/// Create a copy of DownloadedArtistsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DownloadedArtistsStateCopyWith<DownloadedArtistsState> get copyWith => _$DownloadedArtistsStateCopyWithImpl<DownloadedArtistsState>(this as DownloadedArtistsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DownloadedArtistsState&&const DeepCollectionEquality().equals(other.groups, groups));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(groups));

@override
String toString() {
  return 'DownloadedArtistsState(groups: $groups)';
}


}

/// @nodoc
abstract mixin class $DownloadedArtistsStateCopyWith<$Res>  {
  factory $DownloadedArtistsStateCopyWith(DownloadedArtistsState value, $Res Function(DownloadedArtistsState) _then) = _$DownloadedArtistsStateCopyWithImpl;
@useResult
$Res call({
 List<ArtistGroup> groups
});




}
/// @nodoc
class _$DownloadedArtistsStateCopyWithImpl<$Res>
    implements $DownloadedArtistsStateCopyWith<$Res> {
  _$DownloadedArtistsStateCopyWithImpl(this._self, this._then);

  final DownloadedArtistsState _self;
  final $Res Function(DownloadedArtistsState) _then;

/// Create a copy of DownloadedArtistsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? groups = null,}) {
  return _then(_self.copyWith(
groups: null == groups ? _self.groups : groups // ignore: cast_nullable_to_non_nullable
as List<ArtistGroup>,
  ));
}

}


/// Adds pattern-matching-related methods to [DownloadedArtistsState].
extension DownloadedArtistsStatePatterns on DownloadedArtistsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DownloadedArtistsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DownloadedArtistsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DownloadedArtistsState value)  $default,){
final _that = this;
switch (_that) {
case _DownloadedArtistsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DownloadedArtistsState value)?  $default,){
final _that = this;
switch (_that) {
case _DownloadedArtistsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<ArtistGroup> groups)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DownloadedArtistsState() when $default != null:
return $default(_that.groups);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<ArtistGroup> groups)  $default,) {final _that = this;
switch (_that) {
case _DownloadedArtistsState():
return $default(_that.groups);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<ArtistGroup> groups)?  $default,) {final _that = this;
switch (_that) {
case _DownloadedArtistsState() when $default != null:
return $default(_that.groups);case _:
  return null;

}
}

}

/// @nodoc


class _DownloadedArtistsState implements DownloadedArtistsState {
  const _DownloadedArtistsState({final  List<ArtistGroup> groups = const <ArtistGroup>[]}): _groups = groups;
  

 final  List<ArtistGroup> _groups;
@override@JsonKey() List<ArtistGroup> get groups {
  if (_groups is EqualUnmodifiableListView) return _groups;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_groups);
}


/// Create a copy of DownloadedArtistsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DownloadedArtistsStateCopyWith<_DownloadedArtistsState> get copyWith => __$DownloadedArtistsStateCopyWithImpl<_DownloadedArtistsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DownloadedArtistsState&&const DeepCollectionEquality().equals(other._groups, _groups));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_groups));

@override
String toString() {
  return 'DownloadedArtistsState(groups: $groups)';
}


}

/// @nodoc
abstract mixin class _$DownloadedArtistsStateCopyWith<$Res> implements $DownloadedArtistsStateCopyWith<$Res> {
  factory _$DownloadedArtistsStateCopyWith(_DownloadedArtistsState value, $Res Function(_DownloadedArtistsState) _then) = __$DownloadedArtistsStateCopyWithImpl;
@override @useResult
$Res call({
 List<ArtistGroup> groups
});




}
/// @nodoc
class __$DownloadedArtistsStateCopyWithImpl<$Res>
    implements _$DownloadedArtistsStateCopyWith<$Res> {
  __$DownloadedArtistsStateCopyWithImpl(this._self, this._then);

  final _DownloadedArtistsState _self;
  final $Res Function(_DownloadedArtistsState) _then;

/// Create a copy of DownloadedArtistsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? groups = null,}) {
  return _then(_DownloadedArtistsState(
groups: null == groups ? _self._groups : groups // ignore: cast_nullable_to_non_nullable
as List<ArtistGroup>,
  ));
}


}

// dart format on
