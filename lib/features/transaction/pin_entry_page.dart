import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:rcbc_atm_go/core/constants/app_colors.dart';
import 'package:rcbc_atm_go/core/constants/app_strings.dart';
import 'package:rcbc_atm_go/core/widgets/numpad_key.dart';
import 'package:rcbc_atm_go/features/transaction/presentation/cubits/transaction_cubit.dart';
import 'package:rcbc_atm_go/features/transaction/presentation/cubits/transaction_state.dart';

class PinEntryPage extends StatefulWidget {
  const PinEntryPage({super.key});

  @override
  State<PinEntryPage> createState() => _PinEntryPageState();
}

class _PinEntryPageState extends State<PinEntryPage> {
  late final List<int> _digits;
  String _pin = '';

  @override
  void initState() {
    super.initState();
    _digits = List<int>.generate(10, (i) => i)..shuffle(Random());
  }

  // ── Derived state ────────────────────────────────────────────────────────────

  bool get _canEnter => _pin.length == 4;

  // ── Handlers ─────────────────────────────────────────────────────────────────

  void _appendDigit(String digit) {
    if (_pin.length >= 4) return;
    setState(() => _pin += digit);
  }

  void _onBackspace() => setState(
        () => _pin = _pin.isNotEmpty ? _pin.substring(0, _pin.length - 1) : '',
      );

  void _onEnter() {
    context.read<TransactionCubit>().enterPin(_pin);
    context.go('/withdraw/processing');
  }

  // ── PIN dot indicator ─────────────────────────────────────────────────────────

  Widget _buildDot(int index) {
    final filled = index < _pin.length;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? AppColors.primary : Colors.transparent,
        border: Border.all(color: AppColors.primary, width: 2),
      ),
    );
  }

  // ── Grid item builder ─────────────────────────────────────────────────────────

  Widget _buildKey(int index) {
    // Positions 0-8: shuffled digits [0]-[8]
    if (index <= 8) {
      final digit = _digits[index].toString();
      return NumpadKey(
        label: digit,
        onTap: () => _appendDigit(digit),
        style: NumpadKeyStyle.digit,
      );
    }
    // Position 9: ⌫ backspace
    if (index == 9) {
      return NumpadKey(
        icon: Icons.backspace_outlined,
        onTap: _pin.isNotEmpty ? _onBackspace : null,
        style: NumpadKeyStyle.action,
      );
    }
    // Position 10: shuffled digit [9]
    if (index == 10) {
      final digit = _digits[9].toString();
      return NumpadKey(
        label: digit,
        onTap: () => _appendDigit(digit),
        style: NumpadKeyStyle.digit,
      );
    }
    // Position 11: ENTER
    return NumpadKey(
      label: AppStrings.enter,
      onTap: _canEnter ? _onEnter : null,
      style: _canEnter ? NumpadKeyStyle.confirm : NumpadKeyStyle.disabled,
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = context.watch<TransactionCubit>().state;
    if (state is! TransactionCardInserted && state is! TransactionPinEntered) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('ENTER ONLINE PIN')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── PIN indicator ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Column(
              children: [
                const Text(
                  'Enter your 4-digit PIN',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecond),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (i) {
                    return Padding(
                      padding: EdgeInsets.only(left: i == 0 ? 0 : 16),
                      child: _buildDot(i),
                    );
                  }),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // ── Keypad ───────────────────────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1 / 1.15,
                ),
                itemCount: 12,
                itemBuilder: (_, index) => _buildKey(index),
              ),
            ),
          ),

          // ── Cancel button ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: SizedBox(
              width: double.infinity,
              height: 52,
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
        ],
      ),
    );
  }
}
