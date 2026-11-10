import 'package:device_preview_plus/device_preview_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'controller/auth_controller.dart';
import 'core/app_routes.dart';
import 'core/dependencias.dart';
import 'core/tema.dart';
import 'firebase_options.dart';
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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Idioma dos e-mails enviados pelo Firebase, como o de redefinir a senha.
  await FirebaseAuth.instance.setLanguageCode('pt');

  configurarDependencias();
  await g<AuthController>().restaurarSessao();

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
      // Começa sempre em uma única tela, mesmo ao recarregar a página na web.
      onGenerateInitialRoutes: (_) => [
        _gerarRota(
          RouteSettings(
            name: g<AuthController>().logado ? AppRoutes.home : AppRoutes.login,
          ),
        ),
      ],
      onGenerateRoute: _gerarRota,
    );
  }

  /// Monta as rotas. Telas internas só abrem com usuário autenticado;
  /// sem login, o app volta para a tela de Login. Quem já está logado não vê
  /// o Login, e uma rota aberta sem os argumentos que precisa cai na Home.
  static Route<dynamic> _gerarRota(RouteSettings rota) {
    final logado = g<AuthController>().logado;
    final publica = switch (rota.name) {
      AppRoutes.login when !logado => const LoginView(),
      AppRoutes.cadastrarUsuario => const CadastrarUsuarioView(),
      AppRoutes.recuperarSenha => const RecuperarSenhaView(),
      AppRoutes.sobre => const SobreView(),
      _ => null,
    };

    final Widget tela;
    if (publica != null) {
      tela = publica;
    } else if (!logado) {
      tela = const LoginView();
    } else {
      final args = rota.arguments;
      tela = switch (rota.name) {
        AppRoutes.perfil => const PerfilView(),
        AppRoutes.agendar => const AgendarView(),
        AppRoutes.barbeiroDetalhe when args is Barbeiro => BarbeiroDetalheView(
          barbeiro: args,
        ),
        AppRoutes.confirmacao when args is Agendamento => ConfirmacaoView(
          agendamento: args,
        ),
        AppRoutes.avaliar when args is Agendamento => AvaliarView(
          agendamento: args,
        ),
        _ => const HomeView(),
      };
    }

    return MaterialPageRoute(builder: (_) => tela, settings: rota);
  }
}
