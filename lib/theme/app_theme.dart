import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

extension BuildContextX on BuildContext {
  bool get isTablet => MediaQuery.of(this).size.width > 768;
}

class AppColors {
  static const navy = Color(0xFF0B2A42);
  static const teal = Color(0xFF00C9D4);
  static const tealDark = Color(0xFF00A6B5);
  static const cream = Color(0xFFF5F0E8);
  static const creamDark = Color(0xFFE6DDCF);
  static const coral = Color(0xFFFF6B4A);
  static const yellow = Color(0xFFF5C842);
  static const green = Color(0xFF0F9D58);
  static const lime = Color(0xFFDCEE2F);

  static const textPrimary = Color(0xFF17202B);
  static const textSecondary = Color(0xFF3D4954);
  static const textMuted = Color(0xFF6B7785);
  static const textLight = Color(0xFF9AA5AE);

  static const bgWhite = Color(0xFFFFFFFF);
  static const bgCream = Color(0xFFF5F0E8);
  static const bgGray = Color(0xFFF7F7F7);
  static const bgDark = Color(0xFF1C1C1C);

  static const divider = Color(0xFFEEEEEE);
  static const border = Color(0xFFEEF0F2);
}

class AppTextStyles {
  static TextStyle get _base => GoogleFonts.notoSansKr(color: AppColors.textPrimary);

  static TextStyle get h1 => _base.copyWith(fontSize: 22, fontWeight: FontWeight.w800);
  static TextStyle get h2 => _base.copyWith(fontSize: 18, fontWeight: FontWeight.w800);
  static TextStyle get h3 => _base.copyWith(fontSize: 16, fontWeight: FontWeight.w700);
  static TextStyle get body => _base.copyWith(fontSize: 14, fontWeight: FontWeight.w400);
  static TextStyle get bodySmall => _base.copyWith(fontSize: 12, color: AppColors.textMuted);
  static TextStyle get caption => _base.copyWith(fontSize: 11, color: AppColors.textLight);
  static TextStyle get label => _base.copyWith(fontSize: 13, fontWeight: FontWeight.w700);

  static TextStyle get logoStyle => GoogleFonts.nunito(
    fontSize: 48,
    fontWeight: FontWeight.w900,
    color: Colors.white,
  );
}

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.teal,
      primary: AppColors.navy,
      secondary: AppColors.teal,
      surface: AppColors.bgWhite,
      surfaceContainerHighest: AppColors.bgCream,
    ),
    scaffoldBackgroundColor: AppColors.bgCream,
    textTheme: GoogleFonts.notoSansKrTextTheme().apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: true,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: AppColors.navy.withValues(alpha: 0.08),
      labelTextStyle: WidgetStateProperty.all(
        AppTextStyles.caption.copyWith(fontSize: 10),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.navy,
      unselectedItemColor: AppColors.textLight,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.divider, width: 0.5),
      ),
    ),
  );
}
