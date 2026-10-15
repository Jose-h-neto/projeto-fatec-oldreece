import 'package:flutter/material.dart';

import '../controller/agendamento_controller.dart';
import '../controller/barbeiro_controller.dart';
import '../controller/corte_controller.dart';
import '../core/app_routes.dart';
import '../core/dependencias.dart';
import '../core/formatos.dart';
import '../core/tema.dart';
import '../data/dados_mock.dart';
import '../model/barbeiro.dart';
import '../model/corte.dart';
import '../widgets/hud.dart';
import '../widgets/painel.dart';
import '../widgets/sa_botao.dart';

/// Funcionalidade: agendar horário — escolher barbeiro, 
/// serviço, dia da semana e horário livre.
class AgendarView extends StatelessWidget {
  const AgendarView({super.key});

  Future<void> _confirmar(BuildContext context) async {
    final ctrl = g<AgendamentoController>();
    final novo = await ctrl.confirmar();
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.confirmacao,
      arguments: novo,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = g<AgendamentoController>();

    return Scaffold(
      appBar: AppBar(title: const Text('AGENDAR HORÁRIO')),
      body: ListenableBuilder(
        listenable: ctrl,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.all(Espaco.s4),
          children: [
            const TituloSecao('1. Barbeiro'),
            _EscolhaBarbeiro(ctrl),
            const SizedBox(height: Espaco.s6),
            const TituloSecao('2. Serviço'),
            _EscolhaCorte(ctrl),
            const SizedBox(height: Espaco.s6),
            const TituloSecao('3. Dia'),
            _EscolhaDia(ctrl),
            const SizedBox(height: Espaco.s6),
            const TituloSecao('4. Horário'),
            _EscolhaHora(ctrl),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(Espaco.s4),
          decoration: const BoxDecoration(
            color: Cores.surface,
            border: Border(top: BorderSide(color: Cores.line, width: 2)),
          ),
          child: ListenableBuilder(
            listenable: ctrl,
            builder: (context, _) => Row(
              children: [
                if (ctrl.corte != null) ...[
                  PrecoHud(ctrl.corte!.preco, hud: false),
                  const SizedBox(width: Espaco.s4),
                ],
                Expanded(
                  child: SaBotao.primario(
                    rotulo: 'Confirmar',
                    icone: Icons.check,
                    carregando: ctrl.salvando,
                    aoPressionar: ctrl.podeConfirmar
                        ? () => _confirmar(context)
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Cartão selecionável usado nas escolhas de barbeiro e dia.
class _Opcao extends StatelessWidget {
  final bool selecionado;
  final bool habilitado;
  final VoidCallback onTap;
  final Widget child;
  final String rotuloSemantico;

  const _Opcao({
    required this.selecionado,
    required this.onTap,
    required this.child,
    required this.rotuloSemantico,
    this.habilitado = true,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selecionado,
      enabled: habilitado,
      label: rotuloSemantico,
      child: Opacity(
        opacity: habilitado ? 1 : 0.35,
        child: Container(
          decoration: BoxDecoration(
            color: selecionado ? Cores.groveSoft : Cores.surfaceRaised,
            border: Border.all(
              color: selecionado ? Cores.grove : Cores.lineStrong,
              width: selecionado ? 3 : 2,
            ),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(onTap: habilitado ? onTap : null, child: child),
          ),
        ),
      ),
    );
  }
}

/// Foto em tons de cinza quando o barbeiro não faz o serviço.
const _cinza = ColorFilter.matrix([
  0.2126, 0.7152, 0.0722, 0, 0,
  0.2126, 0.7152, 0.0722, 0, 0,
  0.2126, 0.7152, 0.0722, 0, 0,
  0, 0, 0, 1, 0,
]);
const _semFiltro = ColorFilter.mode(Colors.transparent, BlendMode.dst);

class _EscolhaBarbeiro extends StatelessWidget {
  final AgendamentoController ctrl;

  const _EscolhaBarbeiro(this.ctrl);

  @override
  Widget build(BuildContext context) {
    final barbeiros = g<BarbeiroController>().barbeiros;
    final corte = ctrl.corte;
    bool faz(Barbeiro b) => corte == null || b.cortes.contains(corte.id);
    final algumIndisponivel = !barbeiros.every(faz);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            for (final b in barbeiros) ...[
              if (b != barbeiros.first) const SizedBox(width: Espaco.s3),
              Expanded(
                child: _Opcao(
                  selecionado: ctrl.barbeiro?.id == b.id,
                  habilitado: faz(b),
                  rotuloSemantico:
                      'Barbeiro ${b.nome}'
                      '${faz(b) ? '' : ', não faz ${corte!.nome}'}',
                  onTap: () => ctrl.escolherBarbeiro(b),
                  child: Padding(
                    padding: const EdgeInsets.all(Espaco.s2),
                    child: Column(
                      children: [
                        AspectRatio(
                          aspectRatio: 1,
                          child: ColorFiltered(
                            colorFilter: faz(b) ? _semFiltro : _cinza,
                            child: FotoMoldura(
                              b.foto,
                              tamanho: double.infinity,
                            ),
                          ),
                        ),
                        const SizedBox(height: Espaco.s2),
                        Text(
                          b.nome.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Estilos.displayMd.copyWith(
                            fontSize: 16,
                            color: ctrl.barbeiro?.id == b.id
                                ? Cores.grove
                                : Cores.ink,
                          ),
                        ),
                        // Linha fixa para os cartões terem a mesma altura.
                        Text(
                          faz(b) ? ' ' : 'NÃO FAZ',
                          style: Estilos.label.copyWith(fontSize: 9),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        if (algumIndisponivel) ...[
          const SizedBox(height: Espaco.s2),
          Text(
            'Os apagados não fazem ${corte!.nome}. '
            'Troca ou desmarca o serviço pra liberar.',
            style: Estilos.bodySm,
          ),
        ],
      ],
    );
  }
}

class _EscolhaCorte extends StatelessWidget {
  final AgendamentoController ctrl;

  const _EscolhaCorte(this.ctrl);

  @override
  Widget build(BuildContext context) {
    final List<Corte> cortes = ctrl.barbeiro == null
        ? g<CorteController>().todos
        : g<BarbeiroController>().cortesDe(ctrl.barbeiro!);

    return Wrap(
      spacing: Espaco.s2,
      runSpacing: Espaco.s2,
      children: [
        for (final c in cortes)
          ChoiceChip(
            label: Text(
              '${c.nome.toUpperCase()} · ${Formatos.preco(c.preco)}',
            ),
            selected: ctrl.corte?.id == c.id,
            onSelected: (sel) => ctrl.escolherCorte(sel ? c : null),
          ),
      ],
    );
  }
}

class _EscolhaDia extends StatelessWidget {
  final AgendamentoController ctrl;

  const _EscolhaDia(this.ctrl);

  @override
  Widget build(BuildContext context) {
    final barbeiro = ctrl.barbeiro;
    if (barbeiro == null) {
      return const Text(
        'Escolhe o barbeiro primeiro.',
        style: Estilos.bodySm,
      );
    }

    final dias = ctrl.diasDaSemana;
    return Row(
      children: [
        for (var i = 0; i < dias.length; i++) ...[
          if (i > 0) const SizedBox(width: Espaco.s1),
          Expanded(
            child: Builder(
              builder: (context) {
                final d = dias[i];
                final atende = barbeiro.atendeNo(d);
                final sel = ctrl.dia == d;
                return _Opcao(
                  selecionado: sel,
                  habilitado: atende,
                  rotuloSemantico:
                      '${Formatos.dataLonga(d)}'
                      '${atende ? '' : ', sem atendimento'}',
                  onTap: () => ctrl.escolherDia(d),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: Espaco.s2),
                    child: Column(
                      children: [
                        Text(
                          i == 0 ? 'HOJE' : Formatos.diaCurto(d),
                          style: Estilos.label.copyWith(
                            fontSize: 9,
                            color: sel ? Cores.grove : Cores.inkMuted,
                          ),
                        ),
                        Text(
                          '${d.day}',
                          style: Estilos.displayMd.copyWith(
                            fontSize: 22,
                            color: sel ? Cores.grove : Cores.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

class _EscolhaHora extends StatelessWidget {
  final AgendamentoController ctrl;

  const _EscolhaHora(this.ctrl);

  @override
  Widget build(BuildContext context) {
    final barbeiro = ctrl.barbeiro;
    final dia = ctrl.dia;
    if (barbeiro == null || dia == null) {
      return const Text('Escolhe o barbeiro e o dia.', style: Estilos.bodySm);
    }

    final livres = DadosMock.horarios
        .where((h) => ctrl.horarioLivre(barbeiro, dia, h))
        .toList();
    if (livres.isEmpty) {
      return const Text(
        'Agenda lotada nesse dia. Tenta outro.',
        style: Estilos.bodySm,
      );
    }

    return Wrap(
      spacing: Espaco.s2,
      runSpacing: Espaco.s2,
      children: [
        for (final h in livres)
          ChoiceChip(
            key: ValueKey('hora-$h'),
            label: Text('${h.toString().padLeft(2, '0')}:00'),
            selected: ctrl.hora == h,
            onSelected: (_) => ctrl.escolherHora(h),
          ),
      ],
    );
  }
}
