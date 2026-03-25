import 'dart:ui';
import 'package:classificador/models/theme_model.dart';
import 'package:classificador/screens/calls_screen.dart';
import 'package:classificador/screens/home_screen.dart';
import 'package:classificador/screens/new_call_screen.dart';
import 'package:classificador/screens/notifications_screen.dart';
import 'package:classificador/screens/profile_settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class BottomNavBarScreen extends StatefulWidget {
  const BottomNavBarScreen({super.key});

  @override
  State<BottomNavBarScreen> createState() => _BottomNavBarScreenState();
}

class _BottomNavBarScreenState extends State<BottomNavBarScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          const HomeScreen(),
          const CallsScreen(), // Tela de Chamados (Índice 1)
          const NotificationsScreen(),
          Consumer<ThemeModel>(
            builder: (context, themeModel, child) {
              final user = themeModel.currentUser;
              return user != null 
                ? ProfileSettingsScreen(user: user) 
                : const PlaceholderScreen(title: 'Ajustes', icon: Icons.settings);
            },
          ),
        ],
      ),
      bottomNavigationBar: _buildModernNavBar(cs),
    );
  }

  Widget _buildModernNavBar(ColorScheme cs) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24), 
      height: 72,
      decoration: BoxDecoration(
        color: cs.surface.withOpacity(0.85),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(0, Icons.home_outlined, Icons.home_rounded, "Início", cs),
                _buildNavItem(1, Icons.assignment_outlined, Icons.assignment_rounded, "Chamados", cs),
                
                _buildAddButton(cs), 

                _buildNavItem(2, Icons.notifications_outlined, Icons.notifications_rounded, "Avisos", cs),
                _buildNavItem(3, Icons.settings_outlined, Icons.settings_rounded, "Ajustes", cs),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton(ColorScheme cs) {
    return GestureDetector(
      onTap: () async {
        HapticFeedback.mediumImpact();
        
        // CORREÇÃO: Aguarda o fechamento da tela de Novo Chamado
        await Navigator.push(
          context, 
          MaterialPageRoute(builder: (_) => const NewCallScreen())
        );

        // Ao voltar, força a reconstrução para que as telas filhas atualizem
        setState(() {}); 
      },
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: cs.primary,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: cs.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Icon(Icons.add, color: cs.onPrimary, size: 26),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label, ColorScheme cs) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact(); 
        setState(() => _selectedIndex = index);
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? cs.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? cs.primary : cs.onSurfaceVariant,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.inter(
                color: isSelected ? cs.primary : cs.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;

  const PlaceholderScreen({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Usando SafeArea para evitar que o conteúdo fique sob o notch ou status bar
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon, 
                size: 80, 
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5)
              ),
              const SizedBox(height: 24),
              Text(
                'Tela de $title',
                style: GoogleFonts.inter(
                  fontSize: 20, 
                  fontWeight: FontWeight.bold
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Em breve teremos novidades aqui!',
                style: GoogleFonts.inter(
                  fontSize: 14, 
                  color: Colors.grey
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



