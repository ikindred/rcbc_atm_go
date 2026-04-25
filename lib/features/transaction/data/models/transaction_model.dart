import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_model.freezed.dart';
part 'transaction_model.g.dart';

@freezed
class TransactionModel with _$TransactionModel {
  const factory TransactionModel({
    required String transactionType,
    required String dateTime,
    required String rrn,
    required String tid,
    required String mid,
    required String invoiceNo,
    required String traceId,
    required String status,
    required String cardType,
    required String authCode,
    required String cardNo,
    required double amount,
    required double acquirerFee,
    required double total,
  }) = _TransactionModel;

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);
}
