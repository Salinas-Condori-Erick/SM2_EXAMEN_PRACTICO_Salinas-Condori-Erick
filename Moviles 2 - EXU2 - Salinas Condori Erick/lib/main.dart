import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/catalog_screen.dart';
import 'screens/main_screen.dart';
import 'screens/register_screen.dart';
import 'screens/AdminDashboardScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Necesario antes de inicializar Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyApp',
      initialRoute: '/',
      routes: {
        //'/': (ctx) => const AdminDashboardScreen(),
        '/': (ctx) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (ctx) => const MainScreen(),
        '/catalog': (ctx) => CatalogScreen(),
      },
    );
  }
}
