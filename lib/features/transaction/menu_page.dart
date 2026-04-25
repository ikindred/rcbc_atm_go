import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rcbc_atm_go/core/constants/app_strings.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final menuItems = <String>[
      AppStrings.withdraw,
      AppStrings.cashIn,
      AppStrings.balanceInquiry,
      AppStrings.fundTransfer,
      AppStrings.billsPayment,
      AppStrings.eLoad,
      AppStrings.pinChange,
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        leading: IconButton(onPressed: () {}, icon: const Icon(Icons.menu)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black12),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('MID: 88000000'),
                  Text('TID: 62000005'),
                  Text('Network: TPLINK_2025'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: menuItems.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = menuItems[index];
                  return ElevatedButton(
                    onPressed: () {
                      if (item == AppStrings.withdraw) {
                        context.go('/withdraw/amount');
                        return;
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Coming soon')),
                      );
                    },
                    child: Text(item),
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
