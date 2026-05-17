// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'player_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PlayerSnapshot {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlayerSnapshot);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PlayerSnapshot()';
}


}

/// @nodoc
class $PlayerSnapshotCopyWith<$Res>  {
$PlayerSnapshotCopyWith(PlayerSnapshot _, $Res Function(PlayerSnapshot) __);
}


/// Adds pattern-matching-related methods to [PlayerSnapshot].
extension PlayerSnapshotPatterns on PlayerSnapshot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( PlayerLoading value)?  loading,TResult Function( PlayerData value)?  data,TResult Function( PlayerError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case PlayerLoading() when loading != null:
return loading(_that);case PlayerData() when data != null:
return data(_that);case PlayerError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( PlayerLoading value)  loading,required TResult Function( PlayerData value)  data,required TResult Function( PlayerError value)  error,}){
final _that = this;
switch (_that) {
case PlayerLoading():
return loading(_that);case PlayerData():
return data(_that);case PlayerError():
return error(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( PlayerLoading value)?  loading,TResult? Function( PlayerData value)?  data,TResult? Function( PlayerError value)?  error,}){
final _that = this;
switch (_that) {
case PlayerLoading() when loading != null:
return loading(_that);case PlayerData() when data != null:
return data(_that);case PlayerError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  loading,TResult Function( PlayerStatus? status)?  data,TResult Function( AppException error)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case PlayerLoading() when loading != null:
return loading();case PlayerData() when data != null:
return data(_that.status);case PlayerError() when error != null:
return error(_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  loading,required TResult Function( PlayerStatus? status)  data,required TResult Function( AppException error)  error,}) {final _that = this;
switch (_that) {
case PlayerLoading():
return loading();case PlayerData():
return data(_that.status);case PlayerError():
return error(_that.error);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  loading,TResult? Function( PlayerStatus? status)?  data,TResult? Function( AppException error)?  error,}) {final _that = this;
switch (_that) {
case PlayerLoading() when loading != null:
return loading();case PlayerData() when data != null:
return data(_that.status);case PlayerError() when error != null:
return error(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class PlayerLoading implements PlayerSnapshot {
  const PlayerLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlayerLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PlayerSnapshot.loading()';
}


}




/// @nodoc


class PlayerData implements PlayerSnapshot {
  const PlayerData({required this.status});
  

 final  PlayerStatus? status;

/// Create a copy of PlayerSnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlayerDataCopyWith<PlayerData> get copyWith => _$PlayerDataCopyWithImpl<PlayerData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlayerData&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,status);

@override
String toString() {
  return 'PlayerSnapshot.data(status: $status)';
}


}

/// @nodoc
abstract mixin class $PlayerDataCopyWith<$Res> implements $PlayerSnapshotCopyWith<$Res> {
  factory $PlayerDataCopyWith(PlayerData value, $Res Function(PlayerData) _then) = _$PlayerDataCopyWithImpl;
@useResult
$Res call({
 PlayerStatus? status
});


$PlayerStatusCopyWith<$Res>? get status;

}
/// @nodoc
class _$PlayerDataCopyWithImpl<$Res>
    implements $PlayerDataCopyWith<$Res> {
  _$PlayerDataCopyWithImpl(this._self, this._then);

  final PlayerData _self;
  final $Res Function(PlayerData) _then;

/// Create a copy of PlayerSnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? status = freezed,}) {
  return _then(PlayerData(
status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PlayerStatus?,
  ));
}

/// Create a copy of PlayerSnapshot
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
}
}

/// @nodoc


class PlayerError implements PlayerSnapshot {
  const PlayerError({required this.error});
  

 final  AppException error;

/// Create a copy of PlayerSnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlayerErrorCopyWith<PlayerError> get copyWith => _$PlayerErrorCopyWithImpl<PlayerError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlayerError&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'PlayerSnapshot.error(error: $error)';
}


}

/// @nodoc
abstract mixin class $PlayerErrorCopyWith<$Res> implements $PlayerSnapshotCopyWith<$Res> {
  factory $PlayerErrorCopyWith(PlayerError value, $Res Function(PlayerError) _then) = _$PlayerErrorCopyWithImpl;
@useResult
$Res call({
 AppException error
});


$AppExceptionCopyWith<$Res> get error;

}
/// @nodoc
class _$PlayerErrorCopyWithImpl<$Res>
    implements $PlayerErrorCopyWith<$Res> {
  _$PlayerErrorCopyWithImpl(this._self, this._then);

  final PlayerError _self;
  final $Res Function(PlayerError) _then;

/// Create a copy of PlayerSnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(PlayerError(
error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as AppException,
  ));
}

/// Create a copy of PlayerSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppExceptionCopyWith<$Res> get error {
  
  return $AppExceptionCopyWith<$Res>(_self.error, (value) {
    return _then(_self.copyWith(error: value));
  });
}
}

// dart format on
