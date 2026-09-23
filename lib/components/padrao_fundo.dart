import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Fundo com uma estampa de utensílios de cozinha desenhados em traço
/// fino (panela, colher de pau, batedor, talheres, xícara, rolo de
/// macarrão, chapéu de chef) -- no mesmo espírito do padrão de
/// referência de "herramientas de cocina", só que na paleta vinho/dourado
/// do app e com opacidade baixa para não atrapalhar a leitura.
///
/// Uso:
/// ```dart
/// body: PadraoFundo(
///   child: SafeArea(child: ...),
/// ),
/// ```
class PadraoFundo extends StatelessWidget {
  final Widget child;
  final Color cor;
  final double opacidade;

  const PadraoFundo({
    super.key,
    required this.child,
    this.cor = AppColors.vinho,
    this.opacidade = 0.09,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: ColoredBox(color: AppColors.creme)),
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _PadraoFundoPainter(
                cor: cor.withValues(alpha: opacidade),
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

enum _Utensilio { panela, colher, batedor, talheres, xicara, rolo, chapeu }

class _PadraoFundoPainter extends CustomPainter {
  final Color cor;
  const _PadraoFundoPainter({required this.cor});

  static const List<_Utensilio> _utensilios = [
    _Utensilio.panela,
    _Utensilio.talheres,
    _Utensilio.xicara,
    _Utensilio.batedor,
    _Utensilio.chapeu,
    _Utensilio.colher,
    _Utensilio.rolo,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final traco = Paint()
      ..color = cor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Grade "tijolo" (linhas alternadas deslocadas) como num papel de
    // parede real, com espaçamento suficiente para o padrão ficar denso
    // (como na referência) sem virar uma poluição visual.
    const espacamento = 68.0;
    final aleatorio = math.Random(7); // seed fixa: padrão sempre igual

    var linha = 0;
    for (double y = -espacamento; y < size.height + espacamento; y += espacamento) {
      final deslocamentoX = linha.isEven ? 0.0 : espacamento / 2;
      var coluna = 0;
      for (double x = -espacamento; x < size.width + espacamento; x += espacamento) {
        final utensilio = _utensilios[(linha * 3 + coluna) % _utensilios.length];
        final angulo = aleatorio.nextDouble() * 2 * math.pi;
        final escala = 0.72 + aleatorio.nextDouble() * 0.3;
        _desenharUtensilio(
          canvas,
          utensilio,
          Offset(x + deslocamentoX, y),
          angulo,
          escala,
          traco,
        );
        coluna++;
      }
      linha++;
    }
  }

  void _desenharUtensilio(
    Canvas canvas,
    _Utensilio tipo,
    Offset posicao,
    double angulo,
    double escala,
    Paint traco,
  ) {
    canvas.save();
    canvas.translate(posicao.dx, posicao.dy);
    canvas.rotate(angulo);
    canvas.scale(escala);

    switch (tipo) {
      case _Utensilio.panela:
        _panela(canvas, traco);
        break;
      case _Utensilio.colher:
        _colherDePau(canvas, traco);
        break;
      case _Utensilio.batedor:
        _batedor(canvas, traco);
        break;
      case _Utensilio.talheres:
        _talheres(canvas, traco);
        break;
      case _Utensilio.xicara:
        _xicara(canvas, traco);
        break;
      case _Utensilio.rolo:
        _roloDeMacarrao(canvas, traco);
        break;
      case _Utensilio.chapeu:
        _chapeuDeChef(canvas, traco);
        break;
    }

    canvas.restore();
  }

  // Todos os desenhos abaixo usam um "tabuleiro" de -20 a 20 em torno da
  // origem (0,0), assim escalam/rotacionam de forma previsível.

  void _panela(Canvas canvas, Paint traco) {
    final corpo = RRect.fromRectAndRadius(
      const Rect.fromLTRB(-13, -5, 13, 10),
      const Radius.circular(2),
    );
    canvas.drawRRect(corpo, traco);
    // tampa
    canvas.drawArc(const Rect.fromLTRB(-14, -12, 14, -2), math.pi, math.pi, false, traco);
    canvas.drawLine(const Offset(0, -12), const Offset(0, -14), traco);
    canvas.drawCircle(const Offset(0, -15.5), 1.4, traco);
    // alças
    canvas.drawLine(const Offset(-13, -1), const Offset(-19, -1), traco);
    canvas.drawLine(const Offset(13, -1), const Offset(19, -1), traco);
  }

  void _colherDePau(Canvas canvas, Paint traco) {
    canvas.drawLine(const Offset(0, -19), const Offset(0, 3), traco);
    canvas.drawOval(const Rect.fromLTRB(-7, 3, 7, 19), traco);
  }

  void _batedor(Canvas canvas, Paint traco) {
    canvas.drawLine(const Offset(0, -19), const Offset(0, -6), traco);
    final laco1 = Path()
      ..moveTo(0, -6)
      ..quadraticBezierTo(-11, 6, 0, 17);
    final laco2 = Path()
      ..moveTo(0, -6)
      ..quadraticBezierTo(11, 6, 0, 17);
    final laco3 = Path()
      ..moveTo(0, -6)
      ..quadraticBezierTo(-6, 8, 0, 17);
    final laco4 = Path()
      ..moveTo(0, -6)
      ..quadraticBezierTo(6, 8, 0, 17);
    canvas.drawPath(laco1, traco);
    canvas.drawPath(laco2, traco);
    canvas.drawPath(laco3, traco);
    canvas.drawPath(laco4, traco);
  }

  void _talheres(Canvas canvas, Paint traco) {
    // garfo (esquerda)
    canvas.drawLine(const Offset(-6, -8), const Offset(-6, 19), traco);
    canvas.drawLine(const Offset(-9, -19), const Offset(-9, -8), traco);
    canvas.drawLine(const Offset(-6, -19), const Offset(-6, -8), traco);
    canvas.drawLine(const Offset(-3, -19), const Offset(-3, -8), traco);
    canvas.drawLine(const Offset(-9, -8), const Offset(-3, -8), traco);
    // faca (direita)
    final lamina = Path()
      ..moveTo(6, -19)
      ..quadraticBezierTo(11, -14, 6, -2)
      ..lineTo(4, -2)
      ..quadraticBezierTo(4, -14, 6, -19)
      ..close();
    canvas.drawPath(lamina, traco);
    canvas.drawLine(const Offset(5, -2), const Offset(5, 19), traco);
  }

  void _xicara(Canvas canvas, Paint traco) {
    final corpo = Path()
      ..moveTo(-9, -3)
      ..lineTo(9, -3)
      ..lineTo(7, 13)
      ..lineTo(-7, 13)
      ..close();
    canvas.drawPath(corpo, traco);
    canvas.drawArc(const Rect.fromLTRB(7, -2, 18, 9), -1.4, 2.8, false, traco);
    // vapor
    final vapor1 = Path()
      ..moveTo(-3, -7)
      ..quadraticBezierTo(-6, -12, -3, -16)
      ..quadraticBezierTo(0, -20, -2, -23);
    final vapor2 = Path()
      ..moveTo(4, -7)
      ..quadraticBezierTo(1, -12, 4, -16)
      ..quadraticBezierTo(7, -20, 5, -23);
    canvas.drawPath(vapor1, traco);
    canvas.drawPath(vapor2, traco);
  }

  void _roloDeMacarrao(Canvas canvas, Paint traco) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTRB(-11, -3, 11, 3), const Radius.circular(2)),
      traco,
    );
    canvas.drawLine(const Offset(-11, 0), const Offset(-19, 0), traco);
    canvas.drawLine(const Offset(11, 0), const Offset(19, 0), traco);
    canvas.drawCircle(const Offset(-20.5, 0), 1.6, traco);
    canvas.drawCircle(const Offset(20.5, 0), 1.6, traco);
  }

  void _chapeuDeChef(Canvas canvas, Paint traco) {
    final touca = Path()
      ..moveTo(-9, 3)
      ..quadraticBezierTo(-11, -9, -5, -7)
      ..quadraticBezierTo(-3, -16, 0, -9)
      ..quadraticBezierTo(3, -16, 5, -7)
      ..quadraticBezierTo(11, -9, 9, 3);
    canvas.drawPath(touca, traco);
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTRB(-9, 3, 9, 10), const Radius.circular(2)),
      traco,
    );
  }

  @override
  bool shouldRepaint(covariant _PadraoFundoPainter oldDelegate) =>
      oldDelegate.cor != cor;
}
