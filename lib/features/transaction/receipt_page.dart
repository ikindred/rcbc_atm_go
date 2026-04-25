import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:rcbc_atm_go/core/constants/app_colors.dart';
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
            appBar: AppBar(
              title: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: AppColors.success, size: 20),
                  SizedBox(width: 8),
                  Text('RECEIPT'),
                ],
              ),
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const _DashedDivider(),
                              const SizedBox(height: 14),
                              Center(
                                child: Image.asset(
                                  'assets/images/atm_go_logo.png',
                                  height: 64,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Center(
                                child: Text(
                                  transaction.transactionType.toUpperCase(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              const Divider(color: AppColors.divider),
                              _ReceiptRow(label: 'Date/Time', value: transaction.dateTime),
                              _ReceiptRow(label: 'RRN', value: transaction.rrn),
                              _ReceiptRow(label: 'TID', value: transaction.tid),
                              _ReceiptRow(label: 'MID', value: transaction.mid),
                              _ReceiptRow(label: 'Invoice No.', value: transaction.invoiceNo),
                              _ReceiptRow(label: 'Trace ID', value: transaction.traceId),
                              _ReceiptRow(label: 'Status', value: transaction.status),
                              const Divider(color: AppColors.divider),
                              _ReceiptRow(label: 'Card Type', value: transaction.cardType),
                              _ReceiptRow(label: 'Auth Code', value: transaction.authCode),
                              _ReceiptRow(label: 'Card No.', value: transaction.cardNo),
                              const Divider(color: AppColors.divider),
                              _AmountLine(
                                label: 'Amount',
                                amount: transaction.amount.toStringAsFixed(2),
                              ),
                              _AmountLine(
                                label: 'Acquirer Fee',
                                amount: transaction.acquirerFee.toStringAsFixed(2),
                              ),
                              _AmountLine(
                                label: 'Total',
                                amount: transaction.total.toStringAsFixed(2),
                                isTotal: true,
                              ),
                              const SizedBox(height: 14),
                              const Center(
                                child: Text(
                                  'PIN Verified',
                                  style: TextStyle(
                                    color: AppColors.textSecond,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const Center(
                                child: Text(
                                  'Signature Not Required',
                                  style: TextStyle(
                                    color: AppColors.textSecond,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              const _DashedDivider(),
                            ],
                          ),
                        ),
                      ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => context.read<PrinterCubit>().print(transaction),
                          child: const Text('PRINT'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            context.read<TransactionCubit>().reset();
                            context.go('/menu');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primary,
                            overlayColor: AppColors.primary.withOpacity(0.08),
                            side: const BorderSide(color: AppColors.primary, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('DONE'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textSecond),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AmountLine extends StatelessWidget {
  const _AmountLine({
    required this.label,
    required this.amount,
    this.isTotal = false,
  });

  final String label;
  final String amount;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
                color: isTotal ? AppColors.textPrimary : AppColors.textSecond,
              ),
            ),
          ),
          Text(
            'PHP $amount',
            style: TextStyle(
              fontSize: isTotal ? 16 : 13,
              fontWeight: FontWeight.w800,
              color: isTotal ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const dashWidth = 6.0;
        const dashSpace = 4.0;
        final dashCount = (constraints.maxWidth / (dashWidth + dashSpace)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List<Widget>.generate(dashCount, (_) {
            return const SizedBox(
              width: dashWidth,
              child: Divider(color: AppColors.divider, thickness: 1, height: 1),
            );
          }),
        );
      },
    );
  }
}
