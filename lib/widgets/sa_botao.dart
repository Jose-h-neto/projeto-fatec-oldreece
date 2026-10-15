import 'package:flutter/material.dart';

import '../core/tema.dart';

enum VarianteBotao { primario, secundario, perigo, fantasma }

/// Botão reto com moldura e sombra dura que afunda 3px ao pressionar.
/// Use o [VarianteBotao.primario] uma vez por tela, para a ação principal.
class SaBotao extends StatefulWidget {
  final String rotulo;
  final VoidCallback? aoPressionar;
  final VarianteBotao variante;
  final IconData? icone;
  final bool grande;
  final bool largo;
  final bool carregando;

  const SaBotao({
    super.key,
    required this.rotulo,
    required this.aoPressionar,
    this.variante = VarianteBotao.secundario,
    this.icone,
    this.grande = false,
    this.largo = false,
    this.carregando = false,
  });

  const SaBotao.primario({
    super.key,
    required this.rotulo,
    required this.aoPressionar,
    this.icone,
    this.grande = true,
    this.largo = true,
    this.carregando = false,
  }) : variante = VarianteBotao.primario;

  @override
  State<SaBotao> createState() => _SaBotaoState();
}

class _SaBotaoState extends State<SaBotao> {
  bool _pressionado = false;

  bool get _ativo => widget.aoPressionar != null && !widget.carregando;

  (Color fundo, Color texto, Color borda) get _cores =>
      switch (widget.variante) {
        VarianteBotao.primario => (Cores.grove, Cores.onGrove, Cores.frame),
        VarianteBotao.secundario => (
          Cores.surfaceRaised,
          Cores.ink,
          Cores.frame,
        ),
        VarianteBotao.perigo => (Cores.health, Cores.onHealth, Cores.frame),
        VarianteBotao.fantasma => (
          Colors.transparent,
          Cores.ink,
          Colors.transparent,
        ),
      };

  @override
  Widget build(BuildContext context) {
    final (fundo, texto, borda) = _cores;
    final fantasma = widget.variante == VarianteBotao.fantasma;
    final comSombra = !fantasma && _ativo && !_pressionado;
    final deslocamento = _pressionado && !fantasma ? 3.0 : 0.0;

    final conteudo = widget.carregando
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 3, color: texto),
          )
        : Row(
            mainAxisSize: widget.largo ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icone != null) ...[
                Icon(widget.icone, size: 18, color: texto),
                const SizedBox(width: Espaco.s2),
              ],
              Flexible(
                child: Text(
                  widget.rotulo.toUpperCase(),
                  overflow: TextOverflow.ellipsis,
                  style: Estilos.menu.copyWith(
                    color: texto,
                    fontSize: widget.grande ? 13 : 11,
                  ),
                ),
              ),
            ],
          );

    return Opacity(
      opacity: widget.aoPressionar == null ? 0.45 : 1,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        transform: Matrix4.translationValues(deslocamento, deslocamento, 0),
        height: widget.grande ? 56 : 44,
        width: widget.largo ? double.infinity : null,
        decoration: BoxDecoration(
          color: fundo,
          border: Border.all(color: borda, width: 3),
          boxShadow: comSombra ? Sombras.hard : null,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: _ativo ? widget.aoPressionar : null,
            onHighlightChanged: (v) => setState(() => _pressionado = v),
            focusColor: Cores.goldSoft,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: widget.grande ? Espaco.s8 : Espaco.s4,
              ),
              child: Center(widthFactor: 1, child: conteudo),
            ),
          ),
        ),
      ),
    );
  }
}
