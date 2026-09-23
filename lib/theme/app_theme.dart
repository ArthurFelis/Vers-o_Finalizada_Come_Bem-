import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Paleta de cores oficial do Coma Bem.
/// Tudo no app deve referenciar essas constantes em vez de usar
/// Colors.orange / Color.fromARGB(...) espalhados pelas telas,
/// para manter a identidade visual consistente.
class AppColors {
  AppColors._();

  // Tons principais de vinho
  static const Color vinho = Color(0xFF6E1423);
  static const Color vinhoEscuro = Color(0xFF3D0B12);
  static const Color vinhoClaro = Color(0xFF8C2F3F);

  // Dourado usado como destaque (detalhes, ícones, bordas de foco)
  static const Color dourado = Color(0xFFC9A227);
  static const Color douradoClaro = Color(0xFFE4C766);

  // Neutros
  static const Color creme = Color(0xFFFAF3EE);
  static const Color creme2 = Color(0xFFF3E7DE);
  static const Color textoPrincipal = Color(0xFF2B1210);
  static const Color textoSecundario = Color(0xFF7A6560);
  static const Color sucesso = Color(0xFF3E7A4B);
  static const Color erro = Color(0xFFB3261E);
}

class AppTheme {
  AppTheme._();

  static ThemeData get tema {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.vinho,
        primary: AppColors.vinho,
        secondary: AppColors.dourado,
        surface: AppColors.creme,
        error: AppColors.erro,
      ),
      scaffoldBackgroundColor: AppColors.creme,
      // Tipografia: Nunito para textos comuns (letra arredondada e "gordinha",
      // bem amigável e fácil de ler) + Fraunces para títulos (uma serifada
      // encorpada/soft, que dá aquele ar elegante/boutique sem perder o
      // acolhimento). As duas vêm via google_fonts, então não precisam de
      // arquivos .ttf manuais no pubspec.
    );

    final tituloFraunces = GoogleFonts.fraunces(
      fontWeight: FontWeight.w700,
      letterSpacing: 0.2,
    );

    return base.copyWith(
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.vinho,
        foregroundColor: Colors.white,
        titleTextStyle: tituloFraunces.copyWith(
          color: Colors.white,
          fontSize: 21,
          fontWeight: FontWeight.w700,
        ),
      ),
      textTheme: GoogleFonts.nunitoTextTheme(base.textTheme)
          .copyWith(
            displayLarge: tituloFraunces.copyWith(fontSize: 40, fontWeight: FontWeight.w800),
            displayMedium: tituloFraunces.copyWith(fontSize: 32, fontWeight: FontWeight.w800),
            displaySmall: tituloFraunces.copyWith(fontSize: 28, fontWeight: FontWeight.w700),
            headlineLarge: tituloFraunces.copyWith(fontSize: 26, fontWeight: FontWeight.w700),
            headlineMedium: tituloFraunces.copyWith(fontSize: 24, fontWeight: FontWeight.w700),
            headlineSmall: tituloFraunces.copyWith(fontSize: 20, fontWeight: FontWeight.w700),
            titleLarge: tituloFraunces.copyWith(fontSize: 18, fontWeight: FontWeight.w700),
          )
          .apply(
            bodyColor: AppColors.textoPrincipal,
            displayColor: AppColors.textoPrincipal,
          ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.vinho,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.vinho.withValues(alpha: 0.5),
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.vinho,
          textStyle: GoogleFonts.nunito(fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: const TextStyle(color: AppColors.textoSecundario),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.creme2, width: 1.4),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.creme2, width: 1.4),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.vinho, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.erro, width: 1.4),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: AppColors.creme2, width: 1),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.vinho,
        foregroundColor: Colors.white,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
