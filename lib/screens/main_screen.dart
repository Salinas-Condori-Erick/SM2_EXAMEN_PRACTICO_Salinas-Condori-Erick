import 'package:flutter/material.dart';
import 'catalog_screen.dart'; // Ya lo tienes

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const CatalogScreen(), // Solo muestra la pantalla de catálogo
    );
  }
}
