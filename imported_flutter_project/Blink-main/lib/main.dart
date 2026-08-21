import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // 1. Import dotenv

import 'config/theme.dart';
import 'splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Load the environment variables before using them
  await dotenv.load(fileName: ".env");

  // 3. Pass the environment variables to Supabase
  final isLocal = const bool.fromEnvironment('LOCAL_HOST', defaultValue: false);
  final supabaseUrl = isLocal 
      ? (dotenv.env['SUPABASE_URL_LOCAL'] ?? 'http://localhost:54321')
      : (dotenv.env['SUPABASE_URL'] ?? dotenv.env['EXPO_PUBLIC_SUPABASE_URL'])?.trim();
  
  final supabaseAnonKey = (dotenv.env['SUPABASE_ANON_KEY'] ?? dotenv.env['EXPO_PUBLIC_SUPABASE_ANON_KEY'])?.trim();

  debugPrint('Running as localhost: $isLocal');
  debugPrint('Supabase URL loaded: $supabaseUrl');
  debugPrint('Supabase anon key loaded: ${supabaseAnonKey != null && supabaseAnonKey.isNotEmpty}');

  if (supabaseUrl == null || supabaseAnonKey == null || supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    throw FlutterError(
      'Missing or empty Supabase environment variables. Ensure .env contains SUPABASE_URL/SUPABASE_ANON_KEY or EXPO_PUBLIC_SUPABASE_URL/EXPO_PUBLIC_SUPABASE_ANON_KEY.',
    );
  }

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(const BlinkApp());
}

class BlinkApp extends StatelessWidget {
  const BlinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blink',
      debugShowCheckedModeBanner: false,
      theme: blinkTheme,
      home: const SplashScreen(),
    );
  }
}