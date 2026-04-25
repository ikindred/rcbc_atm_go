// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TransactionModelImpl _$$TransactionModelImplFromJson(
  Map<String, dynamic> json,
) => _$TransactionModelImpl(
  transactionType: json['transactionType'] as String,
  dateTime: json['dateTime'] as String,
  rrn: json['rrn'] as String,
  tid: json['tid'] as String,
  mid: json['mid'] as String,
  invoiceNo: json['invoiceNo'] as String,
  traceId: json['traceId'] as String,
  status: json['status'] as String,
  cardType: json['cardType'] as String,
  authCode: json['authCode'] as String,
  cardNo: json['cardNo'] as String,
  amount: (json['amount'] as num).toDouble(),
  acquirerFee: (json['acquirerFee'] as num).toDouble(),
  total: (json['total'] as num).toDouble(),
);

Map<String, dynamic> _$$TransactionModelImplToJson(
  _$TransactionModelImpl instance,
) => <String, dynamic>{
  'transactionType': instance.transactionType,
  'dateTime': instance.dateTime,
  'rrn': instance.rrn,
  'tid': instance.tid,
  'mid': instance.mid,
  'invoiceNo': instance.invoiceNo,
  'traceId': instance.traceId,
  'status': instance.status,
  'cardType': instance.cardType,
  'authCode': instance.authCode,
  'cardNo': instance.cardNo,
  'amount': instance.amount,
  'acquirerFee': instance.acquirerFee,
  'total': instance.total,
};
