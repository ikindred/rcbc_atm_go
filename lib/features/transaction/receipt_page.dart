import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:rcbc_atm_go/core/constants/app_colors.dart';
import 'package:rcbc_atm_go/core/constants/app_strings.dart';
import 'package:rcbc_atm_go/features/printer/presentation/cubits/printer_cubit.dart';
import 'package:rcbc_atm_go/features/printer/presentation/cubits/printer_state.dart';
import 'package:rcbc_atm_go/features/transaction/data/models/transaction_model.dart';
import 'package:rcbc_atm_go/features/transaction/presentation/cubits/transaction_cubit.dart';

class ReceiptPage extends StatelessWidget {
  const ReceiptPage({super.key, required this.transaction});

  final TransactionModel transaction;

  @override
  Widget build(BuildContext context) {
    return BlocListener<PrinterCubit, PrinterState>(
      listener: (context, state) {
        if (state is PrinterSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Receipt printed successfully')),
          );
        } else if (state is PrinterError) {
          showDialog<void>(
            context: context,
            builder: (dialogContext) {
              return AlertDialog(
                title: const Text('Printer Error'),
                content: SingleChildScrollView(
                  child: SelectableText(state.message),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      },
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(title: const Text('RECEIPT')),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: DefaultTextStyle(
                        style: const TextStyle(color: Colors.black87),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Center(
                              child: Text(
                                'RCBC ATM GO',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Center(child: Text('MERCHANT NAME')),
                            const Center(child: Text('HEADER 1')),
                            const Center(child: Text('HEADER 2')),
                            const Center(child: Text('HEADER 3')),
                            const Center(child: Text('HEADER 4')),
                            const Center(child: Text('VERSION NUMBER')),
                            const SizedBox(height: 8),
                            const Center(
                              child: Text(
                                '<<WITHDRAW>>',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            const Divider(),
                            _ReceiptRow(
                              label: 'Date/Time',
                              value: transaction.dateTime,
                            ),
                            _ReceiptRow(label: 'RRN', value: transaction.rrn),
                            _ReceiptRow(label: 'TID', value: transaction.tid),
                            _ReceiptRow(label: 'MID', value: transaction.mid),
                            _ReceiptRow(
                              label: 'Invoice No.',
                              value: transaction.invoiceNo,
                            ),
                            _ReceiptRow(
                              label: 'Trace ID',
                              value: transaction.traceId,
                            ),
                            _ReceiptRow(
                              label: 'Status',
                              value: transaction.status,
                            ),
                            const Divider(),
                            _ReceiptRow(
                              label: 'Card Type',
                              value: transaction.cardType,
                            ),
                            _ReceiptRow(
                              label: 'Auth Code',
                              value: transaction.authCode,
                            ),
                            _ReceiptRow(
                              label: 'Card No.',
                              value: transaction.cardNo,
                            ),
                            const Divider(),
                            _AmountLine(
                              label: 'Amount',
                              amount: transaction.amount.toStringAsFixed(2),
                            ),
                            _AmountLine(
                              label: 'Acquirer Fee',
                              amount: transaction.acquirerFee.toStringAsFixed(
                                2,
                              ),
                            ),
                            _AmountLine(
                              label: 'Total',
                              amount: transaction.total.toStringAsFixed(2),
                            ),
                            const Divider(),
                            const Text('PIN Verified'),
                            const Text('Signature Not Required'),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    onPressed: () =>
                        context.read<PrinterCubit>().print(transaction),
                    child: const Text(AppStrings.print),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      context.read<TransactionCubit>().reset();
                      context.go('/menu');
                    },
                    child: const Text(AppStrings.back),
                  ),
                ],
              ),
            ),
          ),
          BlocBuilder<PrinterCubit, PrinterState>(
            builder: (context, state) {
              if (state is! PrinterPrinting) {
                return const SizedBox.shrink();
              }
              return Container(
                color: Colors.black38,
                alignment: Alignment.center,
                child: const CircularProgressIndicator(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(width: 110, child: Text(label)),
          const Text('|'),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _AmountLine extends StatelessWidget {
  const _AmountLine({required this.label, required this.amount});

  final String label;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text('PHP $amount'),
        ],
      ),
    );
  }
}
