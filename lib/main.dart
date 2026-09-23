import 'package:flutter/material.dart';
import 'database/banco_plataforma.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/cadastro_screen.dart';
import 'screens/cadastro_usuario_screen.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() {
  // Ver lib/database/banco_plataforma.dart para o motivo e os detalhes
  // (resumo: sem isso, o banco falha em desktop e, principalmente, ao
  // rodar o app pelo navegador -- Edge/Chrome).
  //
  // IMPORTANTE: se você estiver rodando pelo navegador (Edge/Chrome) e
  // ver erro de banco na primeira vez, rode uma vez, no terminal, dentro
  // da pasta do projeto:
  //   dart run sqflite_common_ffi_web:setup
  // Isso baixa o "sqlite3.wasm" pra pasta web/ (suporte a SQLite no
  // navegador é experimental e depende desse arquivo). Se preferir não
  // lidar com isso agora, rode o app num emulador Android ou como app
  // desktop (Windows/Linux/macOS) em vez do navegador -- lá funciona
  // direto, sem esse passo extra.
  configurarBancoDeDados();

  runApp(const ComaBemApp());
}

class ComaBemApp extends StatelessWidget { 
  const ComaBemApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Coma Bem',

      // Tema centralizado em lib/theme/app_theme.dart (paleta vinho + dourado)
      theme: AppTheme.tema,

      // Primeira tela que será aberta
      initialRoute: '/splash',

      // Rotas do aplicativo
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/cadastro-usuario': (context) => const CadastroUsuarioScreen(),
        '/cadastro': (context) => const CadastroScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
