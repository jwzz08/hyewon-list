import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// hyewon_list pairs a rounded display face (Quicksand, bold only) for
/// headings/big numbers with a warm humanist sans (Nunito) for everything
/// else. See TODO in pubspec.yaml about bundling these as local assets for a
/// fully offline-first build.
abstract final class AppTextStyles {
  // Every default `color` below used to be `= AppColors.xxx` directly, which
  // required `AppColors.xxx` to be a compile-time constant. Now that those
  // tokens are theme-preset-driven getters (see app_colors.dart), default
  // parameter values can no longer reference them directly — Dart requires
  // default values to be const. Nullable-param + `??` inside the body is the
  // standard workaround, and re-evaluates fresh on every call, which is
  // exactly what's needed for live re-theming anyway.
  static TextStyle display({
    double fontSize = 22,
    Color? color,
  }) =>
      GoogleFonts.quicksand(
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        color: color ?? AppColors.textHeading,
      );

  /// A getter (not a one-time-computed field) so it re-evaluates
  /// `AppColors.accent` on every access instead of freezing at whatever the
  /// accent color was the first time this class happened to be touched.
  static TextStyle get wordmark => display(fontSize: 16, color: AppColors.accent);

  static TextStyle eyebrow({Color? color}) => GoogleFonts.nunito(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1,
        color: color ?? AppColors.textFaint,
      );

  static TextStyle sectionLabel({Color? color}) => GoogleFonts.nunito(
        fontSize: 10.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.6,
        color: color ?? AppColors.textFaint,
      );

  static TextStyle body({
    double fontSize = 13,
    FontWeight weight = FontWeight.w600,
    Color? color,
    TextDecoration? decoration,
  }) =>
      GoogleFonts.nunito(
        fontSize: fontSize,
        fontWeight: weight,
        color: color ?? AppColors.textBody,
        decoration: decoration,
      );

  static TextStyle meta({
    double fontSize = 11,
    Color? color,
  }) =>
      GoogleFonts.nunito(
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.textSecondary,
      );

  static TextStyle get clockTime => GoogleFonts.quicksand(
        fontSize: 26,
        fontWeight: FontWeight.w600,
        color: AppColors.textHeading,
      );

  static TextStyle get widgetDate => GoogleFonts.quicksand(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.textHeading,
      );
}
