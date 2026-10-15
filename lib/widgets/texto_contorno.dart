import 'package:flutter/material.dart';

import '../core/tema.dart';

/// Texto com contorno preto e sombra dura: a assinatura do HUD.
class TextoContorno extends StatelessWidget {
  final String texto;
  final TextStyle estilo;
  final double contorno;
  final TextAlign? alinhamento;
  final int? maxLinhas;

  const TextoContorno(
    this.texto, {
    super.key,
    required this.estilo,
    this.contorno = 2,
    this.alinhamento,
    this.maxLinhas,
  });

  @override
  Widget build(BuildContext context) {
    final borda = estilo.copyWith(
      foreground: Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = contorno * 2
        ..strokeJoin = StrokeJoin.round
        ..color = Cores.outline,
      shadows: [
        Shadow(color: Cores.outline, offset: Offset(contorno, contorno)),
      ],
    );

    return Stack(
      children: [
        Text(
          texto,
          style: borda,
          textAlign: alinhamento,
          maxLines: maxLinhas,
          overflow: maxLinhas == null ? null : TextOverflow.ellipsis,
          semanticsLabel: '',
        ),
        Text(
          texto,
          style: estilo,
          textAlign: alinhamento,
          maxLines: maxLinhas,
          overflow: maxLinhas == null ? null : TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
