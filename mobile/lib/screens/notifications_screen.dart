import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Lista de exemplo para visualizar o layout
    final List<Map<String, String>> mockNotifications = [
      {'titulo': 'Chamado Atualizado', 'msg': 'O chamado #123 teve o status alterado para EM ATENDIMENTO.', 'hora': '10 min atrás'},
      {'titulo': 'Nova Mensagem', 'msg': 'O técnico enviou uma mensagem no chamado #115.', 'hora': '1 hora atrás'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Notificações', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
      ),
      body: mockNotifications.isEmpty
          ? Center(
              child: Text('Nenhuma notificação por enquanto.', style: GoogleFonts.inter()),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: mockNotifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = mockNotifications[index];
                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: cs.outlineVariant.withOpacity(0.5)),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: cs.primaryContainer,
                      child: Icon(Icons.notifications_active, color: cs.primary, size: 20),
                    ),
                    title: Text(item['titulo']!, style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                    subtitle: Text(item['msg']!, style: GoogleFonts.inter(fontSize: 13)),
                    trailing: Text(item['hora']!, style: GoogleFonts.inter(fontSize: 10, color: Colors.grey)),
                  ),
                );
              },
            ),
    );
  }
}