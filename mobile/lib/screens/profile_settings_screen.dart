import 'package:classificador/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/theme_model.dart';
import '../models/user_model.dart';

class ProfileSettingsScreen extends StatefulWidget {
  final UserProfile user;

  const ProfileSettingsScreen({super.key, required this.user});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  String _getThemeModeLabel() {
    switch (Provider.of<ThemeModel>(context, listen: false).themeMode) {
      case ThemeModeOption.light:
        return 'Claro';
      case ThemeModeOption.dark:
        return 'Escuro';
      default:
        return 'Desconhecido';
    }
  }
  
  String _getRoleLabel() {
    final role = widget.user.role.toUpperCase();
    if (role == 'PESSOA' || role == 'CIDADAO') return 'Cidadão';
    if (role == 'TECNICO') return 'Técnico';
    return 'Usuário';
  }

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);
    final isDark = themeModel.isDark;
    final fontSize = themeModel.fontSizeScale;

    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        title: Text(
          '${_getRoleLabel()}: ${widget.user.name}',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: cs.onSurface,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            tooltip: 'Sair',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar e nome
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                  radius: 48,
                  child: Text(
                    widget.user.name[0].toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.user.name,
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getRoleLabel(),
                        style: TextStyle(
                          color: cs.onSurface.withOpacity(0.7),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Dados do perfil
            _buildInfoTile(
              label: '📧 Email',
              value: widget.user.email,
              icon: Icons.email,
              cs: cs,
              fontSize: fontSize,
            ),
            _buildInfoTile(
              label: '📱 Telefone',
              value: widget.user.phone,
              icon: Icons.phone,
              cs: cs,
              fontSize: fontSize,
            ),
            _buildInfoTile(
              label: widget.user.role.toUpperCase() == 'PESSOA' ? '🆔 CPF' : '🆔 Matrícula',
              value: widget.user.cpfOrId,
              icon: Icons.sd_card,
              cs: cs,
              fontSize: fontSize,
            ),
            _buildInfoTile(
              label: '🏢 Unidade',
              value: widget.user.unitName,
              icon: Icons.business,
              cs: cs,
              fontSize: fontSize,
            ),

            const SizedBox(height: 32),
            Divider(color: cs.onSurface.withOpacity(0.2)),

          // === Seção: Tema ===
          ListTile(
            leading: Icon(
              isDark ? Icons.nightlight_round : Icons.wb_sunny,
              color: cs.primary,
            ),
            title: Text('Tema', style: GoogleFonts.inter()),
            subtitle: Text(
              _getThemeModeLabel(),
              style: TextStyle(color: cs.onSurface.withOpacity(0.7)),
            ),
            trailing: SizedBox(
              width: 120,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      themeModel.themeMode == ThemeModeOption.light
                          ? Icons.circle
                          : Icons.circle_outlined,
                      size: 16,
                      color: cs.onSurface.withOpacity(0.7),
                    ),
                    onPressed: () => themeModel.setThemeMode(ThemeModeOption.light),
                    tooltip: 'Claro',
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: Icon(
                      themeModel.themeMode == ThemeModeOption.dark
                          ? Icons.circle
                          : Icons.circle_outlined,
                      size: 16,
                      color: cs.onSurface.withOpacity(0.7),
                    ),
                    onPressed: () => themeModel.setThemeMode(ThemeModeOption.dark),
                    tooltip: 'Escuro',
                  ),
                ],
              ),
            ),
          ),

            ListTile(
              leading: const Icon(Icons.text_fields, color: Colors.blue),
              title: Text('Tamanho da Fonte', style: GoogleFonts.inter()),
              subtitle: Text(
                fontSize == 1.0
                    ? 'Padrão'
                    : fontSize == 1.2
                        ? 'Grande'
                        : fontSize == 1.4
                            ? 'Extra Grande'
                            : 'Pequeno',
                style: TextStyle(color: cs.onSurface.withOpacity(0.7)),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, size: 18),
                    onPressed: () => themeModel.setFontSize(fontSize > 0.8 ? fontSize - 0.2 : 0.8),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      '${(fontSize * 100).toInt()}%',
                      style: GoogleFonts.inter(fontSize: 14),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, size: 18),
                    onPressed: () => themeModel.setFontSize(fontSize < 1.6 ? fontSize + 0.2 : 1.6),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            Center(
              child: Text(
                'Configurações salvas automaticamente',
                style: TextStyle(
                  color: cs.onSurface.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required String label,
    required String value,
    required IconData icon,
    required ColorScheme cs,
    required double fontSize,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: cs.onSurface.withOpacity(0.7)),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14 * fontSize,
                  fontWeight: FontWeight.w500,
                  color: cs.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 16 * fontSize,
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}