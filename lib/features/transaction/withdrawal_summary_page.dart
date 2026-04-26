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
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Center(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Transaction Summary',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _SummaryRow(
                          label: 'Amount',
                          value: 'PHP ${amount.toStringAsFixed(2)}',
                        ),
                        const Divider(color: AppColors.divider),
                        const _SummaryRow(
                            label: 'Acquirer Fee', value: 'PHP 0.00'),
                        const Divider(color: AppColors.divider),
                        _SummaryRow(
                          label: 'Total',
                          value: 'PHP ${total.toStringAsFixed(2)}',
                          isTotal: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.cancel,
                      side: const BorderSide(
                        color: AppColors.cancel,
                        width: 1.5,
                      ),
                    ),
                    onPressed: () => context.go('/menu'),
                    child: const Text(AppStrings.cancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: amount <= 0
                        ? null
                        : () => context.push('/withdraw/card-entry'),
                    child: const Text(AppStrings.proceed),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  final String label;
  final String value;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: AppColors.textSecond),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: isTotal ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
