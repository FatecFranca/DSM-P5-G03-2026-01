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

// Chave global para acessar o estado da CallsScreen e forçar o refresh
final GlobalKey<CallsScreenState> callsScreenKey = GlobalKey<CallsScreenState>();

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
          CallsScreen(key: callsScreenKey), // Passando a chave aqui
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
    return Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(18, 0, 18, 24),
          height: 70,
          decoration: BoxDecoration(
            color: cs.surface.withOpacity(0.8),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildNavItem(0, Icons.grid_view_outlined, Icons.grid_view_rounded, "Início", cs),
                    _buildNavItem(1, Icons.confirmation_number_outlined, Icons.confirmation_number_rounded, "Chamados", cs),
                    const SizedBox(width: 48), // Espaço para o botão central
                    _buildNavItem(2, Icons.notifications_none_rounded, Icons.notifications_rounded, "Avisos", cs),
                    _buildNavItem(3, Icons.person_outline_rounded, Icons.person_rounded, "Perfil", cs),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 42,
          child: _buildAddButton(cs),
        ),
      ],
    );
  }

  Widget _buildAddButton(ColorScheme cs) {
    return GestureDetector(
      onTap: () async {
        HapticFeedback.heavyImpact();
        
        // Espera o usuário terminar de criar o chamado
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NewCallScreen()),
        );

        // Se o usuário estava na aba de chamados, atualiza a lista na hora
        if (callsScreenKey.currentState != null) {
          callsScreenKey.currentState!.loadCalls();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: cs.surface, shape: BoxShape.circle),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [cs.primary, cs.primary.withBlue(220)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: cs.primary.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 6))
            ],
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label, ColorScheme cs) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedIndex = index);
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? cs.primary.withOpacity(0.12) : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                isSelected ? activeIcon : icon,
                color: isSelected ? cs.primary : cs.onSurfaceVariant.withOpacity(0.6),
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isSelected ? 1.0 : 0.0,
              child: Text(
                label,
                style: GoogleFonts.inter(color: cs.primary, fontWeight: FontWeight.bold, fontSize: 10),
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
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
              ),
              const SizedBox(height: 24),
              Text(
                'Tela de $title',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Em breve teremos novidades aqui!',
                style: GoogleFonts.inter(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}