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

class TransactionCardInserted extends TransactionState {
  const TransactionCardInserted({
    required this.amount,
    required this.maskedCard,
    required this.cardHolder,
    required this.expiry,
    required this.cardType,
    required this.accountType,
  });

  final double amount;
  final String maskedCard;
  final String cardHolder;
  final String expiry;
  final String cardType;
  final String accountType;

  @override
  List<Object?> get props => [
        amount,
        maskedCard,
        cardHolder,
        expiry,
        cardType,
        accountType,
      ];
}

class TransactionPinEntered extends TransactionState {
  const TransactionPinEntered({
    required this.amount,
    required this.maskedCard,
    required this.cardHolder,
    required this.expiry,
    required this.cardType,
    required this.accountType,
    required this.pin,
  });

  final double amount;
  final String maskedCard;
  final String cardHolder;
  final String expiry;
  final String cardType;
  final String accountType;
  final String pin;

  @override
  List<Object?> get props => [
        amount,
        maskedCard,
        cardHolder,
        expiry,
        cardType,
        accountType,
        pin,
      ];
}

class TransactionProcessing extends TransactionState {
  const TransactionProcessing({
    required this.amount,
    required this.maskedCard,
    required this.cardHolder,
    required this.expiry,
    required this.cardType,
    required this.accountType,
  });

  final double amount;
  final String maskedCard;
  final String cardHolder;
  final String expiry;
  final String cardType;
  final String accountType;

  @override
  List<Object?> get props => [
        amount,
        maskedCard,
        cardHolder,
        expiry,
        cardType,
        accountType,
      ];
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
