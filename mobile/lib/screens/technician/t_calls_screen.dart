import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import '../../models/theme_model.dart';
import '../../config.dart';

class TCallsScreen extends StatefulWidget {
  const TCallsScreen({super.key});

  @override
  State<TCallsScreen> createState() => _TCallsScreenState();
}

class _TCallsScreenState extends State<TCallsScreen> {
  bool isLoading = true;
  List<dynamic> chamados = [];

  @override
  void initState() {
    super.initState();
    _fetchChamadosTecnico();
  }

  /// Busca chamados filtrados pelo EquipeId do técnico
  Future<void> _fetchChamadosTecnico() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      final user = Provider.of<ThemeModel>(context, listen: false).currentUser;

      // Validação de segurança: técnico precisa ter equipe vinculada
      if (user == null || user.equipeId == null) {
        debugPrint('⚠️ Técnico ou EquipeId não encontrados no profile');
        setState(() => isLoading = false);
        return;
      }

      // Rota ajustada para usar equipeId como parâmetro de filtro
      final url = Uri.parse('${AppConfig.baseUrl}/api/chamado?equipeId=${user.equipeId}');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer ${user.token}',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> todos = decoded['data'] ?? [];

        // Regra de Negócio: Somente ATRIBUIDO, EMATENDIMENTO ou CONCLUIDO aparecem nesta lista
        setState(() {
          chamados = todos.where((c) {
            final status = c['ChamadoStatus']?.toString().toUpperCase();
            return status == 'ATRIBUIDO' || 
                   status == 'EMATENDIMENTO' || 
                   status == 'CONCLUIDO';
          }).toList();
        });
      } else {
        _showSnackBar('Erro ao carregar dados: ${response.statusCode}', isError: true);
      }
    } catch (e) {
      debugPrint('💥 Erro técnico: $e');
      _showSnackBar('Falha na conexão com o servidor', isError: true);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  /// Registra uma nova atividade (No 1º registro, a API muda status de ATRIBUIDO -> EMATENDIMENTO)
  Future<void> _postAtividade(int chamadoId, String descricao) async {
    try {
      final user = Provider.of<ThemeModel>(context, listen: false).currentUser;
      final url = Uri.parse('${AppConfig.baseUrl}/api/chamado/$chamadoId');

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer ${user?.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"AtividadeDescricao": descricao}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        _showSnackBar('✅ Atividade registrada com sucesso!');
        _fetchChamadosTecnico(); // Refresh automático da lista
      } else {
        _showSnackBar('❌ Erro ao registrar atividade', isError: true);
      }
    } catch (e) {
      _showSnackBar('💥 Erro de conexão', isError: true);
    }
  }

  void _showAtividadeDialog(int chamadoId, String currentStatus) {
    final TextEditingController controller = TextEditingController();
    final isFirst = currentStatus == 'ATRIBUIDO';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isFirst ? "Iniciar Atendimento" : "Nova Atividade"),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: isFirst ? "Descreva o início dos trabalhos..." : "O que foi feito agora?",
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCELAR")),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                _postAtividade(chamadoId, controller.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text("SALVAR"),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.redAccent : Colors.green[700],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Chamados da Equipe", style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchChamadosTecnico,
        child: isLoading 
          ? const Center(child: CircularProgressIndicator())
          : chamados.isEmpty 
            ? _buildEmptyState(cs)
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: chamados.length,
                itemBuilder: (context, index) => _buildTicketCard(chamados[index], cs),
              ),
      ),
    );
  }

  Widget _buildTicketCard(Map<String, dynamic> chamado, ColorScheme cs) {
    final status = chamado['ChamadoStatus']?.toString().toUpperCase() ?? 'PENDENTE';
    final id = chamado['ChamadoId'];
    final titulo = chamado['ChamadoTitulo'] ?? 'Sem Título';
    final descricao = chamado['ChamadoDescricaoInicial'] ?? chamado['ChamadoDescricao'] ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: cs.outline.withOpacity(0.1)),
      ),
      color: cs.surfaceVariant.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("#$id", style: GoogleFonts.firaCode(color: cs.primary, fontWeight: FontWeight.bold)),
                _buildStatusBadge(status, cs),
              ],
            ),
            const SizedBox(height: 16),
            Text(titulo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              descricao,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14),
            ),
            const Divider(height: 32),
            if (status != 'CONCLUIDO')
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () => _showAtividadeDialog(id, status),
                  icon: Icon(status == 'ATRIBUIDO' ? Icons.play_arrow_rounded : Icons.add_comment_rounded),
                  label: Text(status == 'ATRIBUIDO' ? "INICIAR ATIVIDADE" : "RELATAR PROGRESSO"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: cs.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status, ColorScheme cs) {
    Color color = Colors.grey;
    if (status == 'ATRIBUIDO') color = Colors.orange;
    if (status == 'EMATENDIMENTO') color = Colors.blue;
    if (status == 'CONCLUIDO') color = Colors.green;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status, 
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w900),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme cs) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.task_alt_rounded, size: 80, color: cs.primary.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text(
            "Tudo em dia!",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: cs.onSurface),
          ),
          Text(
            "Não há chamados para sua equipe no momento.",
            style: TextStyle(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}