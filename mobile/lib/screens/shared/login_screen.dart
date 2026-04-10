import 'dart:async';
import 'dart:convert';

import 'package:classificador/config.dart';
import 'package:classificador/screens/shared/components/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../../models/theme_model.dart';
import '../../models/user_model.dart';

// === Formatação para maiúsculas ===
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

// === Formatação para CPF ===
class CpfFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (text.length <= 3) {
      return TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    } else if (text.length <= 11) {
      // Simplifiquei a lógica para brevidade, mantendo a funcionalidade
      String formatted = text;
      if (text.length > 3) {
        formatted = '${text.substring(0, 3)}.${text.substring(3)}';
      }
      if (text.length > 6) {
        formatted = '${formatted.substring(0, 7)}.${text.substring(6)}';
      }
      if (text.length > 9) {
        formatted = '${formatted.substring(0, 11)}-${text.substring(9)}';
      }
      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
    return oldValue;
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  bool _isCidadao = true;
  bool _isLoading = false;
  bool _isObscure = true;
  late AnimationController _toggleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _toggleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _toggleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _cpfController.dispose();
    _usuarioController.dispose();
    _senhaController.dispose();
    _toggleController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final Map<String, dynamic> body;
      final Uri url;

      if (_isCidadao) {
        final cpf = _cpfController.text.replaceAll(RegExp(r'\D'), '');
        final senha = _senhaController.text.trim();
        if (cpf.isEmpty || senha.isEmpty) {
          throw Exception('CPF e senha são obrigatórios!');
        }
        body = {'PessoaUsuario': cpf, 'PessoaSenha': senha};
        url = Uri.parse('${AppConfig.baseUrl}/api/pessoa/login');
      } else {
        final usuario = _usuarioController.text.trim().toUpperCase();
        final senha = _senhaController.text.trim();
        if (usuario.isEmpty || senha.isEmpty) {
          throw Exception('Usuário e senha são obrigatórios!');
        }
        body = {'TecnicoUsuario': usuario, 'TecnicoSenha': senha};
        url = Uri.parse('${AppConfig.baseUrl}/api/tecnico/login');
      }

      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // CORREÇÃO: Usando o UserProfile que você já tem
        final user = UserProfile.fromJson(data);

        if (mounted) {
          // SALVANDO NO PROVIDER (Importante: verifique se seu ThemeModel realmente gerencia o UserProfile)
          final themeModel = Provider.of<ThemeModel>(context, listen: false);
          themeModel.setCurrentUser(user);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const BottomNavBarScreen()),
          );
        }
      } else {
        final errorMsg =
            jsonDecode(response.body)['message'] ??
            'Erro ${response.statusCode}';
        throw Exception(errorMsg);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ $e'), backgroundColor: Colors.red.shade700),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _toggleMode() {
    _toggleController.forward(from: 0.0);
    Future.delayed(const Duration(milliseconds: 150), () {
      setState(() {
        _isCidadao = !_isCidadao;
        _cpfController.clear();
        _usuarioController.clear();
        _senhaController.clear();
      });
      _toggleController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);
    final fontSize = themeModel.fontSizeScale;

    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 40.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: 1.0,
                  child: Text(
                    _isCidadao
                        ? 'Seja bem-vindo,\nCidadão!'
                        : 'Seja bem-vindo,\nTécnico!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 28 * fontSize,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                      height: 1.3,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _isCidadao
                      ? Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.09),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _cpfController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [CpfFormatter()],
                            style: GoogleFonts.inter(
                              fontSize: 16 * fontSize,
                              color: cs.onSurface,
                            ),
                            decoration: InputDecoration(
                              labelText: 'CPF',
                              labelStyle: GoogleFonts.inter(
                                fontSize: 14 * fontSize,
                                color: cs.onSurface.withOpacity(0.7),
                              ),
                              hintText: '000.000.000-00',
                              hintStyle: GoogleFonts.inter(
                                fontSize: 14 * fontSize,
                                color: cs.onSurface.withOpacity(0.5),
                              ),
                              filled: true,
                              fillColor: cs.surface,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: cs.outline),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: cs.outline),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: cs.primary,
                                  width: 2,
                                ),
                              ),
                              prefixIcon: Icon(
                                Icons.person,
                                color: cs.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _usuarioController,
                            style: GoogleFonts.inter(
                              fontSize: 16 * fontSize,
                              color: cs.onSurface,
                            ),
                            inputFormatters: [UpperCaseTextFormatter()],
                            textCapitalization: TextCapitalization.characters,
                            decoration: InputDecoration(
                              labelText: 'Usuário',
                              labelStyle: GoogleFonts.inter(
                                fontSize: 14 * fontSize,
                                color: cs.onSurface.withOpacity(0.7),
                              ),
                              hintText: 'DIGITE SEU USUÁRIO',
                              hintStyle: GoogleFonts.inter(
                                fontSize: 14 * fontSize,
                                color: cs.onSurface.withOpacity(0.5),
                              ),
                              filled: true,
                              fillColor: cs.surface,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: cs.outline),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: cs.outline),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: cs.primary,
                                  width: 2,
                                ),
                              ),
                              prefixIcon: Icon(
                                Icons.account_circle,
                                color: cs.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 20),

                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _senhaController,
                    style: GoogleFonts.inter(
                      fontSize: 16 * fontSize,
                      color: cs.onSurface,
                    ),
                    obscureText: _isObscure,
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      labelStyle: GoogleFonts.inter(
                        fontSize: 14 * fontSize,
                        color: cs.onSurface.withOpacity(0.7),
                      ),
                      hintText: 'Digite sua senha',
                      hintStyle: GoogleFonts.inter(
                        fontSize: 14 * fontSize,
                        color: cs.onSurface.withOpacity(0.5),
                      ),
                      filled: true,
                      fillColor: cs.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: cs.outline),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: cs.outline),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: cs.primary, width: 2),
                      ),
                      prefixIcon: Icon(
                        Icons.lock,
                        color: cs.onSurface.withOpacity(0.7),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isObscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _isObscure = !_isObscure;
                          });
                        },
                        color: cs.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildToggleChip(
                            label: 'Pessoa',
                            isActive: _isCidadao,
                            onTap: _toggleMode,
                            cs: cs,
                          ),
                          const SizedBox(width: 8),
                          _buildToggleChip(
                            label: 'Técnico',
                            isActive: !_isCidadao,
                            onTap: _toggleMode,
                            cs: cs,
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 32),

                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.primary,
                        foregroundColor: cs.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Entrando...',
                                  style: GoogleFonts.inter(
                                    fontSize: 16 * fontSize,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              'ENTRAR',
                              style: GoogleFonts.inter(
                                fontSize: 18 * fontSize,
                                fontWeight: FontWeight.bold,
                                color: cs.onPrimary,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (_isLoading)
            Stack(
              children: [
                Container(color: Colors.black.withOpacity(0.5)),
                Center(
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    color: cs.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: cs.outline, width: 1),
                    ),
                    elevation: 12,
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 64,
                            height: 64,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                cs.primary,
                              ),
                              strokeWidth: 4,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Autenticando...',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 20 * fontSize,
                              fontWeight: FontWeight.bold,
                              color: cs.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Por favor, aguarde...',
                            style: TextStyle(
                              color: cs.onSurface.withOpacity(0.7),
                              fontSize: 14 * fontSize,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildToggleChip({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    required ColorScheme cs,
  }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isActive ? 0.1 : 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? cs.primary : cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              color: isActive ? cs.onPrimary : cs.onSurface,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
