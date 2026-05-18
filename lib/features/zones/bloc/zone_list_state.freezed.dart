// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'zone_list_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ZoneListState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ZoneListState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ZoneListState()';
}


}

/// @nodoc
class $ZoneListStateCopyWith<$Res>  {
$ZoneListStateCopyWith(ZoneListState _, $Res Function(ZoneListState) __);
}


/// Adds pattern-matching-related methods to [ZoneListState].
extension ZoneListStatePatterns on ZoneListState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ZoneListLoading value)?  loading,TResult Function( ZoneListLoaded value)?  loaded,TResult Function( ZoneListError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ZoneListLoading() when loading != null:
return loading(_that);case ZoneListLoaded() when loaded != null:
return loaded(_that);case ZoneListError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ZoneListLoading value)  loading,required TResult Function( ZoneListLoaded value)  loaded,required TResult Function( ZoneListError value)  error,}){
final _that = this;
switch (_that) {
case ZoneListLoading():
return loading(_that);case ZoneListLoaded():
return loaded(_that);case ZoneListError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ZoneListLoading value)?  loading,TResult? Function( ZoneListLoaded value)?  loaded,TResult? Function( ZoneListError value)?  error,}){
final _that = this;
switch (_that) {
case ZoneListLoading() when loading != null:
return loading(_that);case ZoneListLoaded() when loaded != null:
return loaded(_that);case ZoneListError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  loading,TResult Function( List<Zone> zones,  Zone? activeZone)?  loaded,TResult Function( AppException error)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ZoneListLoading() when loading != null:
return loading();case ZoneListLoaded() when loaded != null:
return loaded(_that.zones,_that.activeZone);case ZoneListError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  loading,required TResult Function( List<Zone> zones,  Zone? activeZone)  loaded,required TResult Function( AppException error)  error,}) {final _that = this;
switch (_that) {
case ZoneListLoading():
return loading();case ZoneListLoaded():
return loaded(_that.zones,_that.activeZone);case ZoneListError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  loading,TResult? Function( List<Zone> zones,  Zone? activeZone)?  loaded,TResult? Function( AppException error)?  error,}) {final _that = this;
switch (_that) {
case ZoneListLoading() when loading != null:
return loading();case ZoneListLoaded() when loaded != null:
return loaded(_that.zones,_that.activeZone);case ZoneListError() when error != null:
return error(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class ZoneListLoading implements ZoneListState {
  const ZoneListLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ZoneListLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ZoneListState.loading()';
}


}




/// @nodoc


class ZoneListLoaded implements ZoneListState {
  const ZoneListLoaded({required final  List<Zone> zones, required this.activeZone}): _zones = zones;
  

 final  List<Zone> _zones;
 List<Zone> get zones {
  if (_zones is EqualUnmodifiableListView) return _zones;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_zones);
}

 final  Zone? activeZone;

/// Create a copy of ZoneListState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ZoneListLoadedCopyWith<ZoneListLoaded> get copyWith => _$ZoneListLoadedCopyWithImpl<ZoneListLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ZoneListLoaded&&const DeepCollectionEquality().equals(other._zones, _zones)&&(identical(other.activeZone, activeZone) || other.activeZone == activeZone));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_zones),activeZone);

@override
String toString() {
  return 'ZoneListState.loaded(zones: $zones, activeZone: $activeZone)';
}


}

/// @nodoc
abstract mixin class $ZoneListLoadedCopyWith<$Res> implements $ZoneListStateCopyWith<$Res> {
  factory $ZoneListLoadedCopyWith(ZoneListLoaded value, $Res Function(ZoneListLoaded) _then) = _$ZoneListLoadedCopyWithImpl;
@useResult
$Res call({
 List<Zone> zones, Zone? activeZone
});


$ZoneCopyWith<$Res>? get activeZone;

}
/// @nodoc
class _$ZoneListLoadedCopyWithImpl<$Res>
    implements $ZoneListLoadedCopyWith<$Res> {
  _$ZoneListLoadedCopyWithImpl(this._self, this._then);

  final ZoneListLoaded _self;
  final $Res Function(ZoneListLoaded) _then;

/// Create a copy of ZoneListState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? zones = null,Object? activeZone = freezed,}) {
  return _then(ZoneListLoaded(
zones: null == zones ? _self._zones : zones // ignore: cast_nullable_to_non_nullable
as List<Zone>,activeZone: freezed == activeZone ? _self.activeZone : activeZone // ignore: cast_nullable_to_non_nullable
as Zone?,
  ));
}

/// Create a copy of ZoneListState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ZoneCopyWith<$Res>? get activeZone {
    if (_self.activeZone == null) {
    return null;
  }

  return $ZoneCopyWith<$Res>(_self.activeZone!, (value) {
    return _then(_self.copyWith(activeZone: value));
  });
}
}

/// @nodoc


class ZoneListError implements ZoneListState {
  const ZoneListError({required this.error});
  

 final  AppException error;

/// Create a copy of ZoneListState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ZoneListErrorCopyWith<ZoneListError> get copyWith => _$ZoneListErrorCopyWithImpl<ZoneListError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ZoneListError&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'ZoneListState.error(error: $error)';
}


}

/// @nodoc
abstract mixin class $ZoneListErrorCopyWith<$Res> implements $ZoneListStateCopyWith<$Res> {
  factory $ZoneListErrorCopyWith(ZoneListError value, $Res Function(ZoneListError) _then) = _$ZoneListErrorCopyWithImpl;
@useResult
$Res call({
 AppException error
});


$AppExceptionCopyWith<$Res> get error;

}
/// @nodoc
class _$ZoneListErrorCopyWithImpl<$Res>
    implements $ZoneListErrorCopyWith<$Res> {
  _$ZoneListErrorCopyWithImpl(this._self, this._then);

  final ZoneListError _self;
  final $Res Function(ZoneListError) _then;

/// Create a copy of ZoneListState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(ZoneListError(
error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as AppException,
  ));
}

/// Create a copy of ZoneListState
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
