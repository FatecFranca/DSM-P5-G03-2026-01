import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TCallsScreen extends StatelessWidget {
  const TCallsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final List<Map<String, dynamic>> calls = [
      {'id': '#1001', 'title': 'Vazamento de água', 'status': 'Pendente', 'priority': 'Alta'},
      {'id': '#1002', 'title': 'Iluminação pública', 'status': 'Em andamento', 'priority': 'Média'},
      {'id': '#1003', 'title': 'Coleta de lixo', 'status': 'Concluído', 'priority': 'Baixa'},
    ];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Meus Chamados',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: calls.length,
                  itemBuilder: (context, index) {
                    final call = calls[index];
                    return _buildCallCard(call, context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCallCard(Map<String, dynamic> call, BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final statusColor = call['status'] == 'Pendente'
        ? Colors.orange
        : call['status'] == 'Em andamento'
            ? Colors.blue
            : Colors.green;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                call['id'],
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  color: cs.primary,
                ),
              ),
              Chip(
                label: Text(
                  call['status'],
                  style: GoogleFonts.inter(fontSize: 10),
                ),
                backgroundColor: statusColor.withOpacity(0.15),
                side: BorderSide(color: statusColor, width: 1),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            call['title'],
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.priority_high_outlined, size: 14, color: cs.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(
                call['priority'],
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}