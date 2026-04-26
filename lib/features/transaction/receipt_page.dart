import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:rcbc_atm_go/core/constants/app_colors.dart';
import 'package:rcbc_atm_go/features/printer/presentation/cubits/printer_cubit.dart';
import 'package:rcbc_atm_go/features/printer/presentation/cubits/printer_state.dart';
import 'package:rcbc_atm_go/features/transaction/data/models/transaction_model.dart';
import 'package:rcbc_atm_go/features/transaction/presentation/cubits/transaction_cubit.dart';

class ReceiptPage extends StatefulWidget {
  const ReceiptPage({super.key, required this.transaction});

  final TransactionModel transaction;

  @override
  State<ReceiptPage> createState() => _ReceiptPageState();
}

class _ReceiptPageState extends State<ReceiptPage> {
  bool _tapped = false;
  bool _isPrinting = false;
  bool _printDone = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onPrinterState(BuildContext context, PrinterState state) {
    if (state is PrinterSuccess) {
      setState(() {
        _printDone = true;
        _isPrinting = false;
      });
    } else if (state is PrinterError) {
      setState(() {
        _tapped = false;
        _isPrinting = false;
        _printDone = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PrinterCubit, PrinterState>(
      listener: _onPrinterState,
      child: Scaffold(
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
              child: Stack(
                children: [
                  // Success overlay — visible once receipt has fully slid out
                  if (_printDone)
                    const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 64,
                            color: AppColors.success,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Receipt Printed',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Check your printed receipt',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecond,
                            ),
                          ),
                        ],
                      ),
                    ),
                  // Receipt card — slides up and off screen on print
                  AnimatedSlide(
                    offset: (_isPrinting || _printDone)
                        ? const Offset(0, -1.0)
                        : Offset.zero,
                    duration: const Duration(milliseconds: 2000),
                    curve: Curves.linear,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(40, 4, 40, 24),
                      child: Card(
                        color: const Color(0xFFFDFDFD),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Top customer copy
                              const Center(
                                child: Text(
                                  '***** CUSTOMER COPY *****',
                                  style: TextStyle(fontSize: 11),
                                ),
                              ),
                              const SizedBox(height: 14),
                              // Logo
                              Center(
                                child: Image.asset(
                                  'assets/images/atm_go_logo.png',
                                  height: 88,
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Bank info
                              const Center(
                                child: Text('RCBC Savings Bank',
                                    style: TextStyle(fontSize: 13)),
                              ),
                              const SizedBox(height: 2),
                              const Center(
                                child: Text('333 Sen. Gil Puyat Ave, Makati',
                                    style: TextStyle(fontSize: 12)),
                              ),
                              const SizedBox(height: 2),
                              const Center(
                                child: Text('www.rcbc.com',
                                    style: TextStyle(fontSize: 12)),
                              ),
                              const SizedBox(height: 12),
                              const _DashedDivider(),
                              const SizedBox(height: 8),
                              // Transaction type
                              Center(
                                child: Text(
                                  widget.transaction.transactionType
                                      .toUpperCase(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const _DashedDivider(),
                              const SizedBox(height: 6),
                              // Transaction details
                              _PrintRow(label: 'Date / Time', value: widget.transaction.dateTime),
                              _PrintRow(label: 'RRN', value: widget.transaction.rrn),
                              _PrintRow(label: 'TID', value: widget.transaction.tid),
                              _PrintRow(label: 'MID', value: widget.transaction.mid),
                              _PrintRow(label: 'Invoice No.', value: widget.transaction.invoiceNo),
                              _PrintRow(label: 'Trace ID', value: widget.transaction.traceId),
                              _PrintRow(label: 'Status', value: widget.transaction.status),
                              const SizedBox(height: 6),
                              const _DashedDivider(),
                              const SizedBox(height: 6),
                              // Card info
                              _PrintRow(label: 'Card Type', value: widget.transaction.cardType),
                              _PrintRow(label: 'Auth Code', value: widget.transaction.authCode),
                              _PrintRow(label: 'Card No.', value: widget.transaction.cardNo),
                              const SizedBox(height: 6),
                              const _DashedDivider(),
                              const SizedBox(height: 6),
                              // Amounts
                              _PrintRow(
                                label: 'Amount',
                                value: 'PHP  ${widget.transaction.amount.toStringAsFixed(2)}',
                              ),
                              _PrintRow(
                                label: 'Acquirer Fee',
                                value: 'PHP  ${widget.transaction.acquirerFee.toStringAsFixed(2)}',
                              ),
                              const SizedBox(height: 6),
                              _PrintRow(
                                label: 'TOTAL',
                                value: 'PHP  ${widget.transaction.total.toStringAsFixed(2)}',
                                bold: true,
                              ),
                              const SizedBox(height: 16),
                              // Footer text
                              const Center(
                                child: Text('PIN Verified',
                                    style: TextStyle(fontSize: 12)),
                              ),
                              const SizedBox(height: 2),
                              const Center(
                                child: Text('Signature Not Required',
                                    style: TextStyle(fontSize: 12)),
                              ),
                              const SizedBox(height: 12),
                              const Center(
                                child: Text('RCBC/CARD',
                                    style: TextStyle(fontSize: 12)),
                              ),
                              const SizedBox(height: 14),
                              const _DashedDivider(),
                              const SizedBox(height: 8),
                              // Bottom customer copy
                              const Center(
                                child: Text(
                                  '***** CUSTOMER COPY *****',
                                  style: TextStyle(fontSize: 11),
                                ),
                              ),
                              const SizedBox(height: 4),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: (_tapped || _isPrinting || _printDone)
                          ? null
                          : () {
                              setState(() => _tapped = true);
                              // Start print immediately, animate after 0.2s
                              context
                                  .read<PrinterCubit>()
                                  .print(widget.transaction);
                              Future.delayed(const Duration(milliseconds: 200), () {
                                if (mounted) {
                                  setState(() => _isPrinting = true);
                                }
                              });
                            },
                      style: _printDone
                          ? ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success,
                              disabledBackgroundColor: AppColors.success,
                            )
                          : null,
                      child: _isPrinting
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(_printDone ? 'PRINTED ✓' : 'PRINT'),
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
                        side: const BorderSide(
                            color: AppColors.primary, width: 1.5),
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
    );
  }
}

class _PrintRow extends StatelessWidget {
  const _PrintRow({required this.label, required this.value, this.bold = false});

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: 13,
      fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 108,
            child: Text(label, style: style),
          ),
          Text(': ', style: style),
          Expanded(
            child: Text(value, style: style),
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
