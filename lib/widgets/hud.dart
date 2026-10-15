import 'package:flutter/material.dart';

import '../core/formatos.dart';
import '../core/tema.dart';
import 'texto_contorno.dart';

/// Preço no estilo contador de dinheiro do HUD: verde, contorno preto e
/// zeros à esquerda. Use `hud: false` em listas longas.
class PrecoHud extends StatelessWidget {
  final int valor;
  final bool hud;
  final double tamanho;

  const PrecoHud(this.valor, {super.key, this.hud = true, this.tamanho = 28});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: Formatos.preco(valor),
      excludeSemantics: true,
      child: TextoContorno(
        hud ? Formatos.precoHud(valor) : Formatos.preco(valor),
        estilo: Estilos.hudNumber.copyWith(fontSize: tamanho),
        contorno: tamanho > 24 ? 2 : 1.5,
      ),
    );
  }
}

/// Avaliação de 0 a 6 estrelas, como o nível de procurado.
/// Com [aoMudar], cada estrela vira um botão.
class Estrelas extends StatelessWidget {
  final int valor;
  final int maximo;
  final double tamanho;
  final ValueChanged<int>? aoMudar;

  const Estrelas({
    super.key,
    required this.valor,
    this.maximo = 6,
    this.tamanho = 18,
    this.aoMudar,
  });

  @override
  Widget build(BuildContext context) {
    final estrelas = List.generate(maximo, (i) {
      final cheia = i < valor;
      final estrela = Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.star, size: tamanho + 5, color: Cores.outline),
          Icon(
            Icons.star,
            size: tamanho,
            color: cheia ? Cores.goldFill : Cores.lineStrong,
          ),
        ],
      );
      if (aoMudar == null) return estrela;
      return Semantics(
        button: true,
        label: '${i + 1} de $maximo estrelas',
        child: InkResponse(
          onTap: () => aoMudar!(i + 1 == valor ? 0 : i + 1),
          radius: tamanho,
          child: Padding(padding: const EdgeInsets.all(4), child: estrela),
        ),
      );
    });

    return Semantics(
      label: aoMudar == null ? '$valor de $maximo estrelas' : null,
      child: Row(mainAxisSize: MainAxisSize.min, children: estrelas),
    );
  }
}

enum TomEtiqueta { neutro, grove, gold, health }

/// Etiqueta reta nas cores das gangues. Texto curto, até duas palavras.
class Etiqueta extends StatelessWidget {
  final String texto;
  final TomEtiqueta tom;

  const Etiqueta(this.texto, {super.key, this.tom = TomEtiqueta.neutro});

  @override
  Widget build(BuildContext context) {
    final (fundo, cor) = switch (tom) {
      TomEtiqueta.neutro => (Cores.surfaceSunken, Cores.ink),
      TomEtiqueta.grove => (Cores.groveSoft, Cores.grove),
      TomEtiqueta.gold => (Cores.goldSoft, Cores.gold),
      TomEtiqueta.health => (Cores.healthSoft, Cores.health),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Espaco.s2, vertical: 2),
      decoration: BoxDecoration(
        color: fundo,
        border: Border.all(color: cor, width: 2),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        texto.toUpperCase(),
        style: Estilos.label.copyWith(color: cor),
      ),
    );
  }
}

/// Nome da unidade ou do barbeiro na fonte script, como o aviso de bairro.
class TituloZona extends StatelessWidget {
  final String titulo;
  final String? subtitulo;
  final double tamanho;
  final CrossAxisAlignment alinhamento;

  const TituloZona(
    this.titulo, {
    super.key,
    this.subtitulo,
    this.tamanho = 40,
    this.alinhamento = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alinhamento,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextoContorno(titulo, estilo: Estilos.zone.copyWith(fontSize: tamanho)),
        if (subtitulo != null)
          Text(subtitulo!.toUpperCase(), style: Estilos.label),
      ],
    );
  }
}

/// O momento "Missão cumprida": título display em ouro (ou vermelho na
/// falha) com contorno, sobre o painel preto do HUD.
class PainelMissao extends StatelessWidget {
  final String titulo;
  final String? subtitulo;
  final bool sucesso;

  const PainelMissao({
    super.key,
    required this.titulo,
    this.subtitulo,
    this.sucesso = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Cores.hudPanel,
      padding: const EdgeInsets.symmetric(
        horizontal: Espaco.s4,
        vertical: Espaco.s6,
      ),
      child: Column(
        children: [
          TextoContorno(
            titulo.toUpperCase(),
            alinhamento: TextAlign.center,
            contorno: 3,
            estilo: Estilos.displayXl.copyWith(
              color: sucesso ? Cores.goldFill : Cores.health,
            ),
          ),
          if (subtitulo != null) ...[
            const SizedBox(height: Espaco.s2),
            TextoContorno(
              subtitulo!,
              alinhamento: TextAlign.center,
              estilo: Estilos.subtitle.copyWith(color: Cores.onHud),
            ),
          ],
        ],
      ),
    );
  }
}

/// Faixa com os 7 dias da semana; os dias de atendimento ficam em verde.
class DiasAtendimento extends StatelessWidget {
  final List<int> dias;

  const DiasAtendimento(this.dias, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var d = DateTime.monday; d <= DateTime.sunday; d++)
          Expanded(
            child: Semantics(
              label:
                  '${Formatos.diasLongos[d - 1]}: '
                  '${dias.contains(d) ? 'atende' : 'folga'}',
              excludeSemantics: true,
              child: Container(
                margin: EdgeInsets.only(right: d == DateTime.sunday ? 0 : 4),
                padding: const EdgeInsets.symmetric(vertical: 6),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: dias.contains(d)
                      ? Cores.groveSoft
                      : Cores.surfaceSunken,
                  border: Border.all(
                    color: dias.contains(d) ? Cores.grove : Cores.line,
                    width: 2,
                  ),
                ),
                child: Text(
                  Formatos.diasCurtos[d - 1],
                  style: Estilos.label.copyWith(
                    fontSize: 9,
                    color: dias.contains(d) ? Cores.grove : Cores.inkMuted,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
