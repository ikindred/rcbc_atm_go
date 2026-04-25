import 'package:equatable/equatable.dart';
import 'package:rcbc_atm_go/features/transaction/data/models/transaction_model.dart';

sealed class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object?> get props => [];
}

class TransactionInitial extends TransactionState {
  const TransactionInitial();
}

class TransactionAmountEntered extends TransactionState {
  const TransactionAmountEntered(this.amount);

  final double amount;

  @override
  List<Object?> get props => [amount];
}

class TransactionConfirmed extends TransactionState {
  const TransactionConfirmed(this.transaction);

  final TransactionModel transaction;

  @override
  List<Object?> get props => [transaction];
}

class TransactionSuccess extends TransactionState {
  const TransactionSuccess(this.transaction);

  final TransactionModel transaction;

  @override
  List<Object?> get props => [transaction];
}

class TransactionError extends TransactionState {
  const TransactionError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
