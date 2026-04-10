import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class THomeScreen extends StatelessWidget {
  const THomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Olá, Técnico!',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Bem-vindo ao painel de atendimento.',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              _buildCard(
                title: 'Chamados Pendentes',
                value: '5',
                icon: Icons.assignment_outlined,
                color: Colors.orangeAccent,
                context: context,
              ),
              const SizedBox(height: 16),
              _buildCard(
                title: 'Atendimentos Hoje',
                value: '12',
                icon: Icons.check_circle_outline,
                color: Colors.greenAccent,
                context: context,
              ),
              const SizedBox(height: 16),
              _buildCard(
                title: 'Avaliação Média',
                value: '4.8',
                icon: Icons.star_border,
                color: Colors.blueAccent,
                context: context,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required BuildContext context,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outline.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: cs.onSurfaceVariant,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}