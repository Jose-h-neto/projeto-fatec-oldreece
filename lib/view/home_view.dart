import 'package:flutter/material.dart';

import '../controller/home_controller.dart';
import '../core/app_routes.dart';
import '../core/dependencias.dart';
import 'agendamentos_view.dart';
import 'barbeiros_view.dart';
import 'cortes_view.dart';
import 'inicio_view.dart';

/// Estrutura principal depois do login: barra superior com acesso ao
/// perfil e barra de navegação inferior com as quatro áreas do app.
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  static const _titulos = ['OLD REECE', 'BARBEIROS', 'CORTES', 'MINHA AGENDA'];

  @override
  Widget build(BuildContext context) {
    final home = g<HomeController>();

    return ListenableBuilder(
      listenable: home,
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: Text(_titulos[home.aba]),
          actions: [
            IconButton(
              tooltip: 'Meu perfil',
              icon: const Icon(Icons.account_circle_outlined),
              onPressed: () => Navigator.pushNamed(context, AppRoutes.perfil),
            ),
          ],
        ),
        body: IndexedStack(
          index: home.aba,
          children: const [
            InicioView(),
            BarbeirosView(),
            CortesView(),
            AgendamentosView(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: home.aba,
          onDestinationSelected: home.irPara,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Início',
            ),
            NavigationDestination(
              icon: Icon(Icons.people_outline),
              selectedIcon: Icon(Icons.people),
              label: 'Barbeiros',
            ),
            NavigationDestination(
              icon: Icon(Icons.content_cut_outlined),
              selectedIcon: Icon(Icons.content_cut),
              label: 'Cortes',
            ),
            NavigationDestination(
              icon: Icon(Icons.event_note_outlined),
              selectedIcon: Icon(Icons.event_note),
              label: 'Agenda',
            ),
          ],
        ),
      ),
    );
  }
}
