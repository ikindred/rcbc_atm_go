import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:rcbc_atm_go/core/constants/app_colors.dart';
import 'package:rcbc_atm_go/features/transaction/presentation/cubits/transaction_state.dart';
import 'package:rcbc_atm_go/features/transaction/presentation/cubits/transaction_cubit.dart';

class EReceiptPage extends StatelessWidget {
  const EReceiptPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<TransactionCubit>().state;
    if (state is! TransactionSuccess) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('E-RECEIPT')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: const [
                    Text(
                      'Send Receipt Notification',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Optional — you may skip this step',
                      style: TextStyle(color: AppColors.textSecond, fontSize: 13),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        prefixText: '+63 ',
                        hintText: 'Mobile number',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Email address',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Receipt sent!')),
                );
                context.go('/receipt', extra: state.transaction);
              },
              child: const Text('SEND'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.go('/receipt', extra: state.transaction),
              child: const Text(
                'SKIP',
                style: TextStyle(color: AppColors.textSecond),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
