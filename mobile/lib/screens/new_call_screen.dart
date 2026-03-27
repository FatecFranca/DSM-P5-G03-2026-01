import 'dart:async';
import 'dart:io';

import 'package:classificador/config.dart';
import 'package:flutter/material.dart';
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Descrição é obrigatória!')),
      );
      return;
    }

    final user = _currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Usuário não encontrado.')),
      );
      return;
    }

    if (user.token == null || user.token!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Token de autenticação ausente.')),
      );
      return;
    }

    if (user.unidadeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ ID da unidade não encontrado.')),
      );
      return;
    }

    print('✅ Usuário logado: id=${user.id}, unidadeId=${user.unidadeId}');

    final body = {
      'PessoaId': user.id,
      'UnidadeId': user.unidadeId!, 
      'ChamadoDescricaoInicial': _descricaoController.text.trim(),
    };

    print('📤 Enviando para API: ${jsonEncode(body)}');

    final uri = Uri.parse('${AppConfig.baseUrl}/api/chamado');
    print('🌐 Endpoint: $uri');

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${user.token}', 
        },
          body: jsonEncode(body),
      );

      print('📡 Resposta HTTP: ${response.statusCode}');
      print('📄 Corpo da resposta: ${response.body}');

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Chamado criado com sucesso!'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
        Navigator.pop(context);
      } else {
        final errorMsg =
            jsonDecode(response.body)['message'] ?? 'Erro desconhecido';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Status ${response.statusCode}: $errorMsg')),
        );
      }
    } catch (e, stack) {
      print('💥 Exceção: $e');
      print('Stack trace: $stack');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('💥 Erro: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fontSize = _themeModel.fontSizeScale;

    if (_currentUser == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text('Carregando...', style: GoogleFonts.inter()),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Novo Chamado', style: GoogleFonts.inter())),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Descrição do problema',
              style: GoogleFonts.inter(
                fontSize: 16 * fontSize,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descricaoController,
              maxLines: 6,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: cs.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: cs.primary, width: 2),
                ),
                hintText: 'Descreva o problema com detalhes...',
                filled: true,
                fillColor: cs.surfaceVariant,
              ),
              style: GoogleFonts.inter(
                fontSize: 16 * fontSize,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitCall,
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Criar Chamado',
                  style: GoogleFonts.inter(
                    fontSize: 18 * fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}