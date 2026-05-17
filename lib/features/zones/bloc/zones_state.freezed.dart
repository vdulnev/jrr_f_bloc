// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'zones_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ZonesState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ZonesState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ZonesState()';
}


}

/// @nodoc
class $ZonesStateCopyWith<$Res>  {
$ZonesStateCopyWith(ZonesState _, $Res Function(ZonesState) __);
}


/// Adds pattern-matching-related methods to [ZonesState].
extension ZonesStatePatterns on ZonesState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ZonesLoading value)?  loading,TResult Function( ZonesLoaded value)?  loaded,TResult Function( ZonesError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ZonesLoading() when loading != null:
return loading(_that);case ZonesLoaded() when loaded != null:
return loaded(_that);case ZonesError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ZonesLoading value)  loading,required TResult Function( ZonesLoaded value)  loaded,required TResult Function( ZonesError value)  error,}){
final _that = this;
switch (_that) {
case ZonesLoading():
return loading(_that);case ZonesLoaded():
return loaded(_that);case ZonesError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ZonesLoading value)?  loading,TResult? Function( ZonesLoaded value)?  loaded,TResult? Function( ZonesError value)?  error,}){
final _that = this;
switch (_that) {
case ZonesLoading() when loading != null:
return loading(_that);case ZonesLoaded() when loaded != null:
return loaded(_that);case ZonesError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  loading,TResult Function( List<Zone> zones)?  loaded,TResult Function( AppException error)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ZonesLoading() when loading != null:
return loading();case ZonesLoaded() when loaded != null:
return loaded(_that.zones);case ZonesError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  loading,required TResult Function( List<Zone> zones)  loaded,required TResult Function( AppException error)  error,}) {final _that = this;
switch (_that) {
case ZonesLoading():
return loading();case ZonesLoaded():
return loaded(_that.zones);case ZonesError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  loading,TResult? Function( List<Zone> zones)?  loaded,TResult? Function( AppException error)?  error,}) {final _that = this;
switch (_that) {
case ZonesLoading() when loading != null:
return loading();case ZonesLoaded() when loaded != null:
return loaded(_that.zones);case ZonesError() when error != null:
return error(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class ZonesLoading implements ZonesState {
  const ZonesLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ZonesLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ZonesState.loading()';
}


}




/// @nodoc


class ZonesLoaded implements ZonesState {
  const ZonesLoaded({required final  List<Zone> zones}): _zones = zones;
  

 final  List<Zone> _zones;
 List<Zone> get zones {
  if (_zones is EqualUnmodifiableListView) return _zones;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_zones);
}


/// Create a copy of ZonesState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ZonesLoadedCopyWith<ZonesLoaded> get copyWith => _$ZonesLoadedCopyWithImpl<ZonesLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ZonesLoaded&&const DeepCollectionEquality().equals(other._zones, _zones));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_zones));

@override
String toString() {
  return 'ZonesState.loaded(zones: $zones)';
}


}

/// @nodoc
abstract mixin class $ZonesLoadedCopyWith<$Res> implements $ZonesStateCopyWith<$Res> {
  factory $ZonesLoadedCopyWith(ZonesLoaded value, $Res Function(ZonesLoaded) _then) = _$ZonesLoadedCopyWithImpl;
@useResult
$Res call({
 List<Zone> zones
});




}
/// @nodoc
class _$ZonesLoadedCopyWithImpl<$Res>
    implements $ZonesLoadedCopyWith<$Res> {
  _$ZonesLoadedCopyWithImpl(this._self, this._then);

  final ZonesLoaded _self;
  final $Res Function(ZonesLoaded) _then;

/// Create a copy of ZonesState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? zones = null,}) {
  return _then(ZonesLoaded(
zones: null == zones ? _self._zones : zones // ignore: cast_nullable_to_non_nullable
as List<Zone>,
  ));
}


}

/// @nodoc


class ZonesError implements ZonesState {
  const ZonesError({required this.error});
  

 final  AppException error;

/// Create a copy of ZonesState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ZonesErrorCopyWith<ZonesError> get copyWith => _$ZonesErrorCopyWithImpl<ZonesError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ZonesError&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'ZonesState.error(error: $error)';
}


}

/// @nodoc
abstract mixin class $ZonesErrorCopyWith<$Res> implements $ZonesStateCopyWith<$Res> {
  factory $ZonesErrorCopyWith(ZonesError value, $Res Function(ZonesError) _then) = _$ZonesErrorCopyWithImpl;
@useResult
$Res call({
 AppException error
});


$AppExceptionCopyWith<$Res> get error;

}
/// @nodoc
class _$ZonesErrorCopyWithImpl<$Res>
    implements $ZonesErrorCopyWith<$Res> {
  _$ZonesErrorCopyWithImpl(this._self, this._then);

  final ZonesError _self;
  final $Res Function(ZonesError) _then;

/// Create a copy of ZonesState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(ZonesError(
error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as AppException,
  ));
}

/// Create a copy of ZonesState
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
