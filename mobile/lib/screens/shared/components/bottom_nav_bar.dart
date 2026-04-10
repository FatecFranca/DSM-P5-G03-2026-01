import 'dart:ui';

import 'package:classificador/models/theme_model.dart';
import 'package:classificador/models/user_type.dart';
import 'package:classificador/screens/citizen/c_calls_screen.dart';
import 'package:classificador/screens/citizen/c_home_screen.dart';
import 'package:classificador/screens/citizen/manual_screen.dart';
import 'package:classificador/screens/citizen/new_call_screen.dart';
import 'package:classificador/screens/shared/profile_settings_screen.dart';
import 'package:classificador/screens/technician/t_calls_screen.dart';
import 'package:classificador/screens/technician/t_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class BottomNavBarScreen extends StatefulWidget {
  final UserType? userType;

  const BottomNavBarScreen({super.key, this.userType});

  @override
  State<BottomNavBarScreen> createState() => _BottomNavBarScreenState();
}

class _BottomNavBarScreenState extends State<BottomNavBarScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);
    final userType = widget.userType ?? themeModel.userType;
    final cs = Theme.of(context).colorScheme;

    final List<Widget> children;
    final List<_NavItemConfig> navItems;

    switch (userType) {
      case UserType.citizen:
        children = [
          const HomeScreen(),
          const CallsScreen(),
          const ManualScreen(),
          Consumer<ThemeModel>(
            builder: (context, themeModel, child) {
              final user = themeModel.currentUser;
              return user != null
                  ? ProfileSettingsScreen(user: user)
                  : const PlaceholderScreen(
                      title: 'Ajustes',
                      icon: Icons.settings,
                    );
            },
          ),
        ];
        navItems = [
          _NavItemConfig(0, Icons.grid_view_outlined, Icons.grid_view_rounded, "Início"),
          _NavItemConfig(1, Icons.confirmation_number_outlined, Icons.confirmation_number_rounded, "Chamados"),
          _NavItemConfig(2, Icons.help_center_outlined, Icons.help_center_rounded, "Manual"),
          _NavItemConfig(3, Icons.person_outline_rounded, Icons.person_rounded, "Perfil"),
        ];

      case UserType.technician:
        children = [
          const THomeScreen(),
          const TCallsScreen(),
          Consumer<ThemeModel>(
            builder: (context, themeModel, child) {
              final user = themeModel.currentUser;
              return user != null
                  ? ProfileSettingsScreen(user: user)
                  : const PlaceholderScreen(
                      title: 'Ajustes',
                      icon: Icons.settings,
                    );
            },
          ),
        ];
        navItems = [
          _NavItemConfig(0, Icons.home_outlined, Icons.home_rounded, "Início"),
          _NavItemConfig(1, Icons.list_alt_outlined, Icons.list_alt_rounded, "Chamados"),
          _NavItemConfig(3, Icons.person_outline_rounded, Icons.person_rounded, "Perfil"),
        ];

      }

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _selectedIndex,
        children: children,
      ),
      bottomNavigationBar: _buildModernNavBar(cs, navItems),
    );
  }

  Widget _buildModernNavBar(ColorScheme cs, List<_NavItemConfig> navItems) {
    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(18, 0, 18, 24),
            height: 70,
            decoration: BoxDecoration(
              color: cs.surface.withOpacity(0.8),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ...navItems.asMap().entries.map((e) {
                        final index = e.key;
                        final config = e.value;
                        return _buildNavItem(
                          index,
                          config.icon,
                          config.activeIcon,
                          config.label,
                          cs,
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (widget.userType == UserType.citizen ||
              (widget.userType == null && Provider.of<ThemeModel>(context).userType == UserType.citizen))
            Positioned(
              bottom: 45,
              child: _buildAddButton(cs),
            ),
        ],
      ),
    );
  }

  Widget _buildAddButton(ColorScheme cs) {
    return GestureDetector(
      onTap: () async {
        HapticFeedback.heavyImpact();
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NewCallScreen()),
        );
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: cs.surface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: cs.primary.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [cs.primary, cs.primary.withBlue(255)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
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
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
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
                style: GoogleFonts.inter(
                  color: cs.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItemConfig {
  final int index;
  final IconData icon;
  final IconData activeIcon;
  final String label;

  _NavItemConfig(this.index, this.icon, this.activeIcon, this.label);
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;

  const PlaceholderScreen({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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