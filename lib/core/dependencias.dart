import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

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
import '../service/viacep_service.dart';

final g = GetIt.instance;

/// Os parâmetros permitem trocar o acesso à rede e ao Firebase nos testes.
void configurarDependencias({
  http.Client? clienteHttp,
  FirebaseAuth? auth,
  FirebaseFirestore? firestore,
}) {
  g.registerSingleton<FirebaseAuth>(auth ?? FirebaseAuth.instance);
  g.registerSingleton<FirebaseFirestore>(
    firestore ?? FirebaseFirestore.instance,
  );
  g.registerSingleton<ViaCepService>(
    ViaCepService(clienteHttp ?? http.Client()),
  );

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
