import 'package:flutter/material.dart';

import '../controller/sobre_controller.dart';
import '../core/dependencias.dart';
import '../core/tema.dart';
import '../widgets/painel.dart';

class SobreView extends StatelessWidget {
  const SobreView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = g<SobreController>();

    return Scaffold(
      appBar: AppBar(title: const Text('SOBRE')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(Espaco.s4),
          children: [
            Center(
              child: Image.asset(
                'assets/images/logo.png',
                height: 160,
                semanticLabel: 'Logotipo Old Reece Barbearia',
              ),
            ),
            const SizedBox(height: Espaco.s6),
            const TituloSecao('Objetivo'),
            Painel(child: Text(ctrl.objetivo, style: Estilos.body)),
            const SizedBox(height: Espaco.s6),
            const TituloSecao('Equipe de desenvolvimento'),
            Painel(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (final nome in ctrl.integrantes)
                    ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: Text(nome),
                    ),
                ],
              ),
            ),
            const SizedBox(height: Espaco.s6),
            const TituloSecao('Projeto'),
            Painel(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _Info(Icons.school_outlined, 'Disciplina', ctrl.disciplina),
                  _Info(
                    Icons.account_balance_outlined,
                    'Instituição',
                    ctrl.instituicao,
                  ),
                  _Info(Icons.badge_outlined, 'Professor', ctrl.professor),
                  _Info(Icons.info_outline, 'Versão', ctrl.versao),
                ],
              ),
            ),
            const SizedBox(height: Espaco.s6),
            const Text(
              'Projeto acadêmico sem fins comerciais. A estética é inspirada '
              'em GTA San Andreas, marca da Rockstar Games.',
              textAlign: TextAlign.center,
              style: Estilos.caption,
            ),
          ],
        ),
      ),
    );
  }
}

class _Info extends StatelessWidget {
  final IconData icone;
  final String rotulo;
  final String valor;

  const _Info(this.icone, this.rotulo, this.valor);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icone),
      title: Text(rotulo.toUpperCase(), style: Estilos.label),
      subtitle: Text(valor, style: Estilos.body),
    );
  }
}
