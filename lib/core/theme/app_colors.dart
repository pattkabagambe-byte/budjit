import 'package:flutter/material.dart';

class AppColors {
  // Brand
  static const navy = Color(0xFF0F1E3C);
  static const navyLight = Color(0xFF1E3A5F);
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
  static const darkBg = Color(0xFF060F1E);
  static const darkSurface = Color(0xFF0F1E3C);
  static const darkCard = Color(0xFF1A2540);
  static const darkCardAlt = Color(0xFF162035);
  static const darkBorder = Color(0xFF2A3A5C);

  // Light surfaces
  static const lightBg = Color(0xFFF4F6FA);
  static const lightCard = Colors.white;
  static const lightBorder = Color(0xFFE8EDF4);

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
    colors: [navy, Color(0xFF1A3A6E)],
  );

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
