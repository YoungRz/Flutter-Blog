import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyBlogApp());
}

class MyBlogApp extends StatelessWidget {
  const MyBlogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Blog',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        // transparan biar gradient dari builder di bawah kelihatan
        scaffoldBackgroundColor: Colors.transparent,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF62C5DC),
          secondary: Color(0xFF97D9E8),
          surface: Colors.white,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF006199),
          elevation: 2,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme).apply(
          bodyColor: Colors.black87,
          displayColor: Colors.black,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          labelStyle: const TextStyle(color: Colors.black54),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Color(0xFF62C5DC), width: 1.5),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF62C5DC),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.black87,
            side: const BorderSide(color: Color(0xFF62C5DC)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: Colors.white,
          selectedColor: const Color(0xFF62C5DC),
          side: const BorderSide(color: Color(0xFF97D9E8)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          labelStyle: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.w500),
          secondaryLabelStyle: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF62C5DC),
          foregroundColor: Colors.white,
        ),
      ),
      // builder ini yang naro gradient background di BELAKANG semua halaman
      builder: (context, child) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF62C5DC),
                Color(0xFF74CCE0),
                Color(0xFF97D9E8),
              ],
            ),
          ),
          child: child,
        );
      },
      home: const HomeScreen(),
    );
  }
}