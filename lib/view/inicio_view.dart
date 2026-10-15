import 'package:flutter/material.dart';

import '../controller/agendamento_controller.dart';
import '../controller/auth_controller.dart';
import '../controller/corte_controller.dart';
import '../controller/home_controller.dart';
import '../core/app_routes.dart';
import '../core/dependencias.dart';
import '../core/formatos.dart';
import '../core/tema.dart';
import '../model/agendamento.dart';
import '../widgets/hud.dart';
import '../widgets/painel.dart';
import '../widgets/sa_botao.dart';

/// Funcionalidade: tela inicial — saudação, próximo horário, atalho para
/// agendar e os cortes em alta.
class InicioView extends StatelessWidget {
  const InicioView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = g<AuthController>();
    final agenda = g<AgendamentoController>();
    final home = g<HomeController>();

    return ListenableBuilder(
      listenable: Listenable.merge([auth, agenda]),
      builder: (context, _) => ListView(
        padding: const EdgeInsets.all(Espaco.s4),
        children: [
          TituloZona(
            'E aí, ${auth.primeiroNome}',
            subtitulo: 'Bora dar um trato no visual?',
          ),
          const SizedBox(height: Espaco.s6),
          const TituloSecao('Seu próximo horário'),
          agenda.proximo == null
              ? const Painel(
                  child: Text(
                    'Nenhum horário marcado ainda.',
                    style: Estilos.bodySm,
                  ),
                )
              : _ProximoHorario(
                  agendamento: agenda.proximo!,
                  aoTocar: () => home.irPara(HomeController.agenda),
                ),
          if (agenda.pendentesDeAvaliacao > 0) ...[
            const SizedBox(height: Espaco.s3),
            Painel(
              cor: Cores.goldSoft,
              corBorda: Cores.gold,
              aoTocar: () => home.irPara(HomeController.agenda),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Cores.goldFill),
                  const SizedBox(width: Espaco.s3),
                  Expanded(
                    child: Text(
                      agenda.pendentesDeAvaliacao == 1
                          ? '1 atendimento esperando tua avaliação'
                          : '${agenda.pendentesDeAvaliacao} atendimentos '
                                'esperando tua avaliação',
                      style: Estilos.body.copyWith(color: Cores.gold),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Cores.gold),
                ],
              ),
            ),
          ],
          const SizedBox(height: Espaco.s4),
          SaBotao.primario(
            rotulo: 'Agendar horário',
            icone: Icons.event_available,
            aoPressionar: () {
              agenda.iniciar();
              Navigator.pushNamed(context, AppRoutes.agendar);
            },
          ),
          const SizedBox(height: Espaco.s8),
          TituloSecao(
            'Em alta no bairro',
            acao: 'Ver cortes',
            aoTocarAcao: () => home.irPara(HomeController.cortes),
          ),
          for (final c in g<CorteController>().destaques) ...[
            Painel(
              aoTocar: () {
                agenda.iniciar(corte: c);
                Navigator.pushNamed(context, AppRoutes.agendar);
              },
              child: Row(
                children: [
                  FotoMoldura(c.imagem, tamanho: 56),
                  const SizedBox(width: Espaco.s3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c.nome.toUpperCase(),
                          style: Estilos.displayMd.copyWith(fontSize: 22),
                        ),
                        Text(
                          Formatos.duracao(c.duracaoMin),
                          style: Estilos.label,
                        ),
                      ],
                    ),
                  ),
                  PrecoHud(c.preco, hud: false, tamanho: 22),
                ],
              ),
            ),
            const SizedBox(height: Espaco.s3),
          ],
        ],
      ),
    );
  }
}

class _ProximoHorario extends StatelessWidget {
  final Agendamento agendamento;
  final VoidCallback aoTocar;

  const _ProximoHorario({required this.agendamento, required this.aoTocar});

  @override
  Widget build(BuildContext context) {
    final a = agendamento;
    return Painel(
      destaque: true,
      aoTocar: aoTocar,
      child: Row(
        children: [
          FotoMoldura(a.barbeiro.foto, tamanho: 64),
          const SizedBox(width: Espaco.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Formatos.dataHora(a.data),
                  style: Estilos.subtitle.copyWith(color: Cores.gold),
                ),
                Text(
                  '${a.corte.nome} com ${a.barbeiro.nome}',
                  style: Estilos.bodySm,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Cores.inkMuted),
        ],
      ),
    );
  }
}
