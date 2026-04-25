import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:rcbc_atm_go/core/constants/app_colors.dart';
import 'package:rcbc_atm_go/core/constants/app_strings.dart';
import 'package:rcbc_atm_go/core/widgets/numpad_key.dart';
import 'package:rcbc_atm_go/features/transaction/presentation/cubits/transaction_cubit.dart';

class WithdrawalAmountPage extends StatefulWidget {
  const WithdrawalAmountPage({super.key});

  @override
  State<WithdrawalAmountPage> createState() => _WithdrawalAmountPageState();
}

class _WithdrawalAmountPageState extends State<WithdrawalAmountPage> {
  String _amountBuffer = '';

  // ── Derived state ────────────────────────────────────────────────────────────

  double get _amount => double.tryParse(_amountBuffer) ?? 0;

  bool get _canEnter => _amountBuffer.isNotEmpty && _amount > 0;

  String get _formattedAmount {
    if (_amountBuffer.isEmpty) return 'PHP 0.00';
    return 'PHP ${_amount.toStringAsFixed(2)}';
  }

  // ── Handlers ─────────────────────────────────────────────────────────────────

  void _onDigitTap(String digit) => setState(() => _amountBuffer += digit);

  void _onBackspace() =>
      setState(() => _amountBuffer = _amountBuffer.isNotEmpty
          ? _amountBuffer.substring(0, _amountBuffer.length - 1)
          : '');

  void _onEnter() {
    context.read<TransactionCubit>().enterAmount(_amount);
    context.go('/withdraw/summary');
  }

  // ── Grid item builder ─────────────────────────────────────────────────────────

  Widget _buildKey(int index) {
    // Row 1-3: digits 1–9
    if (index <= 8) {
      final digit = '${index + 1}';
      return NumpadKey(
        label: digit,
        onTap: () => _onDigitTap(digit),
        style: NumpadKeyStyle.digit,
      );
    }
    // Row 4, col 1: ⌫ backspace
    if (index == 9) {
      return NumpadKey(
        icon: Icons.backspace_outlined,
        onTap: _amountBuffer.isNotEmpty ? _onBackspace : null,
        style: NumpadKeyStyle.action,
      );
    }
    // Row 4, col 2: 0
    if (index == 10) {
      return NumpadKey(
        label: '0',
        onTap: () => _onDigitTap('0'),
        style: NumpadKeyStyle.digit,
      );
    }
    // Row 4, col 3: ENTER
    return NumpadKey(
      label: AppStrings.enter,
      onTap: _canEnter ? _onEnter : null,
      style: _canEnter ? NumpadKeyStyle.confirm : NumpadKeyStyle.disabled,
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isEmpty = _amountBuffer.isEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.withdraw)),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Amount display card ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      offset: const Offset(0, 4),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'AMOUNT',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecond,
                        letterSpacing: 2.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Divider(
                        height: 1, thickness: 1, color: AppColors.divider),
                    const SizedBox(height: 14),
                    Text(
                      _formattedAmount,
                      style: TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w800,
                        color: isEmpty
                            ? AppColors.textSecond
                            : AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Keypad ────────────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 6,
                    crossAxisSpacing: 6,
                    childAspectRatio: 1 / 0.75,
                  ),
                  itemCount: 12,
                  itemBuilder: (_, index) => _buildKey(index),
                ),
              ),
            ),

            // ── Cancel button ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cancel,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    context.read<TransactionCubit>().reset();
                    context.go('/menu');
                  },
                  child: const Text(
                    AppStrings.cancel,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
