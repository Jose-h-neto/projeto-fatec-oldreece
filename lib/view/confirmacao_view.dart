import 'package:flutter/material.dart';

import '../controller/home_controller.dart';
import '../core/app_routes.dart';
import '../core/dependencias.dart';
import '../core/formatos.dart';
import '../core/tema.dart';
import '../model/agendamento.dart';
import '../widgets/hud.dart';
import '../widgets/painel.dart';
import '../widgets/sa_botao.dart';

/// Funcionalidade: tela de "Missão cumprida" depois de agendar, com o
/// resumo do horário marcado.
class ConfirmacaoView extends StatelessWidget {
  final Agendamento agendamento;

  const ConfirmacaoView({super.key, required this.agendamento});

  void _voltar(BuildContext context, int aba) {
    g<HomeController>().irPara(aba);
    Navigator.popUntil(context, ModalRoute.withName(AppRoutes.home));
  }

  @override
  Widget build(BuildContext context) {
    final a = agendamento;
    final reduzirMovimento = MediaQuery.of(context).disableAnimations;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _voltar(context, HomeController.inicio);
      },
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: Espaco.s8),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: reduzirMovimento ? 1 : 1.15, end: 1),
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      builder: (context, escala, child) =>
                          Transform.scale(scale: escala, child: child),
                      child: const PainelMissao(
                        titulo: 'Missão cumprida!',
                        subtitulo: 'Horário marcado',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(Espaco.s4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: Espaco.s4),
                          Painel(
                            destaque: true,
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    FotoMoldura(a.barbeiro.foto, tamanho: 64),
                                    const SizedBox(width: Espaco.s3),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            Formatos.dataHora(a.data),
                                            style: Estilos.subtitle.copyWith(
                                              color: Cores.gold,
                                            ),
                                          ),
                                          Text(
                                            '${a.corte.nome} com '
                                            '${a.barbeiro.nome}',
                                            style: Estilos.body,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: Espaco.s6, thickness: 2),
                                Row(
                                  children: [
                                    const Expanded(
                                      child: Text(
                                        'TOTAL',
                                        style: Estilos.label,
                                      ),
                                    ),
                                    PrecoHud(a.corte.preco),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: Espaco.s4),
                          const Text(
                            'Chega uns 10 minutinhos antes. Se não der, '
                            'cancela pela agenda.',
                            textAlign: TextAlign.center,
                            style: Estilos.bodySm,
                          ),
                          const SizedBox(height: Espaco.s6),
                          SaBotao.primario(
                            rotulo: 'Ver minha agenda',
                            icone: Icons.event_note,
                            aoPressionar: () =>
                                _voltar(context, HomeController.agenda),
                          ),
                          const SizedBox(height: Espaco.s3),
                          SaBotao(
                            rotulo: 'Voltar ao início',
                            largo: true,
                            aoPressionar: () =>
                                _voltar(context, HomeController.inicio),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
