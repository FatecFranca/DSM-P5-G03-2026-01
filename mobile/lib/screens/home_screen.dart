import 'package:classificador/screens/calls_screen.dart';
import 'package:classificador/screens/new_call_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/theme_model.dart';
import '../config.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int pendentes = 0;
  int finalizados = 0;
  int emAtendimento = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Inicia a busca assim que a tela abre
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchDashboardData());
  }

  Future<void> _fetchDashboardData() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      final user = Provider.of<ThemeModel>(context, listen: false).currentUser;
      if (user == null || user.token == null) {
        setState(() => isLoading = false);
        return;
      }

      final url = Uri.parse('${AppConfig.baseUrl}/api/chamado');

      final response = await http
          .get(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${user.token}',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = jsonDecode(response.body);
        final List<dynamic> listaChamados = decodedData['data'] ?? [];

        int countP = 0;
        int countF = 0;
        int countA = 0;

        for (var item in listaChamados) {
          // Captura o status real do JSON: 'ChamadoStatus'
          String status = (item['ChamadoStatus'] ?? '')
              .toString()
              .toUpperCase()
              .trim();

          // Captura o ID do dono: 'PessoaId'
          final int donoId = item['PessoaId'] ?? 0;

          // Filtra apenas os chamados do usuário logado
          if (donoId == user.id) {
            if (status == 'PENDENTE') {
              countP++;
            }
            // Removemos o 'CANCELADO' daqui para ele não ser contado como finalizado
            else if (status == 'FINALIZADO' || status == 'CONCLUIDO') {
              countF++;
            } else if (status == 'EMATENDIMENTO' ||
                status == 'EM ATENDIMENTO') {
              countA++;
            }

            // Opcional: Se você quiser contar cancelados em uma variável separada no futuro,
            // basta adicionar um: else if (status == 'CANCELADO') { countC++; }
          }
        }

        debugPrint('📈 SUCESSO -> Pendentes: $countP | Finalizados: $countF');

        if (mounted) {
          setState(() {
            pendentes = countP;
            finalizados = countF;
            emAtendimento = countA;
          });
        }
      }
    } catch (e) {
      debugPrint('💥 Erro ao processar: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        title: const Text(
          "Início",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchDashboardData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Resumo de Atividades",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),

                    // Layout inspirado no seu print
                    Row(
                      children: [
                        Expanded(
                          child: _buildSquareCard(
                            "Pendentes",
                            pendentes,
                            Colors.orange,
                            Icons.timer_outlined,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _buildSquareCard(
                            "Em Ajuste",
                            emAtendimento,
                            Colors.indigo,
                            Icons.edit_note,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    _buildWideCard(
                      "Finalizados",
                      finalizados,
                      Colors.green,
                      Icons.check_circle_outline,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSquareCard(String title, int value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 15),
          Text(
            value.toString().padLeft(2, '0'),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color.withOpacity(0.8),
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWideCard(String title, int value, Color color, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 10),
          Text(
            value.toString().padLeft(2, '0'),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color.withOpacity(0.8),
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap, // Ativa o clique
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.indigo.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.indigo),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
