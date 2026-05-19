// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'browse_navigation_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BrowseNavigationState {

 List<BrowseItem> get stack;
/// Create a copy of BrowseNavigationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BrowseNavigationStateCopyWith<BrowseNavigationState> get copyWith => _$BrowseNavigationStateCopyWithImpl<BrowseNavigationState>(this as BrowseNavigationState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BrowseNavigationState&&const DeepCollectionEquality().equals(other.stack, stack));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(stack));

@override
String toString() {
  return 'BrowseNavigationState(stack: $stack)';
}


}

/// @nodoc
abstract mixin class $BrowseNavigationStateCopyWith<$Res>  {
  factory $BrowseNavigationStateCopyWith(BrowseNavigationState value, $Res Function(BrowseNavigationState) _then) = _$BrowseNavigationStateCopyWithImpl;
@useResult
$Res call({
 List<BrowseItem> stack
});




}
/// @nodoc
class _$BrowseNavigationStateCopyWithImpl<$Res>
    implements $BrowseNavigationStateCopyWith<$Res> {
  _$BrowseNavigationStateCopyWithImpl(this._self, this._then);

  final BrowseNavigationState _self;
  final $Res Function(BrowseNavigationState) _then;

/// Create a copy of BrowseNavigationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? stack = null,}) {
  return _then(_self.copyWith(
stack: null == stack ? _self.stack : stack // ignore: cast_nullable_to_non_nullable
as List<BrowseItem>,
  ));
}

}


/// Adds pattern-matching-related methods to [BrowseNavigationState].
extension BrowseNavigationStatePatterns on BrowseNavigationState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BrowseNavigationState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BrowseNavigationState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BrowseNavigationState value)  $default,){
final _that = this;
switch (_that) {
case _BrowseNavigationState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BrowseNavigationState value)?  $default,){
final _that = this;
switch (_that) {
case _BrowseNavigationState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<BrowseItem> stack)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BrowseNavigationState() when $default != null:
return $default(_that.stack);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<BrowseItem> stack)  $default,) {final _that = this;
switch (_that) {
case _BrowseNavigationState():
return $default(_that.stack);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<BrowseItem> stack)?  $default,) {final _that = this;
switch (_that) {
case _BrowseNavigationState() when $default != null:
return $default(_that.stack);case _:
  return null;

}
}

}

/// @nodoc


class _BrowseNavigationState implements BrowseNavigationState {
  const _BrowseNavigationState({final  List<BrowseItem> stack = const <BrowseItem>[]}): _stack = stack;
  

 final  List<BrowseItem> _stack;
@override@JsonKey() List<BrowseItem> get stack {
  if (_stack is EqualUnmodifiableListView) return _stack;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_stack);
}


/// Create a copy of BrowseNavigationState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BrowseNavigationStateCopyWith<_BrowseNavigationState> get copyWith => __$BrowseNavigationStateCopyWithImpl<_BrowseNavigationState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BrowseNavigationState&&const DeepCollectionEquality().equals(other._stack, _stack));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_stack));

@override
String toString() {
  return 'BrowseNavigationState(stack: $stack)';
}


}

/// @nodoc
abstract mixin class _$BrowseNavigationStateCopyWith<$Res> implements $BrowseNavigationStateCopyWith<$Res> {
  factory _$BrowseNavigationStateCopyWith(_BrowseNavigationState value, $Res Function(_BrowseNavigationState) _then) = __$BrowseNavigationStateCopyWithImpl;
@override @useResult
$Res call({
 List<BrowseItem> stack
});




}
/// @nodoc
class __$BrowseNavigationStateCopyWithImpl<$Res>
    implements _$BrowseNavigationStateCopyWith<$Res> {
  __$BrowseNavigationStateCopyWithImpl(this._self, this._then);

  final _BrowseNavigationState _self;
  final $Res Function(_BrowseNavigationState) _then;

/// Create a copy of BrowseNavigationState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? stack = null,}) {
  return _then(_BrowseNavigationState(
stack: null == stack ? _self._stack : stack // ignore: cast_nullable_to_non_nullable
as List<BrowseItem>,
  ));
}


}

// dart format on
