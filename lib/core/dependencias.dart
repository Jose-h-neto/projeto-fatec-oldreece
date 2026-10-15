import 'package:get_it/get_it.dart';

import '../controller/agendamento_controller.dart';
import '../controller/auth_controller.dart';
import '../controller/barbeiro_controller.dart';
import '../controller/cadastrar_usuario_controller.dart';
import '../controller/corte_controller.dart';
import '../controller/home_controller.dart';
import '../controller/login_controller.dart';
import '../controller/perfil_controller.dart';
import '../controller/recuperar_senha_controller.dart';
import '../controller/sobre_controller.dart';

final g = GetIt.instance;

void configurarDependencias() {
  g.registerSingleton<AuthController>(AuthController());

  g.registerSingleton<CadastrarUsuarioController>(CadastrarUsuarioController());
  g.registerSingleton<LoginController>(LoginController());
  g.registerSingleton<PerfilController>(PerfilController());
  g.registerSingleton<RecuperarSenhaController>(RecuperarSenhaController());
  g.registerSingleton<SobreController>(SobreController());

  g.registerSingleton<HomeController>(HomeController());
  g.registerSingleton<BarbeiroController>(BarbeiroController());
  g.registerSingleton<CorteController>(CorteController());
  g.registerSingleton<AgendamentoController>(AgendamentoController());
}
