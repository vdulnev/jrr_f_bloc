// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'failed_downloads_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FailedDownloadsState {

 List<DownloadJob> get jobs;
/// Create a copy of FailedDownloadsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FailedDownloadsStateCopyWith<FailedDownloadsState> get copyWith => _$FailedDownloadsStateCopyWithImpl<FailedDownloadsState>(this as FailedDownloadsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FailedDownloadsState&&const DeepCollectionEquality().equals(other.jobs, jobs));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(jobs));

@override
String toString() {
  return 'FailedDownloadsState(jobs: $jobs)';
}


}

/// @nodoc
abstract mixin class $FailedDownloadsStateCopyWith<$Res>  {
  factory $FailedDownloadsStateCopyWith(FailedDownloadsState value, $Res Function(FailedDownloadsState) _then) = _$FailedDownloadsStateCopyWithImpl;
@useResult
$Res call({
 List<DownloadJob> jobs
});




}
/// @nodoc
class _$FailedDownloadsStateCopyWithImpl<$Res>
    implements $FailedDownloadsStateCopyWith<$Res> {
  _$FailedDownloadsStateCopyWithImpl(this._self, this._then);

  final FailedDownloadsState _self;
  final $Res Function(FailedDownloadsState) _then;

/// Create a copy of FailedDownloadsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? jobs = null,}) {
  return _then(_self.copyWith(
jobs: null == jobs ? _self.jobs : jobs // ignore: cast_nullable_to_non_nullable
as List<DownloadJob>,
  ));
}

}


/// Adds pattern-matching-related methods to [FailedDownloadsState].
extension FailedDownloadsStatePatterns on FailedDownloadsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FailedDownloadsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FailedDownloadsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FailedDownloadsState value)  $default,){
final _that = this;
switch (_that) {
case _FailedDownloadsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FailedDownloadsState value)?  $default,){
final _that = this;
switch (_that) {
case _FailedDownloadsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<DownloadJob> jobs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FailedDownloadsState() when $default != null:
return $default(_that.jobs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<DownloadJob> jobs)  $default,) {final _that = this;
switch (_that) {
case _FailedDownloadsState():
return $default(_that.jobs);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<DownloadJob> jobs)?  $default,) {final _that = this;
switch (_that) {
case _FailedDownloadsState() when $default != null:
return $default(_that.jobs);case _:
  return null;

}
}

}

/// @nodoc


class _FailedDownloadsState implements FailedDownloadsState {
  const _FailedDownloadsState({final  List<DownloadJob> jobs = const <DownloadJob>[]}): _jobs = jobs;
  

 final  List<DownloadJob> _jobs;
@override@JsonKey() List<DownloadJob> get jobs {
  if (_jobs is EqualUnmodifiableListView) return _jobs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_jobs);
}


/// Create a copy of FailedDownloadsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FailedDownloadsStateCopyWith<_FailedDownloadsState> get copyWith => __$FailedDownloadsStateCopyWithImpl<_FailedDownloadsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FailedDownloadsState&&const DeepCollectionEquality().equals(other._jobs, _jobs));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_jobs));

@override
String toString() {
  return 'FailedDownloadsState(jobs: $jobs)';
}


}

/// @nodoc
abstract mixin class _$FailedDownloadsStateCopyWith<$Res> implements $FailedDownloadsStateCopyWith<$Res> {
  factory _$FailedDownloadsStateCopyWith(_FailedDownloadsState value, $Res Function(_FailedDownloadsState) _then) = __$FailedDownloadsStateCopyWithImpl;
@override @useResult
$Res call({
 List<DownloadJob> jobs
});




}
/// @nodoc
class __$FailedDownloadsStateCopyWithImpl<$Res>
    implements _$FailedDownloadsStateCopyWith<$Res> {
  __$FailedDownloadsStateCopyWithImpl(this._self, this._then);

  final _FailedDownloadsState _self;
  final $Res Function(_FailedDownloadsState) _then;

/// Create a copy of FailedDownloadsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? jobs = null,}) {
  return _then(_FailedDownloadsState(
jobs: null == jobs ? _self._jobs : jobs // ignore: cast_nullable_to_non_nullable
as List<DownloadJob>,
  ));
}


}

// dart format on
