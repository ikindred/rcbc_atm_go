import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rcbc_atm_go/features/printer/data/printer_service.dart';
import 'package:rcbc_atm_go/features/printer/presentation/cubits/printer_state.dart';
import 'package:rcbc_atm_go/features/transaction/data/models/transaction_model.dart';

class PrinterCubit extends Cubit<PrinterState> {
  PrinterCubit({required PrinterService printerService})
    : _printerService = printerService,
      super(const PrinterInitial());

  final PrinterService _printerService;

  Future<void> print(TransactionModel tx) async {
    emit(const PrinterPrinting());
    final result = await _printerService.printReceipt(tx);
    if (result.success) {
      emit(const PrinterSuccess());
    } else {
      emit(PrinterError(result.message));
    }
  }
}
