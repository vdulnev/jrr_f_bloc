// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'artwork_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ArtworkState {

 String? get serverAddress; String? get token;
/// Create a copy of ArtworkState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ArtworkStateCopyWith<ArtworkState> get copyWith => _$ArtworkStateCopyWithImpl<ArtworkState>(this as ArtworkState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ArtworkState&&(identical(other.serverAddress, serverAddress) || other.serverAddress == serverAddress)&&(identical(other.token, token) || other.token == token));
}


@override
int get hashCode => Object.hash(runtimeType,serverAddress,token);

@override
String toString() {
  return 'ArtworkState(serverAddress: $serverAddress, token: $token)';
}


}

/// @nodoc
abstract mixin class $ArtworkStateCopyWith<$Res>  {
  factory $ArtworkStateCopyWith(ArtworkState value, $Res Function(ArtworkState) _then) = _$ArtworkStateCopyWithImpl;
@useResult
$Res call({
 String? serverAddress, String? token
});




}
/// @nodoc
class _$ArtworkStateCopyWithImpl<$Res>
    implements $ArtworkStateCopyWith<$Res> {
  _$ArtworkStateCopyWithImpl(this._self, this._then);

  final ArtworkState _self;
  final $Res Function(ArtworkState) _then;

/// Create a copy of ArtworkState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? serverAddress = freezed,Object? token = freezed,}) {
  return _then(_self.copyWith(
serverAddress: freezed == serverAddress ? _self.serverAddress : serverAddress // ignore: cast_nullable_to_non_nullable
as String?,token: freezed == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ArtworkState].
extension ArtworkStatePatterns on ArtworkState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ArtworkState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ArtworkState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ArtworkState value)  $default,){
final _that = this;
switch (_that) {
case _ArtworkState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ArtworkState value)?  $default,){
final _that = this;
switch (_that) {
case _ArtworkState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? serverAddress,  String? token)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ArtworkState() when $default != null:
return $default(_that.serverAddress,_that.token);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? serverAddress,  String? token)  $default,) {final _that = this;
switch (_that) {
case _ArtworkState():
return $default(_that.serverAddress,_that.token);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? serverAddress,  String? token)?  $default,) {final _that = this;
switch (_that) {
case _ArtworkState() when $default != null:
return $default(_that.serverAddress,_that.token);case _:
  return null;

}
}

}

/// @nodoc


class _ArtworkState extends ArtworkState {
  const _ArtworkState({required this.serverAddress, required this.token}): super._();
  

@override final  String? serverAddress;
@override final  String? token;

/// Create a copy of ArtworkState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ArtworkStateCopyWith<_ArtworkState> get copyWith => __$ArtworkStateCopyWithImpl<_ArtworkState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ArtworkState&&(identical(other.serverAddress, serverAddress) || other.serverAddress == serverAddress)&&(identical(other.token, token) || other.token == token));
}


@override
int get hashCode => Object.hash(runtimeType,serverAddress,token);

@override
String toString() {
  return 'ArtworkState(serverAddress: $serverAddress, token: $token)';
}


}

/// @nodoc
abstract mixin class _$ArtworkStateCopyWith<$Res> implements $ArtworkStateCopyWith<$Res> {
  factory _$ArtworkStateCopyWith(_ArtworkState value, $Res Function(_ArtworkState) _then) = __$ArtworkStateCopyWithImpl;
@override @useResult
$Res call({
 String? serverAddress, String? token
});




}
/// @nodoc
class __$ArtworkStateCopyWithImpl<$Res>
    implements _$ArtworkStateCopyWith<$Res> {
  __$ArtworkStateCopyWithImpl(this._self, this._then);

  final _ArtworkState _self;
  final $Res Function(_ArtworkState) _then;

/// Create a copy of ArtworkState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? serverAddress = freezed,Object? token = freezed,}) {
  return _then(_ArtworkState(
serverAddress: freezed == serverAddress ? _self.serverAddress : serverAddress // ignore: cast_nullable_to_non_nullable
as String?,token: freezed == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
