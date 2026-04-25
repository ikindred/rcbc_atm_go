import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rcbc_atm_go/features/transaction/data/models/transaction_model.dart';
import 'package:rcbc_atm_go/features/transaction/presentation/cubits/transaction_state.dart';

class TransactionCubit extends Cubit<TransactionState> {
  TransactionCubit() : super(const TransactionInitial());

  void enterAmount(double amount) {
    emit(TransactionAmountEntered(amount));
  }

  Future<void> simulateCardInsert(double amount) async {
    await Future<void>.delayed(const Duration(seconds: 2));
    emit(
      TransactionCardInserted(
        amount: amount,
        maskedCard: '**** **** **** 1105',
        cardHolder: 'JUAN DELA CRUZ',
        expiry: '05/26',
        cardType: 'MASTERCARD',
        accountType: 'SAVINGS',
      ),
    );
  }

  void enterPin(String pin) {
    final currentState = state;
    if (currentState is! TransactionCardInserted) {
      emit(const TransactionError('Card details are missing'));
      return;
    }

    emit(
      TransactionPinEntered(
        amount: currentState.amount,
        maskedCard: currentState.maskedCard,
        cardHolder: currentState.cardHolder,
        expiry: currentState.expiry,
        cardType: currentState.cardType,
        accountType: currentState.accountType,
        pin: pin,
      ),
    );
  }

  Future<void> processTransaction() async {
    final currentState = state;
    if (currentState is! TransactionPinEntered) {
      emit(const TransactionError('PIN is required before processing'));
      return;
    }

    emit(
      TransactionProcessing(
        amount: currentState.amount,
        maskedCard: currentState.maskedCard,
        cardHolder: currentState.cardHolder,
        expiry: currentState.expiry,
        cardType: currentState.cardType,
        accountType: currentState.accountType,
      ),
    );

    await Future<void>.delayed(const Duration(seconds: 3));

    final now = DateTime.now();
    final dateTime =
        '${now.month.toString().padLeft(2, '0')}/'
        '${now.day.toString().padLeft(2, '0')}/'
        '${now.year} '
        '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')}';

    final transaction = TransactionModel(
      transactionType: 'WITHDRAW',
      dateTime: dateTime,
      rrn: 'RRN${DateTime.now().millisecondsSinceEpoch % 1000000}',
      tid: '62000005',
      mid: '88000000',
      invoiceNo: 'INV${DateTime.now().millisecondsSinceEpoch % 1000000}',
      traceId: 'TRC${DateTime.now().millisecondsSinceEpoch % 1000000}',
      status: 'Success',
      cardType: currentState.cardType,
      authCode: 'A1B2C3',
      cardNo: currentState.maskedCard,
      amount: currentState.amount,
      acquirerFee: 0.00,
      total: currentState.amount,
    );
    emit(TransactionSuccess(transaction));
  }

  void reset() {
    emit(const TransactionInitial());
  }
}
