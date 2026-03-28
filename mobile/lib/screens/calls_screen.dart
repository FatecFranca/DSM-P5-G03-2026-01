import 'dart:convert';
import 'package:classificador/config.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/call_model.dart';
import '../models/theme_model.dart';
import '../models/user_model.dart';

class CallsScreen extends StatefulWidget {
  const CallsScreen({super.key});

  @override
  State<CallsScreen> createState() => CallsScreenState();
}

class CallsScreenState extends State<CallsScreen> {
  UserProfile? _currentUser;
  List<CallModel> _calls = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadCalls();
  }

  // Método público para permitir refresh externo
  Future<void> loadCalls() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final themeModel = Provider.of<ThemeModel>(context, listen: false);
      _currentUser = themeModel.currentUser;

      if (_currentUser == null) return;

      final uri = Uri.parse('${AppConfig.baseUrl}/api/chamado').replace(
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
            _calls = chamadosJson
                .map((json) => CallModel.fromJson(json))
                .toList();
          });
        }
      }
    } catch (e) {
      debugPrint('Erro ao carregar chamados: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _cancelCall(int? callId) async {
    // 1. Verificações de segurança
    if (callId == null || _currentUser == null || _currentUser!.token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Sessão inválida ou ID ausente'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // 2. Diálogo de Confirmação
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar'),
        content: Text('Deseja cancelar o chamado #$callId?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Voltar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Sim, Cancelar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      // 3. Rota PATCH: http://localhost:3001/api/chamado/{id}/status
      final url = Uri.parse('${AppConfig.baseUrl}/api/chamado/$callId/status');

      debugPrint('🚀 Enviando PATCH para: $url');

      final response = await http
          .patch(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${_currentUser!.token}',
            },
            body: jsonEncode({
              'ChamadoStatus':
                  'CANCELADO', // O campo que a sua API validou como obrigatório
            }),
          )
          .timeout(const Duration(seconds: 10));

      debugPrint('📡 Status Code: ${response.statusCode}');
      debugPrint('📄 Resposta: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Chamado #$callId cancelado com sucesso!'),
            backgroundColor: Colors.green[700],
            behavior: SnackBarBehavior.floating,
          ),
        );

        await loadCalls(); // Recarrega a lista para atualizar os status na tela
      } else {
        // Trata o erro 403 ou 400 que a API enviar
        final data = jsonDecode(response.body);
        final msg =
            data['error'] ?? data['message'] ?? 'Erro ${response.statusCode}';

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ $msg'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('💥 Falha de rede: $e'),
          backgroundColor: Colors.orange[900],
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Métodos auxiliares de SnackBar simplificados para evitar erros de referência
  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('❌ $msg'),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ $msg'),
        backgroundColor: Colors.green[700],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Função auxiliar para exibir as notificações (SnackBars)
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
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

    return Scaffold(
      backgroundColor: cs.surfaceVariant.withOpacity(0.2),
      appBar: AppBar(
        title: Text(
          'Meus Chamados',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        onRefresh: loadCalls,
        color: cs.primary,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _calls.isEmpty
            ? _buildEmptyState()
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
                itemCount: _calls.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) =>
                    _buildCallCard(context, _calls[index]),
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
        Icon(Icons.assignment_outlined, size: 70, color: Colors.grey[400]),
        const SizedBox(height: 16),
        Center(
          child: Text(
            'Nenhum chamado ativo',
            style: GoogleFonts.inter(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCallCard(BuildContext context, CallModel call) {
    final cs = Theme.of(context).colorScheme;
    final statusColor = _getStatusColor(call.status);
    final statusUpper = call.status.toUpperCase();
    final isEditable =
        statusUpper == 'PENDENTE' || statusUpper == 'FALTAINFORMACAO';

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(18),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ID #${call.id}',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                        _buildStatusChip(call.status, statusColor),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      call.descricaoInicial,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isEditable) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildBtn(
                              'Editar',
                              Icons.edit_outlined,
                              cs.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Expanded(
                          //   child: GestureDetector(
                          //     onTap: () => _cancelCall(
                          //       call.id!,
                          //     ), // Chama a função passando o ID
                          //     child: _buildBtn(
                          //       'Cancelar',
                          //       Icons.close,
                          //       Colors.red[700]!,
                          //     ),
                          //   ),
                          // ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                // ESTE É O DEBUG QUE PRECISAMOS VER:
                                debugPrint('--- DADOS PARA CONFERÊNCIA ---');
                                debugPrint(
                                  'ID do Chamado Selecionado: ${call.id}',
                                );
                                debugPrint(
                                  'Status Atual do Chamado: ${call.status}',
                                );
                                debugPrint(
                                  'ID do Dono do Chamado: ${call.pessoaId}',
                                );
                                debugPrint(
                                  'ID do Usuário Logado: ${_currentUser?.id}',
                                );
                                debugPrint('-----------------------------');

                                _cancelCall(call.id);
                              },
                              child: _buildBtn(
                                'Cancelar',
                                Icons.close,
                                Colors.red[700]!,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildBtn(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDENTE':
        return Colors.orange[800]!;
      case 'CONCLUIDO':
        return Colors.green[700]!;
      case 'CANCELADO':
        return Colors.red[700]!;
      default:
        return Colors.blue[700]!;
    }
  }
}
