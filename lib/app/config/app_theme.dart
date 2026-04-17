import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static ThemeData fromSeed(Color seedColor) {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: seedColor),
      textTheme: GoogleFonts.robotoTextTheme(),
    );

    final cs = base.colorScheme;

    return base.copyWith(
      navigationBarTheme: NavigationBarThemeData(
        height: 80,
        indicatorColor: cs.primary.withValues(alpha: 0.15),
        labelTextStyle: WidgetStateProperty.all(
          GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: cs.primary, size: 26);
          }
          return IconThemeData(color: cs.onSurfaceVariant, size: 24);
        }),
      ),
    );
  }

  static ThemeData get light => fromSeed(Colors.greenAccent);
}
