import 'package:flutter/material.dart';

import '../controller/barbeiro_controller.dart';
import '../core/app_routes.dart';
import '../core/dependencias.dart';
import '../core/tema.dart';
import '../model/barbeiro.dart';
import '../widgets/dados_ao_vivo.dart';
import '../widgets/hud.dart';
import '../widgets/painel.dart';

/// Funcionalidade: lista dos barbeiros (ListView), lida em tempo real da
/// coleção `barbeiros`.
class BarbeirosView extends StatelessWidget {
  const BarbeirosView({super.key});

  @override
  Widget build(BuildContext context) {
    return DadosAoVivo<List<Barbeiro>>(
      consulta: g<BarbeiroController>().observar,
      construtor: (context, lista) => ListView.separated(
        padding: const EdgeInsets.all(Espaco.s4),
        itemCount: lista.length,
        separatorBuilder: (_, _) => const SizedBox(height: Espaco.s3),
        itemBuilder: (context, i) => _CartaoBarbeiro(lista[i]),
      ),
    );
  }
}

class _CartaoBarbeiro extends StatelessWidget {
  final Barbeiro barbeiro;

  const _CartaoBarbeiro(this.barbeiro);

  @override
  Widget build(BuildContext context) {
    final b = barbeiro;
    return Painel(
      aoTocar: () =>
          Navigator.pushNamed(context, AppRoutes.barbeiroDetalhe, arguments: b),
      child: Row(
        children: [
          FotoMoldura(b.foto, tamanho: 80),
          const SizedBox(width: Espaco.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  b.nome.toUpperCase(),
                  style: Estilos.displayMd.copyWith(color: Cores.ink),
                ),
                Text(b.especialidade, style: Estilos.bodySm),
                const SizedBox(height: Espaco.s2),
                Estrelas(valor: b.estrelas, tamanho: 14),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Cores.inkMuted),
        ],
      ),
    );
  }
}
