// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'downloaded_albums_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DownloadedAlbumsState {

 List<Album> get albums;
/// Create a copy of DownloadedAlbumsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DownloadedAlbumsStateCopyWith<DownloadedAlbumsState> get copyWith => _$DownloadedAlbumsStateCopyWithImpl<DownloadedAlbumsState>(this as DownloadedAlbumsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DownloadedAlbumsState&&const DeepCollectionEquality().equals(other.albums, albums));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(albums));

@override
String toString() {
  return 'DownloadedAlbumsState(albums: $albums)';
}


}

/// @nodoc
abstract mixin class $DownloadedAlbumsStateCopyWith<$Res>  {
  factory $DownloadedAlbumsStateCopyWith(DownloadedAlbumsState value, $Res Function(DownloadedAlbumsState) _then) = _$DownloadedAlbumsStateCopyWithImpl;
@useResult
$Res call({
 List<Album> albums
});




}
/// @nodoc
class _$DownloadedAlbumsStateCopyWithImpl<$Res>
    implements $DownloadedAlbumsStateCopyWith<$Res> {
  _$DownloadedAlbumsStateCopyWithImpl(this._self, this._then);

  final DownloadedAlbumsState _self;
  final $Res Function(DownloadedAlbumsState) _then;

/// Create a copy of DownloadedAlbumsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? albums = null,}) {
  return _then(_self.copyWith(
albums: null == albums ? _self.albums : albums // ignore: cast_nullable_to_non_nullable
as List<Album>,
  ));
}

}


/// Adds pattern-matching-related methods to [DownloadedAlbumsState].
extension DownloadedAlbumsStatePatterns on DownloadedAlbumsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DownloadedAlbumsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DownloadedAlbumsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DownloadedAlbumsState value)  $default,){
final _that = this;
switch (_that) {
case _DownloadedAlbumsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DownloadedAlbumsState value)?  $default,){
final _that = this;
switch (_that) {
case _DownloadedAlbumsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Album> albums)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DownloadedAlbumsState() when $default != null:
return $default(_that.albums);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Album> albums)  $default,) {final _that = this;
switch (_that) {
case _DownloadedAlbumsState():
return $default(_that.albums);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Album> albums)?  $default,) {final _that = this;
switch (_that) {
case _DownloadedAlbumsState() when $default != null:
return $default(_that.albums);case _:
  return null;

}
}

}

/// @nodoc


class _DownloadedAlbumsState implements DownloadedAlbumsState {
  const _DownloadedAlbumsState({final  List<Album> albums = const <Album>[]}): _albums = albums;
  

 final  List<Album> _albums;
@override@JsonKey() List<Album> get albums {
  if (_albums is EqualUnmodifiableListView) return _albums;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_albums);
}


/// Create a copy of DownloadedAlbumsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DownloadedAlbumsStateCopyWith<_DownloadedAlbumsState> get copyWith => __$DownloadedAlbumsStateCopyWithImpl<_DownloadedAlbumsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DownloadedAlbumsState&&const DeepCollectionEquality().equals(other._albums, _albums));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_albums));

@override
String toString() {
  return 'DownloadedAlbumsState(albums: $albums)';
}


}

/// @nodoc
abstract mixin class _$DownloadedAlbumsStateCopyWith<$Res> implements $DownloadedAlbumsStateCopyWith<$Res> {
  factory _$DownloadedAlbumsStateCopyWith(_DownloadedAlbumsState value, $Res Function(_DownloadedAlbumsState) _then) = __$DownloadedAlbumsStateCopyWithImpl;
@override @useResult
$Res call({
 List<Album> albums
});




}
/// @nodoc
class __$DownloadedAlbumsStateCopyWithImpl<$Res>
    implements _$DownloadedAlbumsStateCopyWith<$Res> {
  __$DownloadedAlbumsStateCopyWithImpl(this._self, this._then);

  final _DownloadedAlbumsState _self;
  final $Res Function(_DownloadedAlbumsState) _then;

/// Create a copy of DownloadedAlbumsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? albums = null,}) {
  return _then(_DownloadedAlbumsState(
albums: null == albums ? _self._albums : albums // ignore: cast_nullable_to_non_nullable
as List<Album>,
  ));
}


}

// dart format on
