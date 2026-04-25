import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rcbc_atm_go/core/constants/app_colors.dart';
import 'package:rcbc_atm_go/core/constants/app_strings.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final menuItems = <_MenuItem>[
      const _MenuItem(AppStrings.withdraw, Icons.payments_outlined),
      const _MenuItem(AppStrings.cashIn, Icons.account_balance_wallet_outlined),
      const _MenuItem(AppStrings.balanceInquiry, Icons.account_balance_outlined),
      const _MenuItem(AppStrings.fundTransfer, Icons.swap_horiz),
      const _MenuItem(AppStrings.billsPayment, Icons.receipt_long_outlined),
      const _MenuItem(AppStrings.eLoad, Icons.sim_card_outlined),
      const _MenuItem(AppStrings.pinChange, Icons.lock_reset_outlined),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        actions: [
          IconButton(
            onPressed: () => context.go('/login'),
            icon: const Icon(Icons.logout_outlined),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: const [
                    Expanded(
                      child: Text(
                        'MID: 88000000 | TID: 62000005 | Network: TPLINK_2025',
                        style: TextStyle(
                          color: AppColors.textSecond,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                itemCount: menuItems.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2,
                ),
                itemBuilder: (context, index) {
                  final item = menuItems[index];
                  return InkWell(
                    onTap: () {
                      if (item.label == AppStrings.withdraw) {
                        context.go('/withdraw/amount');
                        return;
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Coming soon')),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Card(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x14000000),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(item.icon, size: 32, color: AppColors.primary),
                            const SizedBox(height: 10),
                            Text(
                              item.label,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem {
  const _MenuItem(this.label, this.icon);

  final String label;
  final IconData icon;
}
