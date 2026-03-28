import 'dart:async';
import 'package:classificador/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/user_model.dart';
import '../models/theme_model.dart';

class NewCallScreen extends StatefulWidget {
  const NewCallScreen({super.key});

  @override
  State<NewCallScreen> createState() => _NewCallScreenState();
}

class _NewCallScreenState extends State<NewCallScreen> {
  final TextEditingController _descricaoController = TextEditingController();
  bool _isSubmitting = false; // Controle de loading interno do botão

  late ThemeModel _themeModel;
  UserProfile? _currentUser;

  @override
  void initState() {
    super.initState();
    _themeModel = Provider.of<ThemeModel>(context, listen: false);
    _currentUser = _themeModel.currentUser;

    if (_currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
      });
    }
  }

  Future<void> _submitCall() async {
    if (_descricaoController.text.trim().isEmpty) {
      _showCustomSnackBar('⚠️ Descreva o problema antes de enviar', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    final user = _currentUser;
    final body = {
      'PessoaId': user!.id,
      'UnidadeId': user.unidadeId!,
      'ChamadoDescricaoInicial': _descricaoController.text.trim(),
    };

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/api/chamado'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${user.token}',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        _showCustomSnackBar('✅ Chamado registrado com sucesso!');
        Navigator.pop(context); // Fecha a tela e aciona o refresh automático que configuramos no NavBar
      } else {
        _showCustomSnackBar('❌ Erro ao salvar: ${response.statusCode}', isError: true);
      }
    } catch (e) {
      _showCustomSnackBar('💥 Falha na conexão com o servidor', isError: true);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showCustomSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        backgroundColor: isError ? Colors.redAccent : Colors.green[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fontSize = _themeModel.fontSizeScale;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text('Abrir Chamado', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header instrutivo
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cs.primary.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: cs.primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Seja específico na descrição para que nossa equipe técnica possa te ajudar mais rápido.',
                      style: GoogleFonts.inter(fontSize: 13, color: cs.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            Text(
              'O QUE ESTÁ ACONTECENDO?',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: cs.primary,
              ),
            ),
            const SizedBox(height: 12),
            
            // Campo de texto estilo "Papel"
            TextField(
              controller: _descricaoController,
              maxLines: 8,
              maxLength: 500,
              style: GoogleFonts.inter(fontSize: 16 * fontSize),
              decoration: InputDecoration(
                hintText: 'Ex: Há um buraco na rua das flores...',
                hintStyle: GoogleFonts.inter(color: Colors.grey[400]),
                filled: true,
                fillColor: cs.surfaceVariant.withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: cs.primary, width: 2),
                ),
                counterStyle: GoogleFonts.inter(fontSize: 12),
              ),
            ),
            
            const SizedBox(height: 40),

            // Botão com estado de carregamento
            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitCall,
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                  elevation: 0,
                  disabledBackgroundColor: cs.primary.withOpacity(0.6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.send_rounded, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            'ENVIAR SOLICITAÇÃO',
                            style: GoogleFonts.inter(
                              fontSize: 15 * fontSize,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Descartar rascunho',
                  style: GoogleFonts.inter(color: Colors.redAccent, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}