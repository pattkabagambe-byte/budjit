import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const sl = 12.0;
  static const md = 16.0;
  static const lg = 20.0;
  static const xl = 24.0;
  static const xxl = 32.0;
  static const xxxl = 40.0;
  static const screen = 20.0;
}

class AppRadius {
  static const sm = 12.0;
  static const md = 18.0;
  static const lg = 22.0;
  static const xl = 26.0;
  static const sheet = 30.0;
  static const pill = 999.0;
}

class AppShadows {
  static const card = [
    BoxShadow(
      color: Color(0x12241B1D),
      blurRadius: 22,
      offset: Offset(0, 8),
    ),
  ];

  static const hero = [
    BoxShadow(
      color: Color(0x388A2638),
      blurRadius: 28,
      offset: Offset(0, 12),
    ),
  ];

  static const floating = [
    BoxShadow(
      color: Color(0x18241B1D),
      blurRadius: 30,
      offset: Offset(0, 12),
    ),
  ];
}

class AppTypography {
  static final display = GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.8,
    color: AppColors.textPrimary,
  );

  static final title = GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.35,
    color: AppColors.textPrimary,
  );

  static final sectionTitle = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.15,
    color: AppColors.textPrimary,
  );

  static final body = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static final bodyStrong = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static final caption = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.muted,
  );

  static final label = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.25,
    color: AppColors.textSecondary,
  );
}

// Kept for existing screens while the richer typography naming rolls out.
class AppTextStyles {
  static final title = AppTypography.title.copyWith(color: AppColors.primary);
  static final sectionTitle =
      AppTypography.sectionTitle.copyWith(color: AppColors.primary);
  static final body = AppTypography.body;
  static final caption = AppTypography.caption;
}

class AppAnimations {
  static const fast = Duration(milliseconds: 160);
  static const standard = Duration(milliseconds: 240);
  static const relaxed = Duration(milliseconds: 360);
  static const curve = Curves.easeOutCubic;
}

class AppComponents {
  static const buttonHeight = 58.0;
  static const inputMinHeight = 58.0;
  static const tapTarget = 48.0;
  static const iconSize = 22.0;
  static const cardPadding = EdgeInsets.all(AppSpacing.md);
  static const sectionPadding = EdgeInsets.symmetric(
    horizontal: AppSpacing.screen,
    vertical: AppSpacing.md,
  );
}

class AppButtonStyles {
  static final primary = FilledButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.background,
    minimumSize: const Size.fromHeight(AppComponents.buttonHeight),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
    ),
    textStyle: GoogleFonts.inter(
      fontSize: 15,
      fontWeight: FontWeight.w800,
    ),
  );

  static final secondary = OutlinedButton.styleFrom(
    foregroundColor: AppColors.primary,
    backgroundColor: AppColors.selectedSurface,
    minimumSize: const Size.fromHeight(AppComponents.buttonHeight),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    side: BorderSide.none,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
    ),
    textStyle: GoogleFonts.inter(
      fontSize: 15,
      fontWeight: FontWeight.w700,
    ),
  );

  static final ghost = TextButton.styleFrom(
    foregroundColor: AppColors.primary,
    minimumSize: const Size(48, AppComponents.tapTarget),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
    ),
    textStyle: GoogleFonts.inter(
      fontSize: 15,
      fontWeight: FontWeight.w700,
    ),
  );
}
