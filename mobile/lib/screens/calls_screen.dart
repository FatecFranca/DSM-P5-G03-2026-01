import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../models/call_model.dart';
import '../models/theme_model.dart';
import '../models/user_model.dart';

class CallsScreen extends StatefulWidget {
  const CallsScreen({super.key});

  @override
  State<CallsScreen> createState() => _CallsScreenState();
}

class _CallsScreenState extends State<CallsScreen> {
  UserProfile? _currentUser;
  List<CallModel> _calls = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCalls();
  }

  // CORREÇÃO: Agora o método pode ser chamado pelo RefreshIndicator
  Future<void> _loadCalls() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final themeModel = Provider.of<ThemeModel>(context, listen: false);
      _currentUser = themeModel.currentUser;

      if (_currentUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      final uri = Uri.parse('http://10.232.135.191:3001/api/chamado').replace(
        queryParameters: {
          'pagina': '1',
          'limite': '50',
          'pessoaId': _currentUser!.id.toString(),
          'unidadeId': _currentUser!.unidadeId?.toString() ?? '',
        },
      );

      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer ${_currentUser!.token!}'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data.containsKey('data')) {
          final List<dynamic> chamadosJson = data['data'] as List<dynamic>;
          setState(() {
            _calls = chamadosJson.map((json) => CallModel.fromJson(json)).toList();
          });
        }
      }
    } catch (e) {
      debugPrint('Erro ao carregar chamados: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chamados', style: GoogleFonts.inter())),
      // CORREÇÃO: Adicionado RefreshIndicator para atualização manual
      body: RefreshIndicator(
        onRefresh: _loadCalls,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _calls.isEmpty
                ? ListView( // ListView necessário para o RefreshIndicator funcionar
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                      Center(child: Text('Nenhum chamado encontrado.', style: GoogleFonts.inter())),
                      Center(child: Text('Puxe para atualizar', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey))),
                    ],
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 110), // Padding extra para não cobrir o último card
                    itemCount: _calls.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _buildCallCard(context, _calls[index]);
                    },
                  ),
      ),
    );
  }

  Widget _buildCallCard(BuildContext context, CallModel call) {
    final isEditable = call.status == 'PENDENTE' || call.status == 'FALTAINFORMACAO';
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Chamado #${call.id}', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                _buildStatusChip(call.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(call.descricaoInicial, style: GoogleFonts.inter(fontSize: 15)),
            if (isEditable) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildActionButton('Editar', Icons.edit, Colors.grey[200]!, Colors.black)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildActionButton('Cancelar', Icons.cancel, Colors.red[50]!, Colors.red)),
                ],
              )
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(status, style: TextStyle(fontSize: 12, color: Colors.blue[800])),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color bg, Color fg) {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 14),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: ElevatedButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 0),
      ),
    );
  }
}