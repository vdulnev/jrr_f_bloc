// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'server_manager_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ServerManagerState {

 ServerInfo? get serverInfo;
/// Create a copy of ServerManagerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServerManagerStateCopyWith<ServerManagerState> get copyWith => _$ServerManagerStateCopyWithImpl<ServerManagerState>(this as ServerManagerState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServerManagerState&&(identical(other.serverInfo, serverInfo) || other.serverInfo == serverInfo));
}


@override
int get hashCode => Object.hash(runtimeType,serverInfo);

@override
String toString() {
  return 'ServerManagerState(serverInfo: $serverInfo)';
}


}

/// @nodoc
abstract mixin class $ServerManagerStateCopyWith<$Res>  {
  factory $ServerManagerStateCopyWith(ServerManagerState value, $Res Function(ServerManagerState) _then) = _$ServerManagerStateCopyWithImpl;
@useResult
$Res call({
 ServerInfo? serverInfo
});


$ServerInfoCopyWith<$Res>? get serverInfo;

}
/// @nodoc
class _$ServerManagerStateCopyWithImpl<$Res>
    implements $ServerManagerStateCopyWith<$Res> {
  _$ServerManagerStateCopyWithImpl(this._self, this._then);

  final ServerManagerState _self;
  final $Res Function(ServerManagerState) _then;

/// Create a copy of ServerManagerState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? serverInfo = freezed,}) {
  return _then(_self.copyWith(
serverInfo: freezed == serverInfo ? _self.serverInfo : serverInfo // ignore: cast_nullable_to_non_nullable
as ServerInfo?,
  ));
}
/// Create a copy of ServerManagerState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ServerInfoCopyWith<$Res>? get serverInfo {
    if (_self.serverInfo == null) {
    return null;
  }

  return $ServerInfoCopyWith<$Res>(_self.serverInfo!, (value) {
    return _then(_self.copyWith(serverInfo: value));
  });
}
}


/// Adds pattern-matching-related methods to [ServerManagerState].
extension ServerManagerStatePatterns on ServerManagerState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ServerManagerState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ServerManagerState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ServerManagerState value)  $default,){
final _that = this;
switch (_that) {
case _ServerManagerState():
return $default(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ServerManagerState value)?  $default,){
final _that = this;
switch (_that) {
case _ServerManagerState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ServerInfo? serverInfo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ServerManagerState() when $default != null:
return $default(_that.serverInfo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ServerInfo? serverInfo)  $default,) {final _that = this;
switch (_that) {
case _ServerManagerState():
return $default(_that.serverInfo);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ServerInfo? serverInfo)?  $default,) {final _that = this;
switch (_that) {
case _ServerManagerState() when $default != null:
return $default(_that.serverInfo);case _:
  return null;

}
}

}

/// @nodoc


class _ServerManagerState implements ServerManagerState {
  const _ServerManagerState({required this.serverInfo});
  

@override final  ServerInfo? serverInfo;

/// Create a copy of ServerManagerState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ServerManagerStateCopyWith<_ServerManagerState> get copyWith => __$ServerManagerStateCopyWithImpl<_ServerManagerState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ServerManagerState&&(identical(other.serverInfo, serverInfo) || other.serverInfo == serverInfo));
}


@override
int get hashCode => Object.hash(runtimeType,serverInfo);

@override
String toString() {
  return 'ServerManagerState(serverInfo: $serverInfo)';
}


}

/// @nodoc
abstract mixin class _$ServerManagerStateCopyWith<$Res> implements $ServerManagerStateCopyWith<$Res> {
  factory _$ServerManagerStateCopyWith(_ServerManagerState value, $Res Function(_ServerManagerState) _then) = __$ServerManagerStateCopyWithImpl;
@override @useResult
$Res call({
 ServerInfo? serverInfo
});


@override $ServerInfoCopyWith<$Res>? get serverInfo;

}
/// @nodoc
class __$ServerManagerStateCopyWithImpl<$Res>
    implements _$ServerManagerStateCopyWith<$Res> {
  __$ServerManagerStateCopyWithImpl(this._self, this._then);

  final _ServerManagerState _self;
  final $Res Function(_ServerManagerState) _then;

/// Create a copy of ServerManagerState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? serverInfo = freezed,}) {
  return _then(_ServerManagerState(
serverInfo: freezed == serverInfo ? _self.serverInfo : serverInfo // ignore: cast_nullable_to_non_nullable
as ServerInfo?,
  ));
}

/// Create a copy of ServerManagerState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ServerInfoCopyWith<$Res>? get serverInfo {
    if (_self.serverInfo == null) {
    return null;
  }

  return $ServerInfoCopyWith<$Res>(_self.serverInfo!, (value) {
    return _then(_self.copyWith(serverInfo: value));
  });
}
}

// dart format on
