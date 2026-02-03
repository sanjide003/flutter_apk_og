import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // പ്രധാന നിറങ്ങൾ (Primary Colors)
  static const Color primaryColor = Color(0xFF1565C0); // Institutional Blue
  static const Color secondaryColor = Color(0xFFFFA000); // Amber for highlights
  static const Color backgroundColor = Color(0xFFF5F7FA); // Light Grey Background
  static const Color textDark = Color(0xFF212121);
  static const Color textLight = Color(0xFF757575);
  static const Color white = Colors.white;
  static const Color error = Color(0xFFD32F2F);

  // ലൈറ്റ് തീം (Light Theme Data)
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      
      // ഫോണ്ട് സ്റ്റൈൽ (Font Style - Google Fonts)
      textTheme: GoogleFonts.notoSansTextTheme().copyWith(
        displayLarge: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: textDark),
        displayMedium: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textDark),
        bodyLarge: const TextStyle(fontSize: 16, color: textDark),
        bodyMedium: const TextStyle(fontSize: 14, color: textLight),
      ),

      // ബട്ടൺ സ്റ്റൈൽ (Button Style)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      // കാർഡ് സ്റ്റൈൽ (Card Style)
      cardTheme: CardTheme(
        color: white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      ),

      // ഇൻപുട്ട് ഫീൽഡ് സ്റ്റൈൽ (Input Decoration)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: white,
        elevation: 0,
        centerTitle: false,
      ),
    );
  }
}a
