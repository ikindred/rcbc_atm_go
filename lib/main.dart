import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rcbc_atm_go/app.dart';
import 'package:rcbc_atm_go/features/printer/data/printer_service.dart';
import 'package:rcbc_atm_go/features/printer/presentation/cubits/printer_cubit.dart';
import 'package:rcbc_atm_go/features/transaction/presentation/cubits/transaction_cubit.dart';

void main() {
  final printerService = PrinterService();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<TransactionCubit>(create: (_) => TransactionCubit()),
        BlocProvider<PrinterCubit>(
          create: (_) => PrinterCubit(printerService: printerService),
        ),
      ],
      child: const ATMGoApp(),
    ),
  );
}
