// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'server_setup_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ServerSetupState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServerSetupState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ServerSetupState()';
}


}

/// @nodoc
class $ServerSetupStateCopyWith<$Res>  {
$ServerSetupStateCopyWith(ServerSetupState _, $Res Function(ServerSetupState) __);
}


/// Adds pattern-matching-related methods to [ServerSetupState].
extension ServerSetupStatePatterns on ServerSetupState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ServerSetupIdle value)?  idle,TResult Function( ServerSetupConnecting value)?  connecting,TResult Function( ServerSetupFailed value)?  failed,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ServerSetupIdle() when idle != null:
return idle(_that);case ServerSetupConnecting() when connecting != null:
return connecting(_that);case ServerSetupFailed() when failed != null:
return failed(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ServerSetupIdle value)  idle,required TResult Function( ServerSetupConnecting value)  connecting,required TResult Function( ServerSetupFailed value)  failed,}){
final _that = this;
switch (_that) {
case ServerSetupIdle():
return idle(_that);case ServerSetupConnecting():
return connecting(_that);case ServerSetupFailed():
return failed(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ServerSetupIdle value)?  idle,TResult? Function( ServerSetupConnecting value)?  connecting,TResult? Function( ServerSetupFailed value)?  failed,}){
final _that = this;
switch (_that) {
case ServerSetupIdle() when idle != null:
return idle(_that);case ServerSetupConnecting() when connecting != null:
return connecting(_that);case ServerSetupFailed() when failed != null:
return failed(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  idle,TResult Function()?  connecting,TResult Function( AppException error)?  failed,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ServerSetupIdle() when idle != null:
return idle();case ServerSetupConnecting() when connecting != null:
return connecting();case ServerSetupFailed() when failed != null:
return failed(_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  idle,required TResult Function()  connecting,required TResult Function( AppException error)  failed,}) {final _that = this;
switch (_that) {
case ServerSetupIdle():
return idle();case ServerSetupConnecting():
return connecting();case ServerSetupFailed():
return failed(_that.error);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  idle,TResult? Function()?  connecting,TResult? Function( AppException error)?  failed,}) {final _that = this;
switch (_that) {
case ServerSetupIdle() when idle != null:
return idle();case ServerSetupConnecting() when connecting != null:
return connecting();case ServerSetupFailed() when failed != null:
return failed(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class ServerSetupIdle implements ServerSetupState {
  const ServerSetupIdle();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServerSetupIdle);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ServerSetupState.idle()';
}


}




/// @nodoc


class ServerSetupConnecting implements ServerSetupState {
  const ServerSetupConnecting();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServerSetupConnecting);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ServerSetupState.connecting()';
}


}




/// @nodoc


class ServerSetupFailed implements ServerSetupState {
  const ServerSetupFailed({required this.error});
  

 final  AppException error;

/// Create a copy of ServerSetupState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServerSetupFailedCopyWith<ServerSetupFailed> get copyWith => _$ServerSetupFailedCopyWithImpl<ServerSetupFailed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServerSetupFailed&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'ServerSetupState.failed(error: $error)';
}


}

/// @nodoc
abstract mixin class $ServerSetupFailedCopyWith<$Res> implements $ServerSetupStateCopyWith<$Res> {
  factory $ServerSetupFailedCopyWith(ServerSetupFailed value, $Res Function(ServerSetupFailed) _then) = _$ServerSetupFailedCopyWithImpl;
@useResult
$Res call({
 AppException error
});


$AppExceptionCopyWith<$Res> get error;

}
/// @nodoc
class _$ServerSetupFailedCopyWithImpl<$Res>
    implements $ServerSetupFailedCopyWith<$Res> {
  _$ServerSetupFailedCopyWithImpl(this._self, this._then);

  final ServerSetupFailed _self;
  final $Res Function(ServerSetupFailed) _then;

/// Create a copy of ServerSetupState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(ServerSetupFailed(
error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as AppException,
  ));
}

/// Create a copy of ServerSetupState
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
