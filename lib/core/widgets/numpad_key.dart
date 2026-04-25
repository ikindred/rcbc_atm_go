import 'package:flutter/material.dart';
import 'package:rcbc_atm_go/core/constants/app_colors.dart';

// ─── Key style variants ───────────────────────────────────────────────────────

enum NumpadKeyStyle { digit, action, cancel, confirm, disabled }

// ─── Token maps ───────────────────────────────────────────────────────────────

extension _NumpadKeyStyleX on NumpadKeyStyle {
  Color get backgroundColor => switch (this) {
        NumpadKeyStyle.digit => const Color(0xFFFFFFFF),
        NumpadKeyStyle.action => AppColors.clear,
        NumpadKeyStyle.cancel => AppColors.cancel,
        NumpadKeyStyle.confirm => AppColors.primary,
        NumpadKeyStyle.disabled => const Color(0xFFEEEEEE),
      };

  Color get foregroundColor => switch (this) {
        NumpadKeyStyle.digit => AppColors.textPrimary,
        NumpadKeyStyle.action => Colors.white,
        NumpadKeyStyle.cancel => Colors.white,
        NumpadKeyStyle.confirm => Colors.white,
        NumpadKeyStyle.disabled => const Color(0xFFBBBBBB),
      };

  double get fontSize => switch (this) {
        NumpadKeyStyle.digit => 22,
        _ => 16,
      };

  bool get hasShadow => this == NumpadKeyStyle.digit;
}

// ─── Widget ───────────────────────────────────────────────────────────────────

class NumpadKey extends StatelessWidget {
  const NumpadKey({
    super.key,
    this.label = '',
    this.icon,
    required this.onTap,
    required this.style,
  });

  final String label;

  /// When set, renders an [Icon] instead of the text [label].
  final IconData? icon;

  final VoidCallback? onTap;
  final NumpadKeyStyle style;

  @override
  Widget build(BuildContext context) {
    // Null onTap always forces disabled appearance.
    final effectiveStyle =
        onTap == null ? NumpadKeyStyle.disabled : style;

    final bg = effectiveStyle.backgroundColor;
    final fg = effectiveStyle.foregroundColor;
    final fs = effectiveStyle.fontSize;
    const radius = BorderRadius.all(Radius.circular(16));

    final child = icon != null
        ? Icon(icon, size: 24, color: fg)
        : Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: fs,
              fontWeight: FontWeight.w700,
              letterSpacing: effectiveStyle == NumpadKeyStyle.digit ? 0 : 0.5,
            ),
            textAlign: TextAlign.center,
          );

    return AspectRatio(
      aspectRatio: 1.0,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: radius,
          border: effectiveStyle == NumpadKeyStyle.digit
              ? Border.all(
                  color: const Color(0xFFDDE4EE),
                  width: 1.5,
                )
              : null,
          boxShadow: effectiveStyle.hasShadow
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    offset: const Offset(0, 2),
                    blurRadius: 6,
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: radius,
          child: InkWell(
            onTap: onTap,
            borderRadius: radius,
            splashColor: AppColors.primary.withOpacity(0.15),
            highlightColor: AppColors.primary.withOpacity(0.08),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}
