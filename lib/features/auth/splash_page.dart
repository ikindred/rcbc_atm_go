import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rcbc_atm_go/core/constants/app_colors.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        context.go('/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            _LogoWordmark(isWhite: false),
            SizedBox(height: 6),
            Text(
              'RCBC',
              style: TextStyle(
                color: AppColors.textSecond,
                fontSize: 13,
                letterSpacing: 4.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 24),
            CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoWordmark extends StatelessWidget {
  const _LogoWordmark({required this.isWhite});

  final bool isWhite;

  @override
  Widget build(BuildContext context) {
    final logo = Image.asset('assets/images/atm_go_logo.png', height: 64);
    if (!isWhite) {
      return logo;
    }
    return ColorFiltered(
      colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
      child: logo,
    );
  }
}
