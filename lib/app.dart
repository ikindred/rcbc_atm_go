import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rcbc_atm_go/core/theme/app_theme.dart';
import 'package:rcbc_atm_go/features/auth/login_page.dart';
import 'package:rcbc_atm_go/features/auth/splash_page.dart';
import 'package:rcbc_atm_go/features/transaction/data/models/transaction_model.dart';
import 'package:rcbc_atm_go/features/transaction/menu_page.dart';
import 'package:rcbc_atm_go/features/transaction/receipt_page.dart';
import 'package:rcbc_atm_go/features/transaction/withdrawal_amount_page.dart';
import 'package:rcbc_atm_go/features/transaction/withdrawal_summary_page.dart';

class ATMGoApp extends StatelessWidget {
  const ATMGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/splash',
      routes: [
        GoRoute(
          path: '/splash',
          name: 'splash',
          builder: (context, state) => const SplashPage(),
        ),
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/menu',
          name: 'menu',
          builder: (context, state) => const MenuPage(),
        ),
        GoRoute(
          path: '/withdraw/amount',
          name: 'withdraw-amount',
          builder: (context, state) => const WithdrawalAmountPage(),
        ),
        GoRoute(
          path: '/withdraw/summary',
          name: 'withdraw-summary',
          builder: (context, state) => const WithdrawalSummaryPage(),
        ),
        GoRoute(
          path: '/receipt',
          name: 'receipt',
          builder: (context, state) {
            final tx = state.extra as TransactionModel;
            return ReceiptPage(transaction: tx);
          },
        ),
      ],
    );

    return MaterialApp.router(
      title: 'ATM GO',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
