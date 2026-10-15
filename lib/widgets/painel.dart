import 'package:flutter/material.dart';

import '../core/tema.dart';

/// Painel com moldura grossa e sombra dura, como as artes de capa.
class Painel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool destaque;
  final VoidCallback? aoTocar;
  final Color cor;
  final Color corBorda;

  const Painel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(Espaco.s4),
    this.destaque = false,
    this.aoTocar,
    this.cor = Cores.surfaceRaised,
    this.corBorda = Cores.frame,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cor,
        border: Border.all(color: corBorda, width: 3),
        boxShadow: destaque ? Sombras.hardLg : Sombras.hard,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: aoTocar,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Foto quadrada com borda preta.
class FotoMoldura extends StatelessWidget {
  final String imagem;
  final double tamanho;
  final double? altura;

  const FotoMoldura(this.imagem, {super.key, this.tamanho = 64, this.altura});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: tamanho,
      height: altura ?? tamanho,
      decoration: BoxDecoration(
        border: Border.all(color: Cores.outline, width: 2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: Image.asset(
          imagem,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Container(
            color: Cores.surfaceSunken,
            child: const Icon(Icons.content_cut, color: Cores.inkMuted),
          ),
        ),
      ),
    );
  }
}

/// Cabeçalho de seção em fonte de menu, com ação opcional à direita.
class TituloSecao extends StatelessWidget {
  final String texto;
  final String? acao;
  final VoidCallback? aoTocarAcao;

  const TituloSecao(this.texto, {super.key, this.acao, this.aoTocarAcao});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Espaco.s2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              texto.toUpperCase(),
              style: Estilos.label.copyWith(fontSize: 12, color: Cores.ink),
            ),
          ),
          if (acao != null)
            TextButton(
              onPressed: aoTocarAcao,
              child: Text(acao!.toUpperCase()),
            ),
        ],
      ),
    );
  }
}
