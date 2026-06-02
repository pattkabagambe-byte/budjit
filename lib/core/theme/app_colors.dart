import 'package:flutter/material.dart';

class AppColors {
  // Brand
  static const primary = Color(0xFF7D2935);
  static const primaryLight = Color(0xFFA74754);
  static const primaryDark = Color(0xFF531923);
  static const background = Color(0xFFF8F1E7);
  static const card = Colors.white;
  static const border = Color(0xFFE9DBC9);
  static const muted = Color(0xFF786A61);

  // Legacy aliases kept while feature screens move onto named tokens.
  static const navy = primary;
  static const navyLight = primaryLight;
  static const emerald = Color(0xFF10B981);
  static const emeraldLight = Color(0xFF34D399);
  static const amber = Color(0xFFF59E0B);
  static const rose = Color(0xFFEF4444);
  static const violet = Color(0xFF8B5CF6);
  static const sky = Color(0xFF0EA5E9);
  static const coral = Color(0xFFFF6B6B);
  static const teal = Color(0xFF14B8A6);
  static const orange = Color(0xFFF97316);
  static const pink = Color(0xFFEC4899);

  // Dark surfaces
  static const darkBg = Color(0xFF160F10);
  static const darkSurface = Color(0xFF211617);
  static const darkCard = Color(0xFF2B1D1F);
  static const darkCardAlt = Color(0xFF24191A);
  static const darkBorder = Color(0xFF493538);

  // Light surfaces
  static const lightBg = background;
  static const lightCard = card;
  static const lightBorder = border;

  // Category colors
  static const catFood = Color(0xFFFF6B6B);
  static const catTransport = Color(0xFF4ECDC4);
  static const catHousing = Color(0xFF45B7D1);
  static const catUtilities = Color(0xFF96CEB4);
  static const catEntertainment = Color(0xFFFFAB40);
  static const catHealth = Color(0xFFBA68C8);
  static const catEducation = Color(0xFF4DB6AC);
  static const catShopping = Color(0xFFFF8A65);
  static const catPersonalCare = Color(0xFFF06292);
  static const catSubscriptions = Color(0xFF7986CB);
  static const catMisc = Color(0xFF90A4AE);
  static const catSavings = Color(0xFF10B981);
  static const catDebt = Color(0xFFEF5350);
  static const catAirtime = Color(0xFFFFCA28);
  static const catFuel = Color(0xFF8D6E63);
  static const catSchoolFees = Color(0xFF26A69A);
  static const catGroceries = Color(0xFF66BB6A);

  // Gradient presets
  static const gradientNavy = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDark, primary],
  );

  static const gradientBurgundy = gradientNavy;

  static const gradientEmerald = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF059669), emerald],
  );

  static const gradientViolet = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6D28D9), violet],
  );

  static const gradientAmber = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFD97706), amber],
  );

  static const gradientRose = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFDC2626), rose],
  );

  // ── Tabbed Mode palette ───────────────────────────────────────────────────
  static const tabBg = background;
  static const tabBgDark = darkBg;
  static const tabPrimary = primary;
  static const tabPrimaryLight = primaryLight;
  static const tabCard = card;
  static const tabCardDark = darkCard;
  static const tabBorder = border;
  static const tabBorderDark = darkBorder;
  static const tabMuted = muted;
  static const tabMutedDark = Color(0xFFB9A5A0);
  static const tabDarkSurface = Color(0xFF20191A);

  static Color categoryColor(String category) {
    return switch (category.toLowerCase()) {
      'food' || 'food & dining' => catFood,
      'groceries' => catGroceries,
      'transport' => catTransport,
      'housing' => catHousing,
      'utilitybills' || 'utilities' || 'utility bills' => catUtilities,
      'entertainment' => catEntertainment,
      'healthcare' || 'health' => catHealth,
      'education' => catEducation,
      'shopping' => catShopping,
      'personalcare' || 'personal care' => catPersonalCare,
      'subscriptions' => catSubscriptions,
      'debt' => catDebt,
      'airtime' => catAirtime,
      'fuel' => catFuel,
      'schoolfees' || 'school fees' => catSchoolFees,
      'childcare' => catPersonalCare,
      'salary' || 'income' => catSavings,
      'investments' => violet,
      _ => catMisc,
    };
  }
}
