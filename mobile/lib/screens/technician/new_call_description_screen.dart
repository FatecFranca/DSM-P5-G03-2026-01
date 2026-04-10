import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NewCallDescriptionScreen extends StatelessWidget {
  const NewCallDescriptionScreen({super.key});

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
                'Novo Chamado',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Descreva o problema ou serviço solicitado',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Ex: Vazamento na rua das Palmeiras, esquina com a Av. Central...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: cs.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: cs.primary),
                  ),
                  filled: true,
                  fillColor: cs.surface,
                ),
                style: GoogleFonts.inter(color: cs.onSurface),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  // Navegar para próxima tela (ex: confirmação)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Chamado criado!')),
                  );
                },
                icon: const Icon(Icons.check),
                label: const Text('Enviar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}