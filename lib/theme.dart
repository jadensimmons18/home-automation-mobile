import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

/// Colors taken from the mobile design.
class AppColors {
  static const background = Color(0xFF0D0E10);
  static const text = Color(0xFFF2F3F5);
  static const muted = Color(0x99F2F3F5); // 60%
  static const soft = Color(0xB8F2F3F5); // 72%
  static const accent = Color(0xFF8EC5FF);
  static const good = Color(0xFF7EE2B8);
  static const warn = Color(0xFFFFB86B);
  static const live = Color(0xFFFF8A7A);
  static const divider = Color(0x14FFFFFF); // 8%
  static const glassFill = Color(0x0EFFFFFF); // 5.5%
  static const glassBorder = Color(0x1AFFFFFF); // 10%
}

/// Text style helper. [tracking] is letter spacing in em, as in the design.
TextStyle txt(
  double size, {
  FontWeight weight = FontWeight.w400,
  Color color = AppColors.text,
  double tracking = 0,
  double? height,
  List<FontFeature>? features,
}) {
  return GoogleFonts.geist(
    fontSize: size,
    fontWeight: weight,
    color: color,
    letterSpacing: size * tracking,
    height: height,
    fontFeatures: features,
  );
}

const tabularFigures = [FontFeature.tabularFigures()];

ThemeData buildTheme() {
  final base = ThemeData(brightness: Brightness.dark, useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.accent,
      surface: AppColors.background,
    ),
    textTheme: GoogleFonts.geistTextTheme(base.textTheme).apply(
      bodyColor: AppColors.text,
      displayColor: AppColors.text,
    ),
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
  );
}
