import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:rcbc_atm_go/core/constants/app_colors.dart';
import 'package:rcbc_atm_go/features/transaction/presentation/cubits/transaction_cubit.dart';
import 'package:rcbc_atm_go/features/transaction/presentation/cubits/transaction_state.dart';

class CardEntryPage extends StatefulWidget {
  const CardEntryPage({super.key});

  @override
  State<CardEntryPage> createState() => _CardEntryPageState();
}

class _CardEntryPageState extends State<CardEntryPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _scaleAnimation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<TransactionCubit>().state;
    final amount = state is TransactionAmountEntered ? state.amount : 0.0;

    return BlocListener<TransactionCubit, TransactionState>(
      listener: (context, cubitState) {
        if (cubitState is TransactionCardInserted) {
          setState(() => _isLoading = false);
          context.go('/withdraw/card-confirm');
        } else if (cubitState is TransactionError) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(cubitState.message)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('WITHDRAW'),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(32),
            child: Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text(
                'CARD ENTRY',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Spacer(),
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 172,
                      height: 172,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withValues(alpha: 0.10),
                      ),
                      child: const Icon(
                        Icons.credit_card,
                        size: 96,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'PLEASE INSERT CARD',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Insert your ATM card into the card reader',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: AppColors.textSecond),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            setState(() => _isLoading = true);
                            context.read<TransactionCubit>().simulateCardInsert(amount);
                          },
                    child: const Text('SIMULATE CARD INSERT'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _isLoading ? null : () => context.pop(),
                    child: const Text(
                      'BACK',
                      style: TextStyle(
                        color: AppColors.cancel,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_isLoading)
              Container(
                color: Colors.black26,
                alignment: Alignment.center,
                child: const CircularProgressIndicator(color: AppColors.primary),
              ),
          ],
        ),
      ),
    );
  }
}
