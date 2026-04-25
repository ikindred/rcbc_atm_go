import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rcbc_atm_go/features/transaction/data/models/transaction_model.dart';
import 'package:rcbc_atm_go/features/transaction/presentation/cubits/transaction_state.dart';

class TransactionCubit extends Cubit<TransactionState> {
  TransactionCubit() : super(const TransactionInitial());

  void enterAmount(double amount) {
    emit(TransactionAmountEntered(amount));
  }

  void confirmWithdrawal(double amount) {
    final transaction = TransactionModel(
      transactionType: 'WITHDRAW',
      dateTime: DateTime.now().toString(),
      rrn: '000001',
      tid: '62000005',
      mid: '88000000',
      invoiceNo: 'INV000001',
      traceId: 'TRACE000001',
      status: 'Success',
      cardType: 'MASTERCARD',
      authCode: 'AUTH01',
      cardNo: 'XXXXXX******* XXXX',
      amount: amount,
      acquirerFee: 0.00,
      total: amount,
    );
    emit(TransactionConfirmed(transaction));
    emit(TransactionSuccess(transaction));
  }

  void reset() {
    emit(const TransactionInitial());
  }
}
