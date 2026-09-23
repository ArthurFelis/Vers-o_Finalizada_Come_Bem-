import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Seletor de nota em estrelas, de 0 (sem nota) a 5.
/// Tocar numa estrela já marcada limpa a nota (volta pra 0).
class SeletorDeNota extends StatelessWidget {
  final int nota; // 0 a 5
  final ValueChanged<int> aoMudar;

  const SeletorDeNota({
    super.key,
    required this.nota,
    required this.aoMudar,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 1; i <= 5; i++)
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
            visualDensity: VisualDensity.compact,
            onPressed: () => aoMudar(i == nota ? 0 : i),
            icon: Icon(
              i <= nota ? Icons.star_rounded : Icons.star_border_rounded,
              color: AppColors.dourado,
              size: 28,
            ),
          ),
        const SizedBox(width: 6),
        Text(
          nota == 0 ? 'Sem nota' : '$nota/5',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textoSecundario,
          ),
        ),
      ],
    );
  }
}
