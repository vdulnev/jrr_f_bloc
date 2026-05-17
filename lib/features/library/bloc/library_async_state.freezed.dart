// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'library_async_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LibAsync<T> {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LibAsync<T>);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'LibAsync<$T>()';
}


}

/// @nodoc
class $LibAsyncCopyWith<T,$Res>  {
$LibAsyncCopyWith(LibAsync<T> _, $Res Function(LibAsync<T>) __);
}


/// Adds pattern-matching-related methods to [LibAsync].
extension LibAsyncPatterns<T> on LibAsync<T> {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( LibLoading<T> value)?  loading,TResult Function( LibData<T> value)?  data,TResult Function( LibError<T> value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case LibLoading() when loading != null:
return loading(_that);case LibData() when data != null:
return data(_that);case LibError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( LibLoading<T> value)  loading,required TResult Function( LibData<T> value)  data,required TResult Function( LibError<T> value)  error,}){
final _that = this;
switch (_that) {
case LibLoading():
return loading(_that);case LibData():
return data(_that);case LibError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( LibLoading<T> value)?  loading,TResult? Function( LibData<T> value)?  data,TResult? Function( LibError<T> value)?  error,}){
final _that = this;
switch (_that) {
case LibLoading() when loading != null:
return loading(_that);case LibData() when data != null:
return data(_that);case LibError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  loading,TResult Function( T value)?  data,TResult Function( AppException error)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case LibLoading() when loading != null:
return loading();case LibData() when data != null:
return data(_that.value);case LibError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  loading,required TResult Function( T value)  data,required TResult Function( AppException error)  error,}) {final _that = this;
switch (_that) {
case LibLoading():
return loading();case LibData():
return data(_that.value);case LibError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  loading,TResult? Function( T value)?  data,TResult? Function( AppException error)?  error,}) {final _that = this;
switch (_that) {
case LibLoading() when loading != null:
return loading();case LibData() when data != null:
return data(_that.value);case LibError() when error != null:
return error(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class LibLoading<T> implements LibAsync<T> {
  const LibLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LibLoading<T>);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'LibAsync<$T>.loading()';
}


}




/// @nodoc


class LibData<T> implements LibAsync<T> {
  const LibData({required this.value});
  

 final  T value;

/// Create a copy of LibAsync
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LibDataCopyWith<T, LibData<T>> get copyWith => _$LibDataCopyWithImpl<T, LibData<T>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LibData<T>&&const DeepCollectionEquality().equals(other.value, value));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(value));

@override
String toString() {
  return 'LibAsync<$T>.data(value: $value)';
}


}

/// @nodoc
abstract mixin class $LibDataCopyWith<T,$Res> implements $LibAsyncCopyWith<T, $Res> {
  factory $LibDataCopyWith(LibData<T> value, $Res Function(LibData<T>) _then) = _$LibDataCopyWithImpl;
@useResult
$Res call({
 T value
});




}
/// @nodoc
class _$LibDataCopyWithImpl<T,$Res>
    implements $LibDataCopyWith<T, $Res> {
  _$LibDataCopyWithImpl(this._self, this._then);

  final LibData<T> _self;
  final $Res Function(LibData<T>) _then;

/// Create a copy of LibAsync
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? value = freezed,}) {
  return _then(LibData<T>(
value: freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as T,
  ));
}


}

/// @nodoc


class LibError<T> implements LibAsync<T> {
  const LibError({required this.error});
  

 final  AppException error;

/// Create a copy of LibAsync
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LibErrorCopyWith<T, LibError<T>> get copyWith => _$LibErrorCopyWithImpl<T, LibError<T>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LibError<T>&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'LibAsync<$T>.error(error: $error)';
}


}

/// @nodoc
abstract mixin class $LibErrorCopyWith<T,$Res> implements $LibAsyncCopyWith<T, $Res> {
  factory $LibErrorCopyWith(LibError<T> value, $Res Function(LibError<T>) _then) = _$LibErrorCopyWithImpl;
@useResult
$Res call({
 AppException error
});


$AppExceptionCopyWith<$Res> get error;

}
/// @nodoc
class _$LibErrorCopyWithImpl<T,$Res>
    implements $LibErrorCopyWith<T, $Res> {
  _$LibErrorCopyWithImpl(this._self, this._then);

  final LibError<T> _self;
  final $Res Function(LibError<T>) _then;

/// Create a copy of LibAsync
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(LibError<T>(
error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as AppException,
  ));
}

/// Create a copy of LibAsync
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
