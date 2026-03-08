// lib/theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const navy    = Color(0xFF0A1628);
  static const navyMid = Color(0xFF0F2044);
  static const navyLt  = Color(0xFF162952);
  static const gold    = Color(0xFFC8A951);
  static const goldLt  = Color(0xFFE8C96A);
  static const red     = Color(0xFFE8394A);
  static const green   = Color(0xFF2ECC8B);
  static const yellow  = Color(0xFFF5A623);
  static const blue    = Color(0xFF4A90D9);
  static const text    = Color(0xFFE8EEF7);
  static const textDim = Color(0xFF7A8BA8);
  static const border  = Color(0xFF1E3560);

  static Color statusColor(String status) => {
    'Online':      green,
    'Offline':     red,
    'Maintenance': yellow,
  }[status] ?? textDim;

  static Color ticketStatusColor(String status) => {
    'open':        blue,
    'in_progress': yellow,
    'resolved':    green,
    'escalated':   red,
  }[status] ?? textDim;
}

ThemeData buildTheme() => ThemeData(
  colorScheme: const ColorScheme.dark(
    primary:   AppColors.gold,
    secondary: AppColors.blue,
    surface:   AppColors.navyMid,
    error:     AppColors.red,
  ),
  scaffoldBackgroundColor: AppColors.navy,
  textTheme: GoogleFonts.syneTextTheme(
    ThemeData.dark().textTheme,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.navyMid,
    elevation: 0,
    titleTextStyle: TextStyle(
      color: AppColors.gold, fontSize: 18, fontWeight: FontWeight.w700,
    ),
    iconTheme: IconThemeData(color: AppColors.text),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: AppColors.navyMid,
    selectedItemColor: AppColors.gold,
    unselectedItemColor: AppColors.textDim,
    type: BottomNavigationBarType.fixed,
  ),
  cardTheme: CardThemeData(
    color: AppColors.navyMid,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: AppColors.border),
    ),
    elevation: 0,
  ),
  dividerColor: AppColors.border,
  useMaterial3: true,
);
