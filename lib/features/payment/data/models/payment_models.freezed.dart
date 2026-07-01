// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CourseOrderResponse _$CourseOrderResponseFromJson(Map<String, dynamic> json) {
  return _CourseOrderResponse.fromJson(json);
}

/// @nodoc
mixin _$CourseOrderResponse {
  @JsonKey(name: 'order_id')
  String get orderId => throw _privateConstructorUsedError;
  int get amount => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'gateway_key')
  String get gatewayKey => throw _privateConstructorUsedError;

  /// Serializes this CourseOrderResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CourseOrderResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CourseOrderResponseCopyWith<CourseOrderResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CourseOrderResponseCopyWith<$Res> {
  factory $CourseOrderResponseCopyWith(
          CourseOrderResponse value, $Res Function(CourseOrderResponse) then) =
      _$CourseOrderResponseCopyWithImpl<$Res, CourseOrderResponse>;
  @useResult
  $Res call(
      {@JsonKey(name: 'order_id') String orderId,
      int amount,
      String currency,
      String status,
      @JsonKey(name: 'gateway_key') String gatewayKey});
}

/// @nodoc
class _$CourseOrderResponseCopyWithImpl<$Res, $Val extends CourseOrderResponse>
    implements $CourseOrderResponseCopyWith<$Res> {
  _$CourseOrderResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CourseOrderResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? orderId = null,
    Object? amount = null,
    Object? currency = null,
    Object? status = null,
    Object? gatewayKey = null,
  }) {
    return _then(_value.copyWith(
      orderId: null == orderId
          ? _value.orderId
          : orderId // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as int,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      gatewayKey: null == gatewayKey
          ? _value.gatewayKey
          : gatewayKey // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CourseOrderResponseImplCopyWith<$Res>
    implements $CourseOrderResponseCopyWith<$Res> {
  factory _$$CourseOrderResponseImplCopyWith(_$CourseOrderResponseImpl value,
          $Res Function(_$CourseOrderResponseImpl) then) =
      __$$CourseOrderResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'order_id') String orderId,
      int amount,
      String currency,
      String status,
      @JsonKey(name: 'gateway_key') String gatewayKey});
}

/// @nodoc
class __$$CourseOrderResponseImplCopyWithImpl<$Res>
    extends _$CourseOrderResponseCopyWithImpl<$Res, _$CourseOrderResponseImpl>
    implements _$$CourseOrderResponseImplCopyWith<$Res> {
  __$$CourseOrderResponseImplCopyWithImpl(_$CourseOrderResponseImpl _value,
      $Res Function(_$CourseOrderResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of CourseOrderResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? orderId = null,
    Object? amount = null,
    Object? currency = null,
    Object? status = null,
    Object? gatewayKey = null,
  }) {
    return _then(_$CourseOrderResponseImpl(
      orderId: null == orderId
          ? _value.orderId
          : orderId // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as int,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      gatewayKey: null == gatewayKey
          ? _value.gatewayKey
          : gatewayKey // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CourseOrderResponseImpl implements _CourseOrderResponse {
  const _$CourseOrderResponseImpl(
      {@JsonKey(name: 'order_id') required this.orderId,
      required this.amount,
      required this.currency,
      required this.status,
      @JsonKey(name: 'gateway_key') required this.gatewayKey});

  factory _$CourseOrderResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$CourseOrderResponseImplFromJson(json);

  @override
  @JsonKey(name: 'order_id')
  final String orderId;
  @override
  final int amount;
  @override
  final String currency;
  @override
  final String status;
  @override
  @JsonKey(name: 'gateway_key')
  final String gatewayKey;

  @override
  String toString() {
    return 'CourseOrderResponse(orderId: $orderId, amount: $amount, currency: $currency, status: $status, gatewayKey: $gatewayKey)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CourseOrderResponseImpl &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.gatewayKey, gatewayKey) ||
                other.gatewayKey == gatewayKey));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, orderId, amount, currency, status, gatewayKey);

  /// Create a copy of CourseOrderResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CourseOrderResponseImplCopyWith<_$CourseOrderResponseImpl> get copyWith =>
      __$$CourseOrderResponseImplCopyWithImpl<_$CourseOrderResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CourseOrderResponseImplToJson(
      this,
    );
  }
}

abstract class _CourseOrderResponse implements CourseOrderResponse {
  const factory _CourseOrderResponse(
          {@JsonKey(name: 'order_id') required final String orderId,
          required final int amount,
          required final String currency,
          required final String status,
          @JsonKey(name: 'gateway_key') required final String gatewayKey}) =
      _$CourseOrderResponseImpl;

  factory _CourseOrderResponse.fromJson(Map<String, dynamic> json) =
      _$CourseOrderResponseImpl.fromJson;

  @override
  @JsonKey(name: 'order_id')
  String get orderId;
  @override
  int get amount;
  @override
  String get currency;
  @override
  String get status;
  @override
  @JsonKey(name: 'gateway_key')
  String get gatewayKey;

  /// Create a copy of CourseOrderResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CourseOrderResponseImplCopyWith<_$CourseOrderResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SubscriptionOrderResponse _$SubscriptionOrderResponseFromJson(
    Map<String, dynamic> json) {
  return _SubscriptionOrderResponse.fromJson(json);
}

/// @nodoc
mixin _$SubscriptionOrderResponse {
  @JsonKey(name: 'subscription_id')
  String get subscriptionId => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'gateway_key')
  String get gatewayKey => throw _privateConstructorUsedError;

  /// Serializes this SubscriptionOrderResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SubscriptionOrderResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubscriptionOrderResponseCopyWith<SubscriptionOrderResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubscriptionOrderResponseCopyWith<$Res> {
  factory $SubscriptionOrderResponseCopyWith(SubscriptionOrderResponse value,
          $Res Function(SubscriptionOrderResponse) then) =
      _$SubscriptionOrderResponseCopyWithImpl<$Res, SubscriptionOrderResponse>;
  @useResult
  $Res call(
      {@JsonKey(name: 'subscription_id') String subscriptionId,
      String status,
      @JsonKey(name: 'gateway_key') String gatewayKey});
}

/// @nodoc
class _$SubscriptionOrderResponseCopyWithImpl<$Res,
        $Val extends SubscriptionOrderResponse>
    implements $SubscriptionOrderResponseCopyWith<$Res> {
  _$SubscriptionOrderResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SubscriptionOrderResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? subscriptionId = null,
    Object? status = null,
    Object? gatewayKey = null,
  }) {
    return _then(_value.copyWith(
      subscriptionId: null == subscriptionId
          ? _value.subscriptionId
          : subscriptionId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      gatewayKey: null == gatewayKey
          ? _value.gatewayKey
          : gatewayKey // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SubscriptionOrderResponseImplCopyWith<$Res>
    implements $SubscriptionOrderResponseCopyWith<$Res> {
  factory _$$SubscriptionOrderResponseImplCopyWith(
          _$SubscriptionOrderResponseImpl value,
          $Res Function(_$SubscriptionOrderResponseImpl) then) =
      __$$SubscriptionOrderResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'subscription_id') String subscriptionId,
      String status,
      @JsonKey(name: 'gateway_key') String gatewayKey});
}

/// @nodoc
class __$$SubscriptionOrderResponseImplCopyWithImpl<$Res>
    extends _$SubscriptionOrderResponseCopyWithImpl<$Res,
        _$SubscriptionOrderResponseImpl>
    implements _$$SubscriptionOrderResponseImplCopyWith<$Res> {
  __$$SubscriptionOrderResponseImplCopyWithImpl(
      _$SubscriptionOrderResponseImpl _value,
      $Res Function(_$SubscriptionOrderResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of SubscriptionOrderResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? subscriptionId = null,
    Object? status = null,
    Object? gatewayKey = null,
  }) {
    return _then(_$SubscriptionOrderResponseImpl(
      subscriptionId: null == subscriptionId
          ? _value.subscriptionId
          : subscriptionId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      gatewayKey: null == gatewayKey
          ? _value.gatewayKey
          : gatewayKey // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SubscriptionOrderResponseImpl implements _SubscriptionOrderResponse {
  const _$SubscriptionOrderResponseImpl(
      {@JsonKey(name: 'subscription_id') required this.subscriptionId,
      required this.status,
      @JsonKey(name: 'gateway_key') required this.gatewayKey});

  factory _$SubscriptionOrderResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubscriptionOrderResponseImplFromJson(json);

  @override
  @JsonKey(name: 'subscription_id')
  final String subscriptionId;
  @override
  final String status;
  @override
  @JsonKey(name: 'gateway_key')
  final String gatewayKey;

  @override
  String toString() {
    return 'SubscriptionOrderResponse(subscriptionId: $subscriptionId, status: $status, gatewayKey: $gatewayKey)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubscriptionOrderResponseImpl &&
            (identical(other.subscriptionId, subscriptionId) ||
                other.subscriptionId == subscriptionId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.gatewayKey, gatewayKey) ||
                other.gatewayKey == gatewayKey));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, subscriptionId, status, gatewayKey);

  /// Create a copy of SubscriptionOrderResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubscriptionOrderResponseImplCopyWith<_$SubscriptionOrderResponseImpl>
      get copyWith => __$$SubscriptionOrderResponseImplCopyWithImpl<
          _$SubscriptionOrderResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SubscriptionOrderResponseImplToJson(
      this,
    );
  }
}

abstract class _SubscriptionOrderResponse implements SubscriptionOrderResponse {
  const factory _SubscriptionOrderResponse(
      {@JsonKey(name: 'subscription_id') required final String subscriptionId,
      required final String status,
      @JsonKey(name: 'gateway_key')
      required final String gatewayKey}) = _$SubscriptionOrderResponseImpl;

  factory _SubscriptionOrderResponse.fromJson(Map<String, dynamic> json) =
      _$SubscriptionOrderResponseImpl.fromJson;

  @override
  @JsonKey(name: 'subscription_id')
  String get subscriptionId;
  @override
  String get status;
  @override
  @JsonKey(name: 'gateway_key')
  String get gatewayKey;

  /// Create a copy of SubscriptionOrderResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubscriptionOrderResponseImplCopyWith<_$SubscriptionOrderResponseImpl>
      get copyWith => throw _privateConstructorUsedError;
}
