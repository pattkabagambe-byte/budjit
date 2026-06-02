import 'package:flutter/material.dart';

class AppColors {
  // Brand colors sampled from the Budgit wallet icon.
  static const primary = Color(0xFF8A2638);
  static const primaryLight = Color(0xFFB55061);
  static const primaryDark = Color(0xFF611827);
  static const background = Color(0xFFFAF4EA);
  static const card = Color(0xFFFFF9F2);
  static const elevatedSurface = Color(0xFFFDF6EE);
  static const blush = Color(0xFFE9D7D9);
  static const gold = Color(0xFFD7B679);
  static const border = blush;

  // Light-mode copy
  static const textPrimary = Color(0xFF241B1D);
  static const textSecondary = Color(0xFF5D4C51);
  static const muted = Color(0xFF8B767A);
  static const placeholder = Color(0xFFB9A5A9);

  // Semantic feedback
  static const error = Color(0xFFD64D5F);
  static const success = Color(0xFF2E8B57); // SeaGreen - better visibility
  static const warning = Color(0xFFB68642);
  static const info = Color(0xFF7C5C62);

  // Legacy aliases kept while feature screens move onto named tokens.
  static const navy = textPrimary;
  static const navyLight = textSecondary;
  static const emerald = Color(0xFF10B981); // Vibrant Emerald
  static const emeraldLight = Color(0xFF34D399);
  static const amber = warning;
  static const rose = error;
  static const violet = Color(0xFF8A718C);
  static const sky = Color(0xFF718B91);
  static const coral = Color(0xFFC97878);
  static const teal = Color(0xFF5E8A83);
  static const orange = Color(0xFFC78356);
  static const pink = Color(0xFFB96F88);

  // Dark surfaces
  static const darkBg = Color(0xFF181012);
  static const darkSurface = Color(0xFF211719);
  static const darkCard = Color(0xFF2B1D20);
  static const darkCardAlt = Color(0xFF24181B);
  static const darkBorder = Color(0xFF50383E);
  static const darkText = Color(0xFFFAF4EA);
  static const darkMuted = Color(0xFFD0BBC0);

  static Color primarySelected(bool isDark) =>
      isDark ? const Color(0xFFFFB3B9) : primary;

  // Light surfaces
  static const lightBg = background;
  static const lightCard = card;
  static const lightBorder = border;

  static Color get selectedSurface => primary.withValues(alpha: 0.08);

  static Color get subtleShadow => textPrimary.withValues(alpha: 0.07);

  // Category colors
  static const catFood = Color(0xFFC97878);
  static const catTransport = Color(0xFF6E9691);
  static const catHousing = Color(0xFF718B91);
  static const catUtilities = Color(0xFF86A28B);
  static const catEntertainment = Color(0xFFC79761);
  static const catHealth = Color(0xFF9B789B);
  static const catEducation = Color(0xFF668C87);
  static const catShopping = Color(0xFFC78356);
  static const catPersonalCare = Color(0xFFB96F88);
  static const catSubscriptions = Color(0xFF817C9F);
  static const catMisc = Color(0xFF8D8581);
  static const catSavings = success;
  static const catDebt = error;
  static const catAirtime = Color(0xFFC7A44D);
  static const catFuel = Color(0xFF96735F);
  static const catSchoolFees = Color(0xFF668C87);
  static const catGroceries = Color(0xFF6DA368);

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
    colors: [Color(0xFF3E6549), emerald],
  );

  static const gradientViolet = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF69566B), violet],
  );

  static const gradientAmber = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF936B33), amber],
  );

  static const gradientRose = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF943848), rose],
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
  static const tabMutedDark = darkMuted;
  static const tabDarkSurface = darkSurface;

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
