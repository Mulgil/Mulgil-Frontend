import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

extension BuildContextX on BuildContext {
  bool get isTablet => MediaQuery.of(this).size.width > 768;
}

class AppRadius {
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 18;
  static const double xl = 22;
  static const double pill = 999;
}

class AppColors {
  static const navy = Color(0xFF0B2A42);
  static const teal = Color(0xFF00C9D4);
  static const tealDark = Color(0xFF00A6B5);
  static const tealSoft = Color(0xFFE0F7F9);
  static const coral = Color(0xFFFF6B4A);
  static const coralSoft = Color(0xFFFFE7E0);
  static const yellow = Color(0xFFF5C842);
  static const yellowSoft = Color(0xFFFCF1D2);
  static const green = Color(0xFF0F9D58);
  static const greenSoft = Color(0xFFDCF2E5);
  static const lime = Color(0xFFDCEE2F);
  static const limeSoft = Color(0xFFF6FAD6);

  // Neutral scale — cool gray surfaces/borders + ink text ramp.
  static const bg = Color(0xFFF2F3F4);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFF1F7F8);
  static const chip = Color(0xFFF3F5F6);
  static const border = Color(0xFFE6E9EC);

  static const ink = Color(0xFF141A1F);
  static const ink80 = Color(0xFF2E363C);
  static const ink60 = Color(0xFF5E676D);
  static const ink40 = Color(0xFF8C949A);
  static const ink20 = Color(0xFFC8CDD1);

  // Back-compat aliases used across older call sites.
  static const textPrimary = ink;
  static const textSecondary = ink80;
  static const textMuted = ink60;
  static const textLight = ink40;
  static const bgWhite = surface;
  static const bgGray = surfaceAlt;
  static const divider = border;
}

class AppTextStyles {
  static TextStyle get _base => kIsWeb
      ? const TextStyle(color: AppColors.ink)
      : GoogleFonts.notoSansKr(color: AppColors.ink);

  static TextStyle get h1 => _base.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.6,
    height: 1.2,
  );
  static TextStyle get h2 => _base.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.4,
  );
  static TextStyle get h3 => _base.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
  );
  static TextStyle get body => _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.2,
  );
  static TextStyle get bodySmall =>
      _base.copyWith(fontSize: 12, color: AppColors.ink60, letterSpacing: -0.1);
  static TextStyle get caption =>
      _base.copyWith(fontSize: 11, color: AppColors.ink40);
  static TextStyle get label => _base.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
  );

  static TextStyle get logoStyle => GoogleFonts.nunito(
    fontSize: 48,
    fontWeight: FontWeight.w900,
    color: Colors.white,
  );
}

ThemeData buildAppTheme() {
  final textTheme = kIsWeb
      ? ThemeData.light().textTheme
      : GoogleFonts.notoSansKrTextTheme();
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.teal,
      primary: AppColors.navy,
      secondary: AppColors.teal,
      surface: AppColors.surface,
      surfaceContainerHighest: AppColors.surfaceAlt,
    ),
    scaffoldBackgroundColor: AppColors.bg,
    textTheme: textTheme.apply(
      bodyColor: AppColors.ink,
      displayColor: AppColors.ink,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.ink,
      elevation: 0,
      centerTitle: true,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.tealSoft,
      labelTextStyle: WidgetStateProperty.all(
        AppTextStyles.caption.copyWith(fontSize: 10),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.navy,
      unselectedItemColor: AppColors.ink40,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.ink,
      contentTextStyle: AppTextStyles.body.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceAlt,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.teal, width: 1.5),
      ),
      hintStyle: AppTextStyles.body.copyWith(color: AppColors.ink40),
    ),
  );
}
