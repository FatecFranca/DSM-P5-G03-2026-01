import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Página Inicial', style: GoogleFonts.inter())),
      body: const Center(child: Text('Bem-vindo à página inicial!')),
    );
  }
}