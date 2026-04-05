// lib/core/theme/app_theme.dart
// KriptoPilot — Dark-only theme
// Colors: background #0D1117, card #161B22, green #00D4AA, red #FF4757

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // ─── Brand Palette ────────────────────────────────────────────────────────

  // Backgrounds
  static const Color bgPrimary  = Color(0xFF0D1117); // Scaffold
  static const Color bgCard     = Color(0xFF161B22); // Cards
  static const Color bgSurface  = Color(0xFF21262D); // Elevated surfaces
  static const Color bgBorder   = Color(0xFF30363D); // Borders / dividers

  // Brand
  static const Color colorGreen  = Color(0xFF00D4AA); // Profit, buy, bot ON
  static const Color colorRed    = Color(0xFFFF4757); // Loss, sell, stop loss
  static const Color colorYellow = Color(0xFFF0A500); // Hold, warning
  static const Color colorBlue   = Color(0xFF58A6FF); // Primary actions

  // Text
  static const Color textPrimary   = Color(0xFFE6EDF3);
  static const Color textSecondary = Color(0xFF8B949E);
  static const Color textHint      = Color(0xFF484F58);

  // ─── Gradients ────────────────────────────────────────────────────────────

  static const LinearGradient greenGradient = LinearGradient(
    colors: [Color(0xFF00D4AA), Color(0xFF00A884)],
  );

  static const LinearGradient bgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0D1117), Color(0xFF161B22)],
  );

  // ─── Typography ───────────────────────────────────────────────────────────

  static TextStyle get displayLarge  => GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w700, color: textPrimary,   letterSpacing: -1.0, height: 1.1);
  static TextStyle get displayMedium => GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: textPrimary,   letterSpacing: -0.5, height: 1.15);
  static TextStyle get headlineLarge => GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary,   height: 1.2);
  static TextStyle get headlineMedium=> GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w600, color: textPrimary,   height: 1.3);
  static TextStyle get titleLarge    => GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: textPrimary,   height: 1.35);
  static TextStyle get titleMedium   => GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: textPrimary,   height: 1.4);
  static TextStyle get bodyLarge     => GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w400, color: textPrimary,   height: 1.5);
  static TextStyle get bodyMedium    => GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w400, color: textSecondary, height: 1.5);
  static TextStyle get labelLarge    => GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary,   letterSpacing: 0.2);
  static TextStyle get labelMedium   => GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: textSecondary, letterSpacing: 0.3);
  static TextStyle get labelSmall    => GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: textHint,      letterSpacing: 0.5);
  // Monospace for prices and amounts
  static TextStyle get monoLarge     => GoogleFonts.jetBrainsMono(fontSize: 24, fontWeight: FontWeight.w600, color: textPrimary);
  static TextStyle get monoMedium    => GoogleFonts.jetBrainsMono(fontSize: 14, fontWeight: FontWeight.w400, color: textPrimary);

  // ─── ThemeData ────────────────────────────────────────────────────────────

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgPrimary,

      colorScheme: const ColorScheme.dark(
        primary:                  colorGreen,
        primaryContainer:         Color(0xFF003D2E),
        onPrimary:                bgPrimary,
        secondary:                colorBlue,
        secondaryContainer:       Color(0xFF1A2840),
        onSecondary:              bgPrimary,
        error:                    colorRed,
        onError:                  bgPrimary,
        surface:                  bgCard,
        surfaceContainerHighest:  bgSurface,
        onSurface:                textPrimary,
        onSurfaceVariant:         textSecondary,
        outline:                  bgBorder,
        // ignore: deprecated_member_use
        background:               bgPrimary,
      ),

      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge:   displayLarge,
        displayMedium:  displayMedium,
        headlineLarge:  headlineLarge,
        headlineMedium: headlineMedium,
        titleLarge:     titleLarge,
        titleMedium:    titleMedium,
        bodyLarge:      bodyLarge,
        bodyMedium:     bodyMedium,
        labelLarge:     labelLarge,
        labelMedium:    labelMedium,
        labelSmall:     labelSmall,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: bgPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: headlineLarge,
        iconTheme: const IconThemeData(color: textPrimary),
        surfaceTintColor: Colors.transparent,
      ),

      cardTheme: CardThemeData(
        color: bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: bgBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorGreen,
          foregroundColor: bgPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: labelLarge,
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorGreen,
          foregroundColor: bgPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: labelLarge,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: const BorderSide(color: bgBorder, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: labelLarge,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border:         OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: bgBorder)),
        enabledBorder:  OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: bgBorder)),
        focusedBorder:  OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: colorGreen, width: 1.5)),
        errorBorder:    OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: colorRed, width: 1.5)),
        labelStyle: bodyMedium,
        hintStyle:  labelMedium,
      ),

      dividerTheme: const DividerThemeData(color: bgBorder, thickness: 1, space: 1),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: bgCard,
        indicatorColor: colorGreen.withOpacity(0.15),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: colorGreen);
          }
          return const IconThemeData(color: AppTheme.textHint);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return labelMedium.copyWith(color: colorGreen);
          }
          return labelMedium;
        }),
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: bgSurface,
        contentTextStyle: bodyMedium.copyWith(color: textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: bgBorder),
        ),
        titleTextStyle:   headlineMedium,
        contentTextStyle: bodyMedium,
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: bgCard,
        modalBackgroundColor: bgCard,
        showDragHandle: true,
        dragHandleColor: bgBorder,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return textHint;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return colorGreen;
          return bgBorder;
        }),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: colorGreen,
        linearTrackColor: bgBorder,
        circularTrackColor: bgBorder,
      ),
    );
  }
}
