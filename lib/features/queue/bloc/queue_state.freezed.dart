// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'queue_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$QueueState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QueueState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'QueueState()';
}


}

/// @nodoc
class $QueueStateCopyWith<$Res>  {
$QueueStateCopyWith(QueueState _, $Res Function(QueueState) __);
}


/// Adds pattern-matching-related methods to [QueueState].
extension QueueStatePatterns on QueueState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( QueueLoading value)?  loading,TResult Function( QueueLoaded value)?  loaded,TResult Function( QueueError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case QueueLoading() when loading != null:
return loading(_that);case QueueLoaded() when loaded != null:
return loaded(_that);case QueueError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( QueueLoading value)  loading,required TResult Function( QueueLoaded value)  loaded,required TResult Function( QueueError value)  error,}){
final _that = this;
switch (_that) {
case QueueLoading():
return loading(_that);case QueueLoaded():
return loaded(_that);case QueueError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( QueueLoading value)?  loading,TResult? Function( QueueLoaded value)?  loaded,TResult? Function( QueueError value)?  error,}){
final _that = this;
switch (_that) {
case QueueLoading() when loading != null:
return loading(_that);case QueueLoaded() when loaded != null:
return loaded(_that);case QueueError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  loading,TResult Function( Tracks tracks,  int currentIndex)?  loaded,TResult Function( AppException error)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case QueueLoading() when loading != null:
return loading();case QueueLoaded() when loaded != null:
return loaded(_that.tracks,_that.currentIndex);case QueueError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  loading,required TResult Function( Tracks tracks,  int currentIndex)  loaded,required TResult Function( AppException error)  error,}) {final _that = this;
switch (_that) {
case QueueLoading():
return loading();case QueueLoaded():
return loaded(_that.tracks,_that.currentIndex);case QueueError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  loading,TResult? Function( Tracks tracks,  int currentIndex)?  loaded,TResult? Function( AppException error)?  error,}) {final _that = this;
switch (_that) {
case QueueLoading() when loading != null:
return loading();case QueueLoaded() when loaded != null:
return loaded(_that.tracks,_that.currentIndex);case QueueError() when error != null:
return error(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class QueueLoading implements QueueState {
  const QueueLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QueueLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'QueueState.loading()';
}


}




/// @nodoc


class QueueLoaded implements QueueState {
  const QueueLoaded({required this.tracks, required this.currentIndex});
  

 final  Tracks tracks;
 final  int currentIndex;

/// Create a copy of QueueState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QueueLoadedCopyWith<QueueLoaded> get copyWith => _$QueueLoadedCopyWithImpl<QueueLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QueueLoaded&&(identical(other.tracks, tracks) || other.tracks == tracks)&&(identical(other.currentIndex, currentIndex) || other.currentIndex == currentIndex));
}


@override
int get hashCode => Object.hash(runtimeType,tracks,currentIndex);

@override
String toString() {
  return 'QueueState.loaded(tracks: $tracks, currentIndex: $currentIndex)';
}


}

/// @nodoc
abstract mixin class $QueueLoadedCopyWith<$Res> implements $QueueStateCopyWith<$Res> {
  factory $QueueLoadedCopyWith(QueueLoaded value, $Res Function(QueueLoaded) _then) = _$QueueLoadedCopyWithImpl;
@useResult
$Res call({
 Tracks tracks, int currentIndex
});


$TracksCopyWith<$Res> get tracks;

}
/// @nodoc
class _$QueueLoadedCopyWithImpl<$Res>
    implements $QueueLoadedCopyWith<$Res> {
  _$QueueLoadedCopyWithImpl(this._self, this._then);

  final QueueLoaded _self;
  final $Res Function(QueueLoaded) _then;

/// Create a copy of QueueState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? tracks = null,Object? currentIndex = null,}) {
  return _then(QueueLoaded(
tracks: null == tracks ? _self.tracks : tracks // ignore: cast_nullable_to_non_nullable
as Tracks,currentIndex: null == currentIndex ? _self.currentIndex : currentIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of QueueState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TracksCopyWith<$Res> get tracks {
  
  return $TracksCopyWith<$Res>(_self.tracks, (value) {
    return _then(_self.copyWith(tracks: value));
  });
}
}

/// @nodoc


class QueueError implements QueueState {
  const QueueError({required this.error});
  

 final  AppException error;

/// Create a copy of QueueState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QueueErrorCopyWith<QueueError> get copyWith => _$QueueErrorCopyWithImpl<QueueError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QueueError&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'QueueState.error(error: $error)';
}


}

/// @nodoc
abstract mixin class $QueueErrorCopyWith<$Res> implements $QueueStateCopyWith<$Res> {
  factory $QueueErrorCopyWith(QueueError value, $Res Function(QueueError) _then) = _$QueueErrorCopyWithImpl;
@useResult
$Res call({
 AppException error
});


$AppExceptionCopyWith<$Res> get error;

}
/// @nodoc
class _$QueueErrorCopyWithImpl<$Res>
    implements $QueueErrorCopyWith<$Res> {
  _$QueueErrorCopyWithImpl(this._self, this._then);

  final QueueError _self;
  final $Res Function(QueueError) _then;

/// Create a copy of QueueState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(QueueError(
error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as AppException,
  ));
}

/// Create a copy of QueueState
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
