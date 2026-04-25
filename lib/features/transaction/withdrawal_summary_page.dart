import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:rcbc_atm_go/core/constants/app_colors.dart';
import 'package:rcbc_atm_go/core/constants/app_strings.dart';
import 'package:rcbc_atm_go/features/transaction/presentation/cubits/transaction_cubit.dart';
import 'package:rcbc_atm_go/features/transaction/presentation/cubits/transaction_state.dart';

class WithdrawalSummaryPage extends StatelessWidget {
  const WithdrawalSummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final amountState = context.watch<TransactionCubit>().state;
    final amount = amountState is TransactionAmountEntered
        ? amountState.amount
        : 0;
    const acquirerFee = 0.0;
    final total = amount + acquirerFee;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.withdraw)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Summary',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            _SummaryRow(
              label: 'Amount',
              value: 'PHP ${amount.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 8),
            const _SummaryRow(label: 'Acquirer Fee', value: 'PHP 0.00'),
            const SizedBox(height: 8),
            _SummaryRow(
              label: 'Total',
              value: 'PHP ${total.toStringAsFixed(2)}',
            ),
            const Spacer(),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.cancel,
                side: const BorderSide(color: AppColors.cancel),
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              onPressed: () => context.pop(),
              child: const Text(AppStrings.cancel),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.confirm,
              ),
              onPressed: amount <= 0
                  ? null
                  : () {
                      context.read<TransactionCubit>().confirmWithdrawal(
                        amount.toDouble(),
                      );
                      final state = context.read<TransactionCubit>().state;
                      if (state is TransactionSuccess) {
                        context.go('/receipt', extra: state.transaction);
                      }
                    },
              child: const Text(AppStrings.proceed),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
