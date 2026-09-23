import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../theme/app_theme.dart';
import '../components/padrao_fundo.dart';
import 'home_screen.dart';
import 'cadastro_usuario_screen.dart';

// Credenciais de acesso rápido só para o desenvolvedor testar o app sem
// precisar passar pelo formulário de "Criar conta" (que continua
// obrigatório para qualquer usuário normal). Não fica salvo no banco,
// é só um atalho local neste arquivo.
// IMPORTANTE: troque ou remova isso antes de publicar o app de verdade,
// já que qualquer pessoa que ler o código-fonte veria essas credenciais.
const String _emailDesenvolvedor = 'dev@comabem.com';
const String _senhaDesenvolvedor = 'ComaBem#Dev2026';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  bool _senhaVisivel = false;
  bool _carregando = false;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _fazerLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _carregando = true);

    // Atalho de desenvolvedor: entra direto, sem consultar o banco nem
    // exigir conta cadastrada.
    final ehLoginDesenvolvedor =
        _emailController.text.trim().toLowerCase() == _emailDesenvolvedor &&
            _senhaController.text == _senhaDesenvolvedor;

    final usuario = ehLoginDesenvolvedor
        ? {'usu_id_usuario': 0, 'usu_nm_usuario': 'Desenvolvedor'}
        : await DatabaseHelper.instancia.autenticarUsuario(
            _emailController.text.trim(),
            _senhaController.text,
          );

    if (!mounted) return;
    setState(() => _carregando = false);

    if (usuario != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            idUsuario: usuario['usu_id_usuario'] as int?,
            nomeUsuario: usuario['usu_nm_usuario'] as String?,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('E-mail ou senha inválidos!'),
          backgroundColor: AppColors.erro,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creme,
      body: PadraoFundo(
        child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: AppColors.vinho,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.restaurant,
                    color: AppColors.douradoClaro,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Bem-vindo de volta!',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 6),
                const Text(
                  'Faça login para continuar explorando experiências únicas.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textoSecundario,
                  ),
                ),
                const SizedBox(height: 32),

                const Text(
                  'E-mail',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textoSecundario,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'seu@email.com',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (valor) {
                    if (valor == null || valor.trim().isEmpty) {
                      return 'Informe seu e-mail';
                    }
                    if (!valor.contains('@') || !valor.contains('.')) {
                      return 'Informe um e-mail válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                const Text(
                  'Senha',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textoSecundario,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _senhaController,
                  obscureText: !_senhaVisivel,
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _senhaVisivel
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: () {
                        setState(() => _senhaVisivel = !_senhaVisivel);
                      },
                    ),
                  ),
                  validator: (valor) {
                    if (valor == null || valor.isEmpty) {
                      return 'Informe sua senha';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: _carregando ? null : _fazerLogin,
                  child: _carregando
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Entrar'),
                ),

                const SizedBox(height: 24),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CadastroUsuarioScreen(),
                        ),
                      );
                    },
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          color: AppColors.textoSecundario,
                          fontSize: 14,
                        ),
                        children: [
                          TextSpan(text: 'Não tem uma conta? '),
                          TextSpan(
                            text: 'Criar conta',
                            style: TextStyle(
                              color: AppColors.vinho,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }
}
