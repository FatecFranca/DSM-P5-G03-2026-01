import 'dart:async';
import 'package:classificador/screens/technician/new_call_description_screen.dart';
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
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    // Garante que a busca só comece após a tela estar montada
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint("🏁 Interface pronta. Iniciando processos...");
      _fetchChamadosTecnico();
      _startAutoRefresh();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    debugPrint("🛑 Timer de atualização cancelado.");
    super.dispose();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _fetchChamadosTecnico(isAutoRefresh: true);
    });
  }

  Future<void> _fetchChamadosTecnico({bool isAutoRefresh = false}) async {
    if (!mounted) return;

    try {
      final user = Provider.of<ThemeModel>(context, listen: false).currentUser;
      final url = Uri.parse('${AppConfig.baseUrl}/api/chamado');

      if (!isAutoRefresh) setState(() => isLoading = true);

      final response = await http
          .get(
            url,
            headers: {
              'Authorization': 'Bearer ${user?.token}',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> todos = (decoded is List)
            ? decoded
            : (decoded['data'] ?? []);

        if (mounted) {
          setState(() {
            // REGRA: Apenas chamados em andamento ou atribuídos aparecem.
            // Pendentes (fila geral) e Cancelados são ignorados.
            chamados = todos.where((c) {
              final status = c['ChamadoStatus']?.toString().toUpperCase();

              // O técnico só vê o que já está sob responsabilidade dele/equipe
              return status == 'ATRIBUIDO' || status == 'EMATENDIMENTO';
            }).toList();

            isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('💥 Erro no filtro técnico: $e');
      if (mounted) setState(() => isLoading = false);
    }
  }

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
        _showSnackBar('✅ Atividade registrada!');
        _fetchChamadosTecnico();
      }
    } catch (e) {
      _showSnackBar('💥 Erro de conexão ao salvar', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    debugPrint("🎨 Renderizando lista com ${chamados.length} chamados.");

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Chamados da Equipe",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          const Icon(Icons.sync, size: 14, color: Colors.blueGrey),
          const SizedBox(width: 16),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _fetchChamadosTecnico(),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : chamados.isEmpty
            ? _buildEmptyState(cs)
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: chamados.length,
                itemBuilder: (context, index) =>
                    _buildTicketCard(chamados[index], cs),
              ),
      ),
    );
  }

  Widget _buildTicketCard(Map<String, dynamic> chamado, ColorScheme cs) {
    final status =
        chamado['ChamadoStatus']?.toString().toUpperCase() ?? 'PENDENTE';
    final id = chamado['ChamadoId'];
    // Verificamos se o título é nulo e usamos a descrição inicial como alternativa
    final titulo = chamado['ChamadoTitulo'] ?? "Chamado #$id";
    final descricao =
        chamado['ChamadoDescricaoInicial'] ?? "Sem descrição disponível";

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
                Text(
                  "#$id",
                  style: GoogleFonts.firaCode(
                    color: cs.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildStatusBadge(status, cs),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              titulo,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              descricao,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14),
            ),
            const Divider(height: 32),
            // Botão só aparece se não estiver cancelado ou concluído
            if (status != 'CONCLUIDO' && status != 'CANCELADO')
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () async {
  // Navega para a tela de nova atividade e aguarda o retorno
                    final resultado = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NewCallDescriptionScreen(chamadoId: id),
                      ),
                    );

                    // Se a tela retornar 'true', atualizamos a lista de chamados
                    if (resultado == true) {
                      _fetchChamadosTecnico();
                    }
                  },
                  icon: const Icon(Icons.edit_note),
                  label: const Text("ATUALIZAR CHAMADO"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: cs.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showAtividadeDialog(int chamadoId, String currentStatus) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Registrar Atividade"),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: "O que foi realizado?",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCELAR"),
          ),
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

  Widget _buildStatusBadge(String status, ColorScheme cs) {
    Color color = Colors.grey;
    if (status == 'ATRIBUIDO') color = Colors.orange;
    if (status == 'EMATENDIMENTO') color = Colors.blue;
    if (status == 'CONCLUIDO') color = Colors.green;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme cs) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 60,
            color: cs.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          const Text("Nenhum chamado pendente para sua equipe."),
        ],
      ),
    );
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
      ),
    );
  }
}
