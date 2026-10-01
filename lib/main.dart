import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_navigation_screen.dart';
import 'services/user_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UserService().init();
  runApp(const BloomRoseApp());
}

class BloomRoseApp extends StatelessWidget {
  const BloomRoseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bloom Rose 🌸',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF85A1),
          primary: const Color(0xFFFF85A1),
          secondary: const Color(0xFFFFB3C6),
          tertiary: const Color(0xFFD47A8A),
          surface: const Color(0xFFFFF9FA),
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Color(0xFFFFF9FA),
          foregroundColor: Color(0xFF702632),
          centerTitle: false,
        ),
      ),
      home: const HomeNavigationScreen(),
    );
  }
}

