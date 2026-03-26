// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
// import 'package:provider/provider.dart';
// import 'package:intl/intl.dart'; 
// import '../models/call_model.dart';
// import '../models/theme_model.dart';
// import '../models/user_model.dart';

// class CallsScreen extends StatefulWidget {
//   const CallsScreen({super.key});

//   @override
//   State<CallsScreen> createState() => _CallsScreenState();
// }

// class _CallsScreenState extends State<CallsScreen> {
//   UserProfile? _currentUser;
//   List<CallModel> _calls = [];
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadCalls();
//   }

//   Future<void> _loadCalls() async {
//     if (!mounted) return;
//     setState(() => _isLoading = true);

//     try {
//       final themeModel = Provider.of<ThemeModel>(context, listen: false);
//       _currentUser = themeModel.currentUser;

//       if (_currentUser == null) {
//         setState(() => _isLoading = false);
//         return;
//       }

//       final uri = Uri.parse('http://10.232.135.191:3001/api/chamado').replace(
//         queryParameters: {
//           'pagina': '1',
//           'limite': '50',
//           'pessoaId': _currentUser!.id.toString(),
//           'unidadeId': _currentUser!.unidadeId?.toString() ?? '',
//         },
//       );

//       final response = await http.get(
//         uri,
//         headers: {'Authorization': 'Bearer ${_currentUser!.token!}'},
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data is Map && data.containsKey('data')) {
//           final List<dynamic> chamadosJson = data['data'] as List<dynamic>;
//           setState(() {
//             _calls = chamadosJson.map((json) => CallModel.fromJson(json)).toList();
//           });
//         }
//       }
//     } catch (e) {
//       debugPrint('Erro ao carregar chamados: $e');
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final cs = Theme.of(context).colorScheme;

//     return Scaffold(
//       backgroundColor: cs.surfaceVariant.withOpacity(0.3), // Fundo levemente acinzentado para destacar os cards
//       appBar: AppBar(
//         title: Text('Meus Chamados', 
//           style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 20)
//         ),
//         centerTitle: false,
//         elevation: 0,
//         backgroundColor: Colors.transparent,
//         surfaceTintColor: Colors.transparent,
//       ),
//       body: RefreshIndicator(
//         onRefresh: _loadCalls,
//         color: cs.primary,
//         child: _isLoading
//             ? const Center(child: CircularProgressIndicator())
//             : _calls.isEmpty
//                 ? _buildEmptyState(context)
//                 : ListView.separated(
//                     padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
//                     itemCount: _calls.length,
//                     separatorBuilder: (_, __) => const SizedBox(height: 12),
//                     itemBuilder: (context, index) => _buildCallCard(context, _calls[index]),
//                   ),
//       ),
//     );
//   }

//   Widget _buildEmptyState(BuildContext context) {
//     return ListView(
//       children: [
//         SizedBox(height: MediaQuery.of(context).size.height * 0.2),
//         Icon(Icons.assignment_late_outlined, size: 80, color: Colors.grey[400]),
//         const SizedBox(height: 16),
//         Center(
//           child: Text('Nenhum chamado encontrado', 
//             style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey[600])
//           ),
//         ),
//         Center(
//           child: Text('Puxe para atualizar a lista', 
//             style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[500])
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildCallCard(BuildContext context, CallModel call) {
//     final cs = Theme.of(context).colorScheme;
//     final isEditable = call.status == 'PENDENTE' || call.status == 'FALTAINFORMACAO';
    
//     // Formatação de data simples
//     final String dateStr = call.dataInicio != null 
//         ? DateFormat('dd MMM, HH:mm').format(call.dataInicio!.toLocal()) 
//         : '--/--';

//     return Container(
//       decoration: BoxDecoration(
//         color: cs.surface,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(20),
//         child: IntrinsicHeight(
//           child: Row(
//             children: [
//               // Barra lateral colorida conforme o status
//               Container(
//                 width: 6,
//                 color: _getStatusColor(call.status),
//               ),
//               Expanded(
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text('ID #${call.id}', 
//                             style: GoogleFonts.jetBrainsMono(
//                               fontSize: 12, 
//                               color: Colors.grey[600],
//                               fontWeight: FontWeight.bold
//                             )
//                           ),
//                           _buildStatusChip(call.status),
//                         ],
//                       ),
//                       const SizedBox(height: 10),
//                       Text(
//                         call.descricaoInicial,
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                         style: GoogleFonts.inter(
//                           fontSize: 15, 
//                           fontWeight: FontWeight.w600,
//                           height: 1.3
//                         ),
//                       ),
//                       const SizedBox(height: 12),
//                       Row(
//                         children: [
//                           Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
//                           const SizedBox(width: 4),
//                           Text(dateStr, 
//                             style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[500])
//                           ),
//                         ],
//                       ),
//                       if (isEditable) ...[
//                         const SizedBox(height: 16),
//                         Row(
//                           children: [
//                             Expanded(child: _buildActionButton('Editar', Icons.edit_outlined, cs.primary.withOpacity(0.1), cs.primary)),
//                             const SizedBox(width: 10),
//                             Expanded(child: _buildActionButton('Cancelar', Icons.close_rounded, Colors.red[50]!, Colors.red[700]!)),
//                           ],
//                         )
//                       ]
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildStatusChip(String status) {
//     final color = _getStatusColor(status);
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: color.withOpacity(0.2)),
//       ),
//       child: Text(
//         status,
//         style: GoogleFonts.inter(
//           fontSize: 11, 
//           fontWeight: FontWeight.bold, 
//           color: color
//         ),
//       ),
//     );
//   }

//   Widget _buildActionButton(String label, IconData icon, Color bg, Color fg) {
//     return Material(
//       color: bg,
//       borderRadius: BorderRadius.circular(12),
//       child: InkWell(
//         onTap: () {},
//         borderRadius: BorderRadius.circular(12),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 10),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(icon, size: 16, color: fg),
//               const SizedBox(width: 6),
//               Text(label, 
//                 style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: fg)
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Color _getStatusColor(String status) {
//     switch (status.toUpperCase()) {
//       case 'PENDENTE': return Colors.orange[700]!;
//       case 'FALTAINFORMACAO': return Colors.purple[600]!;
//       case 'CONCLUIDO': return Colors.green[600]!;
//       case 'CANCELADO': return Colors.red[600]!;
//       case 'EM_ANDAMENTO': return Colors.blue[600]!;
//       default: return Colors.blueGrey[600]!;
//     }
//   }
// }





























import 'dart:convert';
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
  State<CallsScreen> createState() => CallsScreenState(); // Removido o underline para ser acessível via GlobalKey
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
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surfaceVariant.withOpacity(0.2),
      appBar: AppBar(
        title: Text('Meus Chamados', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
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
                    itemBuilder: (context, index) => _buildCallCard(context, _calls[index]),
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
        Center(child: Text('Nenhum chamado ativo', style: GoogleFonts.inter(color: Colors.grey[600], fontWeight: FontWeight.w500))),
      ],
    );
  }

  Widget _buildCallCard(BuildContext context, CallModel call) {
    final cs = Theme.of(context).colorScheme;
    final statusColor = _getStatusColor(call.status);
    final isEditable = call.status == 'PENDENTE' || call.status == 'FALTAINFORMACAO';

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(width: 5, decoration: BoxDecoration(color: statusColor, borderRadius: const BorderRadius.horizontal(left: Radius.circular(18)))),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('ID #${call.id}', style: GoogleFonts.jetBrainsMono(fontSize: 11, color: Colors.grey)),
                        _buildStatusChip(call.status, statusColor),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(call.descricaoInicial, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600)),
                    if (isEditable) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildBtn('Editar', Icons.edit_outlined, cs.primary)),
                          const SizedBox(width: 8),
                          Expanded(child: _buildBtn('Cancelar', Icons.close, Colors.red[700]!)),
                        ],
                      )
                    ]
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
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(status, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
    );
  }

  Widget _buildBtn(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDENTE': return Colors.orange[800]!;
      case 'CONCLUIDO': return Colors.green[700]!;
      case 'CANCELADO': return Colors.red[700]!;
      default: return Colors.blue[700]!;
    }
  }
}