import 'package:flutter/material.dart';
import 'dart:async';
import '../theme/app_theme.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 6), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

  static const String _urlImagemFundo =
      'https://images.pexels.com/photos/4253316/pexels-photo-4253316.jpeg';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Foto de fundo. Se a internet estiver lenta/offline no momento
          // do splash, cai automaticamente no gradiente vinho (errorBuilder)
          // em vez de mostrar uma tela quebrada.
          Image.network(
            _urlImagemFundo,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progresso) {
              if (progresso == null) return child;
              return const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.vinhoEscuro, AppColors.vinho],
                  ),
                ),
              );
            },
            errorBuilder: (context, erro, stackTrace) {
              return const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.vinhoEscuro, AppColors.vinho],
                  ),
                ),
              );
            },
          ),

          // Camada escura em tom de vinho por cima da foto, para manter
          // o texto legível e a identidade visual consistente.
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.vinhoEscuro.withValues(alpha: 0.80),
                  AppColors.vinho.withValues(alpha: 0.55),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.08),
                      border: Border.all(
                        color: AppColors.dourado.withValues(alpha: 0.6),
                        width: 1.4,
                      ),
                    ),
                    child: const Icon(
                      Icons.restaurant, 
                      size: 46,
                      color: AppColors.douradoClaro,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Coma Bem',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Descubra sabores inesquecíveis',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.85),
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.douradoClaro,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
