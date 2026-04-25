import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:rcbc_atm_go/core/constants/app_colors.dart';
import 'package:rcbc_atm_go/core/constants/app_strings.dart';
import 'package:rcbc_atm_go/features/transaction/presentation/cubits/transaction_cubit.dart';

class WithdrawalAmountPage extends StatefulWidget {
  const WithdrawalAmountPage({super.key});

  @override
  State<WithdrawalAmountPage> createState() => _WithdrawalAmountPageState();
}

class _WithdrawalAmountPageState extends State<WithdrawalAmountPage> {
  String _amountBuffer = '';

  String get _formattedAmount {
    if (_amountBuffer.isEmpty) {
      return 'PHP 0.00';
    }
    final amount = double.tryParse(_amountBuffer) ?? 0;
    return 'PHP ${amount.toStringAsFixed(2)}';
  }

  bool get _canEnter =>
      _amountBuffer.isNotEmpty && (double.tryParse(_amountBuffer) ?? 0) > 0;

  void _onDigitTap(String digit) {
    setState(() {
      _amountBuffer += digit;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.withdraw)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Please Enter Amount',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Container(
              height: 56,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black26),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _formattedAmount,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                children: [
                  ...List.generate(
                    9,
                    (index) => _KeypadButton(
                      label: '${index + 1}',
                      onPressed: () => _onDigitTap('${index + 1}'),
                    ),
                  ),
                  _KeypadButton(
                    label: AppStrings.cancel,
                    color: AppColors.cancel,
                    onPressed: () => context.go('/menu'),
                  ),
                  _KeypadButton(label: '0', onPressed: () => _onDigitTap('0')),
                  _KeypadButton(
                    label: AppStrings.clear,
                    color: AppColors.clear,
                    onPressed: () => setState(() => _amountBuffer = ''),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _canEnter ? AppColors.confirm : Colors.grey,
              ),
              onPressed: _canEnter
                  ? () {
                      final amount = double.parse(_amountBuffer);
                      context.read<TransactionCubit>().enterAmount(amount);
                      context.go('/withdraw/summary');
                    }
                  : null,
              child: const Text(AppStrings.enter),
            ),
          ],
        ),
      ),
    );
  }
}

class _KeypadButton extends StatelessWidget {
  const _KeypadButton({
    required this.label,
    required this.onPressed,
    this.color,
  });

  final String label;
  final VoidCallback onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: color),
      onPressed: onPressed,
      child: Text(label, textAlign: TextAlign.center),
    );
  }
}
