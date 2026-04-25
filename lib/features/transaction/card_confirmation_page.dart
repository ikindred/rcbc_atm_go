import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:rcbc_atm_go/core/constants/app_colors.dart';
import 'package:rcbc_atm_go/features/transaction/presentation/cubits/transaction_cubit.dart';
import 'package:rcbc_atm_go/features/transaction/presentation/cubits/transaction_state.dart';

class CardConfirmPage extends StatelessWidget {
  const CardConfirmPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<TransactionCubit>().state;
    if (state is! TransactionCardInserted) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('WITHDRAW')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Please Confirm Transaction',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      state.maskedCard,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Expiry: ${state.expiry}  |  Card Holder: ${state.cardHolder}',
                      style: const TextStyle(color: AppColors.textSecond),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      state.cardType,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Divider(color: AppColors.divider, height: 24),
                    _InfoRow(label: 'Account type', value: state.accountType),
                    _InfoRow(
                      label: 'Withdrawal amount',
                      value: 'PHP ${state.amount.toStringAsFixed(2)}',
                    ),
                    _InfoRow(
                      label: 'Total amount',
                      value: 'PHP ${state.amount.toStringAsFixed(2)}',
                      isTotal: true,
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
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
                    onPressed: () {
                      context.read<TransactionCubit>().reset();
                      context.go('/menu');
                    },
                    child: const Text('CANCEL'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => context.go('/withdraw/pin'),
                    child: const Text('PROCEED'),
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  final String label;
  final String value;
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
      ),
    );
  }
}
