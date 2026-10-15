import 'package:flutter/material.dart';

import '../controller/agendamento_controller.dart';
import '../controller/barbeiro_controller.dart';
import '../controller/corte_controller.dart';
import '../core/app_routes.dart';
import '../core/dependencias.dart';
import '../core/formatos.dart';
import '../core/tema.dart';
import '../model/corte.dart';
import '../widgets/hud.dart';
import '../widgets/painel.dart';
import '../widgets/sa_botao.dart';

/// Funcionalidade: catálogo de cortes em grade (GridView), com filtro por
/// categoria e detalhes de cada serviço.
class CortesView extends StatelessWidget {
  const CortesView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = g<CorteController>();

    return ListenableBuilder(
      listenable: ctrl,
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(
              Espaco.s4,
              Espaco.s3,
              Espaco.s4,
              0,
            ),
            child: Row(
              children: [
                _Filtro('Todos', null, ctrl),
                for (final cat in CategoriaCorte.values)
                  _Filtro(cat.rotulo, cat, ctrl),
              ],
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) => GridView.builder(
                padding: const EdgeInsets.all(Espaco.s4),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: constraints.maxWidth > 600 ? 3 : 2,
                  mainAxisSpacing: Espaco.s4,
                  crossAxisSpacing: Espaco.s4,
                  mainAxisExtent: 268,
                ),
                itemCount: ctrl.cortes.length,
                itemBuilder: (context, i) => _CartaoCorte(ctrl.cortes[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Filtro extends StatelessWidget {
  final String rotulo;
  final CategoriaCorte? categoria;
  final CorteController ctrl;

  const _Filtro(this.rotulo, this.categoria, this.ctrl);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: Espaco.s2),
      child: ChoiceChip(
        label: Text(rotulo.toUpperCase()),
        selected: ctrl.categoria == categoria,
        onSelected: (_) => ctrl.filtrar(categoria),
      ),
    );
  }
}

class _CartaoCorte extends StatelessWidget {
  final Corte corte;

  const _CartaoCorte(this.corte);

  @override
  Widget build(BuildContext context) {
    final c = corte;
    return Painel(
      padding: const EdgeInsets.all(Espaco.s2),
      aoTocar: () => _mostrarDetalhes(context, c),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                FotoMoldura(c.imagem),
                if (c.destaque)
                  const Positioned(
                    top: Espaco.s1,
                    left: Espaco.s1,
                    child: Etiqueta('Em alta', tom: TomEtiqueta.gold),
                  ),
              ],
            ),
          ),
          const SizedBox(height: Espaco.s2),
          Text(
            c.nome.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Estilos.displayMd.copyWith(fontSize: 20),
          ),
          Text(Formatos.duracao(c.duracaoMin), style: Estilos.label),
          const SizedBox(height: Espaco.s1),
          PrecoHud(c.preco, hud: false, tamanho: 22),
        ],
      ),
    );
  }
}

void _mostrarDetalhes(BuildContext context, Corte c) {
  final barbeiros = g<BarbeiroController>().quemFaz(c);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Cores.surfaceRaised,
    shape: const RoundedRectangleBorder(
      side: BorderSide(color: Cores.frame, width: 3),
    ),
    builder: (sheet) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(Espaco.s4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FotoMoldura(c.imagem, tamanho: 96),
                const SizedBox(width: Espaco.s4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.nome.toUpperCase(),
                        style: Estilos.displayLg.copyWith(fontSize: 32),
                      ),
                      Text(
                        '${c.categoria.rotulo} · ${Formatos.duracao(c.duracaoMin)}'
                            .toUpperCase(),
                        style: Estilos.label,
                      ),
                      const SizedBox(height: Espaco.s2),
                      PrecoHud(c.preco),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: Espaco.s4),
            Text(c.descricao, style: Estilos.body),
            const SizedBox(height: Espaco.s4),
            const TituloSecao('Quem faz'),
            Wrap(
              spacing: Espaco.s2,
              runSpacing: Espaco.s2,
              children: [
                for (final b in barbeiros)
                  Etiqueta(b.nome, tom: TomEtiqueta.grove),
              ],
            ),
            const SizedBox(height: Espaco.s6),
            SaBotao.primario(
              rotulo: 'Agendar este corte',
              icone: Icons.event_available,
              aoPressionar: () {
                Navigator.pop(sheet);
                g<AgendamentoController>().iniciar(corte: c);
                Navigator.pushNamed(context, AppRoutes.agendar);
              },
            ),
          ],
        ),
      ),
    ),
  );
}
