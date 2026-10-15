import 'package:flutter/material.dart';

import '../controller/agendamento_controller.dart';
import '../core/dependencias.dart';
import '../core/formatos.dart';
import '../core/tema.dart';
import '../model/agendamento.dart';
import '../widgets/hud.dart';
import '../widgets/mensagem.dart';
import '../widgets/painel.dart';
import '../widgets/sa_botao.dart';

/// Funcionalidade: avaliar o atendimento com 0 a 6 estrelas (como o nível
/// de procurado) e um comentário opcional.
class AvaliarView extends StatefulWidget {
  final Agendamento agendamento;

  const AvaliarView({super.key, required this.agendamento});

  @override
  State<AvaliarView> createState() => _AvaliarViewState();
}

class _AvaliarViewState extends State<AvaliarView> {
  final _comentario = TextEditingController();
  int _estrelas = 0;

  static const _legendas = [
    'Toca nas estrelas pra dar a nota',
    'Nem me fala...',
    'Dava pra ser melhor',
    'De boa',
    'Mandou bem',
    'Ficou na régua',
    'Lenda do bairro!',
  ];

  @override
  void dispose() {
    _comentario.dispose();
    super.dispose();
  }

  void _enviar() {
    g<AgendamentoController>().avaliar(
      widget.agendamento,
      _estrelas,
      _comentario.text,
    );
    mostrarMensagem(context, 'Valeu pela avaliação!');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.agendamento;

    return Scaffold(
      appBar: AppBar(title: const Text('AVALIAR')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(Espaco.s4),
          children: [
            Painel(
              child: Row(
                children: [
                  FotoMoldura(a.barbeiro.foto, tamanho: 80),
                  const SizedBox(width: Espaco.s4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TituloZona(a.barbeiro.nome, tamanho: 30),
                        Text(a.corte.nome, style: Estilos.body),
                        Text(Formatos.dataHora(a.data), style: Estilos.caption),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Espaco.s8),
            const Text(
              'TUA NOTA',
              textAlign: TextAlign.center,
              style: Estilos.label,
            ),
            const SizedBox(height: Espaco.s2),
            Center(
              child: FittedBox(
                child: Estrelas(
                  valor: _estrelas,
                  tamanho: 34,
                  aoMudar: (v) => setState(() => _estrelas = v),
                ),
              ),
            ),
            const SizedBox(height: Espaco.s2),
            Text(
              _legendas[_estrelas],
              textAlign: TextAlign.center,
              style: Estilos.subtitle.copyWith(
                color: _estrelas == 0 ? Cores.inkMuted : Cores.gold,
              ),
            ),
            const SizedBox(height: Espaco.s8),
            TextField(
              controller: _comentario,
              maxLines: 4,
              maxLength: 200,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Comentário (opcional)',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: Espaco.s4),
            SaBotao.primario(
              rotulo: 'Enviar avaliação',
              icone: Icons.send,
              aoPressionar: _estrelas == 0 ? null : _enviar,
            ),
          ],
        ),
      ),
    );
  }
}
