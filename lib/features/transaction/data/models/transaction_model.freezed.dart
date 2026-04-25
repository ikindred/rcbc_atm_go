// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TransactionModel _$TransactionModelFromJson(Map<String, dynamic> json) {
  return _TransactionModel.fromJson(json);
}

/// @nodoc
mixin _$TransactionModel {
  String get transactionType => throw _privateConstructorUsedError;
  String get dateTime => throw _privateConstructorUsedError;
  String get rrn => throw _privateConstructorUsedError;
  String get tid => throw _privateConstructorUsedError;
  String get mid => throw _privateConstructorUsedError;
  String get invoiceNo => throw _privateConstructorUsedError;
  String get traceId => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String get cardType => throw _privateConstructorUsedError;
  String get authCode => throw _privateConstructorUsedError;
  String get cardNo => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  double get acquirerFee => throw _privateConstructorUsedError;
  double get total => throw _privateConstructorUsedError;

  /// Serializes this TransactionModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TransactionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TransactionModelCopyWith<TransactionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TransactionModelCopyWith<$Res> {
  factory $TransactionModelCopyWith(
    TransactionModel value,
    $Res Function(TransactionModel) then,
  ) = _$TransactionModelCopyWithImpl<$Res, TransactionModel>;
  @useResult
  $Res call({
    String transactionType,
    String dateTime,
    String rrn,
    String tid,
    String mid,
    String invoiceNo,
    String traceId,
    String status,
    String cardType,
    String authCode,
    String cardNo,
    double amount,
    double acquirerFee,
    double total,
  });
}

/// @nodoc
class _$TransactionModelCopyWithImpl<$Res, $Val extends TransactionModel>
    implements $TransactionModelCopyWith<$Res> {
  _$TransactionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TransactionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? transactionType = null,
    Object? dateTime = null,
    Object? rrn = null,
    Object? tid = null,
    Object? mid = null,
    Object? invoiceNo = null,
    Object? traceId = null,
    Object? status = null,
    Object? cardType = null,
    Object? authCode = null,
    Object? cardNo = null,
    Object? amount = null,
    Object? acquirerFee = null,
    Object? total = null,
  }) {
    return _then(
      _value.copyWith(
            transactionType: null == transactionType
                ? _value.transactionType
                : transactionType // ignore: cast_nullable_to_non_nullable
                      as String,
            dateTime: null == dateTime
                ? _value.dateTime
                : dateTime // ignore: cast_nullable_to_non_nullable
                      as String,
            rrn: null == rrn
                ? _value.rrn
                : rrn // ignore: cast_nullable_to_non_nullable
                      as String,
            tid: null == tid
                ? _value.tid
                : tid // ignore: cast_nullable_to_non_nullable
                      as String,
            mid: null == mid
                ? _value.mid
                : mid // ignore: cast_nullable_to_non_nullable
                      as String,
            invoiceNo: null == invoiceNo
                ? _value.invoiceNo
                : invoiceNo // ignore: cast_nullable_to_non_nullable
                      as String,
            traceId: null == traceId
                ? _value.traceId
                : traceId // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            cardType: null == cardType
                ? _value.cardType
                : cardType // ignore: cast_nullable_to_non_nullable
                      as String,
            authCode: null == authCode
                ? _value.authCode
                : authCode // ignore: cast_nullable_to_non_nullable
                      as String,
            cardNo: null == cardNo
                ? _value.cardNo
                : cardNo // ignore: cast_nullable_to_non_nullable
                      as String,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double,
            acquirerFee: null == acquirerFee
                ? _value.acquirerFee
                : acquirerFee // ignore: cast_nullable_to_non_nullable
                      as double,
            total: null == total
                ? _value.total
                : total // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TransactionModelImplCopyWith<$Res>
    implements $TransactionModelCopyWith<$Res> {
  factory _$$TransactionModelImplCopyWith(
    _$TransactionModelImpl value,
    $Res Function(_$TransactionModelImpl) then,
  ) = __$$TransactionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String transactionType,
    String dateTime,
    String rrn,
    String tid,
    String mid,
    String invoiceNo,
    String traceId,
    String status,
    String cardType,
    String authCode,
    String cardNo,
    double amount,
    double acquirerFee,
    double total,
  });
}

/// @nodoc
class __$$TransactionModelImplCopyWithImpl<$Res>
    extends _$TransactionModelCopyWithImpl<$Res, _$TransactionModelImpl>
    implements _$$TransactionModelImplCopyWith<$Res> {
  __$$TransactionModelImplCopyWithImpl(
    _$TransactionModelImpl _value,
    $Res Function(_$TransactionModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TransactionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? transactionType = null,
    Object? dateTime = null,
    Object? rrn = null,
    Object? tid = null,
    Object? mid = null,
    Object? invoiceNo = null,
    Object? traceId = null,
    Object? status = null,
    Object? cardType = null,
    Object? authCode = null,
    Object? cardNo = null,
    Object? amount = null,
    Object? acquirerFee = null,
    Object? total = null,
  }) {
    return _then(
      _$TransactionModelImpl(
        transactionType: null == transactionType
            ? _value.transactionType
            : transactionType // ignore: cast_nullable_to_non_nullable
                  as String,
        dateTime: null == dateTime
            ? _value.dateTime
            : dateTime // ignore: cast_nullable_to_non_nullable
                  as String,
        rrn: null == rrn
            ? _value.rrn
            : rrn // ignore: cast_nullable_to_non_nullable
                  as String,
        tid: null == tid
            ? _value.tid
            : tid // ignore: cast_nullable_to_non_nullable
                  as String,
        mid: null == mid
            ? _value.mid
            : mid // ignore: cast_nullable_to_non_nullable
                  as String,
        invoiceNo: null == invoiceNo
            ? _value.invoiceNo
            : invoiceNo // ignore: cast_nullable_to_non_nullable
                  as String,
        traceId: null == traceId
            ? _value.traceId
            : traceId // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        cardType: null == cardType
            ? _value.cardType
            : cardType // ignore: cast_nullable_to_non_nullable
                  as String,
        authCode: null == authCode
            ? _value.authCode
            : authCode // ignore: cast_nullable_to_non_nullable
                  as String,
        cardNo: null == cardNo
            ? _value.cardNo
            : cardNo // ignore: cast_nullable_to_non_nullable
                  as String,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
        acquirerFee: null == acquirerFee
            ? _value.acquirerFee
            : acquirerFee // ignore: cast_nullable_to_non_nullable
                  as double,
        total: null == total
            ? _value.total
            : total // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TransactionModelImpl implements _TransactionModel {
  const _$TransactionModelImpl({
    required this.transactionType,
    required this.dateTime,
    required this.rrn,
    required this.tid,
    required this.mid,
    required this.invoiceNo,
    required this.traceId,
    required this.status,
    required this.cardType,
    required this.authCode,
    required this.cardNo,
    required this.amount,
    required this.acquirerFee,
    required this.total,
  });

  factory _$TransactionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TransactionModelImplFromJson(json);

  @override
  final String transactionType;
  @override
  final String dateTime;
  @override
  final String rrn;
  @override
  final String tid;
  @override
  final String mid;
  @override
  final String invoiceNo;
  @override
  final String traceId;
  @override
  final String status;
  @override
  final String cardType;
  @override
  final String authCode;
  @override
  final String cardNo;
  @override
  final double amount;
  @override
  final double acquirerFee;
  @override
  final double total;

  @override
  String toString() {
    return 'TransactionModel(transactionType: $transactionType, dateTime: $dateTime, rrn: $rrn, tid: $tid, mid: $mid, invoiceNo: $invoiceNo, traceId: $traceId, status: $status, cardType: $cardType, authCode: $authCode, cardNo: $cardNo, amount: $amount, acquirerFee: $acquirerFee, total: $total)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TransactionModelImpl &&
            (identical(other.transactionType, transactionType) ||
                other.transactionType == transactionType) &&
            (identical(other.dateTime, dateTime) ||
                other.dateTime == dateTime) &&
            (identical(other.rrn, rrn) || other.rrn == rrn) &&
            (identical(other.tid, tid) || other.tid == tid) &&
            (identical(other.mid, mid) || other.mid == mid) &&
            (identical(other.invoiceNo, invoiceNo) ||
                other.invoiceNo == invoiceNo) &&
            (identical(other.traceId, traceId) || other.traceId == traceId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.cardType, cardType) ||
                other.cardType == cardType) &&
            (identical(other.authCode, authCode) ||
                other.authCode == authCode) &&
            (identical(other.cardNo, cardNo) || other.cardNo == cardNo) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.acquirerFee, acquirerFee) ||
                other.acquirerFee == acquirerFee) &&
            (identical(other.total, total) || other.total == total));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    transactionType,
    dateTime,
    rrn,
    tid,
    mid,
    invoiceNo,
    traceId,
    status,
    cardType,
    authCode,
    cardNo,
    amount,
    acquirerFee,
    total,
  );

  /// Create a copy of TransactionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TransactionModelImplCopyWith<_$TransactionModelImpl> get copyWith =>
      __$$TransactionModelImplCopyWithImpl<_$TransactionModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TransactionModelImplToJson(this);
  }
}

abstract class _TransactionModel implements TransactionModel {
  const factory _TransactionModel({
    required final String transactionType,
    required final String dateTime,
    required final String rrn,
    required final String tid,
    required final String mid,
    required final String invoiceNo,
    required final String traceId,
    required final String status,
    required final String cardType,
    required final String authCode,
    required final String cardNo,
    required final double amount,
    required final double acquirerFee,
    required final double total,
  }) = _$TransactionModelImpl;

  factory _TransactionModel.fromJson(Map<String, dynamic> json) =
      _$TransactionModelImpl.fromJson;

  @override
  String get transactionType;
  @override
  String get dateTime;
  @override
  String get rrn;
  @override
  String get tid;
  @override
  String get mid;
  @override
  String get invoiceNo;
  @override
  String get traceId;
  @override
  String get status;
  @override
  String get cardType;
  @override
  String get authCode;
  @override
  String get cardNo;
  @override
  double get amount;
  @override
  double get acquirerFee;
  @override
  double get total;

  /// Create a copy of TransactionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TransactionModelImplCopyWith<_$TransactionModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
