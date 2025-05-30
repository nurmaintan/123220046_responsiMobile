import 'package:flutter/material.dart';
import 'package:responsi_046/screens/login_screen.dart';
import 'package:responsi_046/screens/register_screen.dart';
import 'package:responsi_046/screens/movies_screen.dart';
import 'package:responsi_046/screens/favorites_screen.dart';
import 'package:responsi_046/services/shared_pref_manager.dart';
import 'package:responsi_046/services/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.database;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/movies': (context) => const MoviesScreen(),
        '/favorites': (context) => const FavoritesScreen(),
      },
    );
  }
}
