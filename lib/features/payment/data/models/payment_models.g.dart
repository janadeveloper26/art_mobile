// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CourseOrderResponseImpl _$$CourseOrderResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$CourseOrderResponseImpl(
      orderId: json['order_id'] as String,
      amount: (json['amount'] as num).toInt(),
      currency: json['currency'] as String,
      status: json['status'] as String,
      gatewayKey: json['gateway_key'] as String,
    );

Map<String, dynamic> _$$CourseOrderResponseImplToJson(
        _$CourseOrderResponseImpl instance) =>
    <String, dynamic>{
      'order_id': instance.orderId,
      'amount': instance.amount,
      'currency': instance.currency,
      'status': instance.status,
      'gateway_key': instance.gatewayKey,
    };

_$SubscriptionOrderResponseImpl _$$SubscriptionOrderResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$SubscriptionOrderResponseImpl(
      subscriptionId: json['subscription_id'] as String,
      status: json['status'] as String,
      gatewayKey: json['gateway_key'] as String,
    );

Map<String, dynamic> _$$SubscriptionOrderResponseImplToJson(
        _$SubscriptionOrderResponseImpl instance) =>
    <String, dynamic>{
      'subscription_id': instance.subscriptionId,
      'status': instance.status,
      'gateway_key': instance.gatewayKey,
    };
