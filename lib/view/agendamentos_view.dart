import 'package:flutter/material.dart';

import '../controller/agendamento_controller.dart';
import '../core/app_routes.dart';
import '../core/dependencias.dart';
import '../core/formatos.dart';
import '../core/tema.dart';
import '../model/agendamento.dart';
import '../widgets/hud.dart';
import '../widgets/mensagem.dart';
import '../widgets/painel.dart';
import '../widgets/sa_botao.dart';

/// Funcionalidade: minha agenda (ListView) — próximos horários com opção de
/// cancelar e o histórico com avaliações.
class AgendamentosView extends StatelessWidget {
  const AgendamentosView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = g<AgendamentoController>();

    return ListenableBuilder(
      listenable: ctrl,
      builder: (context, _) {
        final proximos = ctrl.proximos;
        final historico = ctrl.historico;

        return ListView(
          padding: const EdgeInsets.all(Espaco.s4),
          children: [
            const TituloSecao('Próximos'),
            if (proximos.isEmpty) ...[
              const Text('Nada marcado por enquanto.', style: Estilos.bodySm),
              const SizedBox(height: Espaco.s3),
              SaBotao.primario(
                rotulo: 'Agendar horário',
                icone: Icons.event_available,
                aoPressionar: () {
                  ctrl.iniciar();
                  Navigator.pushNamed(context, AppRoutes.agendar);
                },
              ),
            ],
            for (final a in proximos) ...[
              _ItemAgendamento(a),
              const SizedBox(height: Espaco.s3),
            ],
            const SizedBox(height: Espaco.s6),
            const TituloSecao('Histórico'),
            if (historico.isEmpty)
              const Text('Teu histórico aparece aqui.', style: Estilos.bodySm),
            for (final a in historico) ...[
              _ItemAgendamento(a),
              const SizedBox(height: Espaco.s3),
            ],
          ],
        );
      },
    );
  }
}

class _ItemAgendamento extends StatelessWidget {
  final Agendamento agendamento;

  const _ItemAgendamento(this.agendamento);

  Future<void> _cancelar(BuildContext context) async {
    final ok = await confirmar(
      context,
      titulo: 'Cancelar horário?',
      mensagem:
          '${agendamento.corte.nome} com ${agendamento.barbeiro.nome}, '
          '${Formatos.dataHora(agendamento.data)}.',
      rotuloConfirmar: 'Cancelar horário',
      perigo: true,
    );
    if (!ok || !context.mounted) return;
    g<AgendamentoController>().cancelar(agendamento);
    mostrarMensagem(context, 'Horário cancelado. A cadeira foi liberada.');
  }

  @override
  Widget build(BuildContext context) {
    final a = agendamento;
    final agendado = a.status == StatusAgendamento.agendado;
    final cancelado = a.status == StatusAgendamento.cancelado;

    return Painel(
      destaque: agendado,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Opacity(
                opacity: cancelado ? 0.5 : 1,
                child: FotoMoldura(a.barbeiro.foto, tamanho: 52),
              ),
              const SizedBox(width: Espaco.s3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Formatos.dataHora(a.data),
                      style: Estilos.body.copyWith(
                        fontWeight: FontWeight.w700,
                        color: agendado ? Cores.gold : Cores.ink,
                        decoration: cancelado
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    Text(
                      '${a.corte.nome} com ${a.barbeiro.nome}',
                      style: Estilos.bodySm,
                    ),
                  ],
                ),
              ),
              if (!agendado)
                Etiqueta(
                  a.status.rotulo,
                  tom: cancelado ? TomEtiqueta.health : TomEtiqueta.neutro,
                ),
            ],
          ),
          if (agendado)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                style: TextButton.styleFrom(foregroundColor: Cores.health),
                onPressed: () => _cancelar(context),
                child: const Text('CANCELAR'),
              ),
            ),
          if (a.podeAvaliar) ...[
            const SizedBox(height: Espaco.s3),
            SaBotao(
              rotulo: 'Avaliar atendimento',
              icone: Icons.star_outline,
              largo: true,
              aoPressionar: () =>
                  Navigator.pushNamed(context, AppRoutes.avaliar, arguments: a),
            ),
          ],
          if (a.avaliacao != null) ...[
            const SizedBox(height: Espaco.s2),
            Estrelas(valor: a.avaliacao!, tamanho: 14),
            if (a.comentario != null) ...[
              const SizedBox(height: Espaco.s1),
              Text('“${a.comentario}”', style: Estilos.bodySm),
            ],
          ],
        ],
      ),
    );
  }
}
