import 'package:device_preview_plus/device_preview_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'controller/auth_controller.dart';
import 'core/app_routes.dart';
import 'core/dependencias.dart';
import 'core/tema.dart';
import 'model/agendamento.dart';
import 'model/barbeiro.dart';
import 'view/agendar_view.dart';
import 'view/avaliar_view.dart';
import 'view/barbeiro_detalhe_view.dart';
import 'view/cadastrar_usuario_view.dart';
import 'view/confirmacao_view.dart';
import 'view/home_view.dart';
import 'view/login_view.dart';
import 'view/perfil_view.dart';
import 'view/recuperar_senha_view.dart';
import 'view/sobre_view.dart';

void main() {
  configurarDependencias();
  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Old Reece',
      theme: criarTema(),
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      initialRoute: AppRoutes.login,
      onGenerateRoute: _gerarRota,
    );
  }

  /// Monta as rotas. Telas internas só abrem com usuário autenticado;
  /// sem login, o app volta para a tela de Login.
  static Route<dynamic> _gerarRota(RouteSettings rota) {
    final publica = switch (rota.name) {
      AppRoutes.login => const LoginView(),
      AppRoutes.cadastrarUsuario => const CadastrarUsuarioView(),
      AppRoutes.recuperarSenha => const RecuperarSenhaView(),
      AppRoutes.sobre => const SobreView(),
      _ => null,
    };

    final Widget tela;
    if (publica != null) {
      tela = publica;
    } else if (!g<AuthController>().logado) {
      tela = const LoginView();
    } else {
      final args = rota.arguments;
      tela = switch (rota.name) {
        AppRoutes.perfil => const PerfilView(),
        AppRoutes.agendar => const AgendarView(),
        AppRoutes.barbeiroDetalhe => BarbeiroDetalheView(
          barbeiro: args as Barbeiro,
        ),
        AppRoutes.confirmacao => ConfirmacaoView(
          agendamento: args as Agendamento,
        ),
        AppRoutes.avaliar => AvaliarView(agendamento: args as Agendamento),
        _ => const HomeView(),
      };
    }

    return MaterialPageRoute(builder: (_) => tela, settings: rota);
  }
}
