import 'package:flutter/material.dart';

import '../controller/home_controller.dart';
import '../controller/login_controller.dart';
import '../core/app_routes.dart';
import '../core/dependencias.dart';
import '../core/tema.dart';
import '../core/validadores.dart';
import '../widgets/campo_texto.dart';
import '../widgets/mensagem.dart';
import '../widgets/sa_botao.dart';
import '../widgets/texto_contorno.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final ctrl = g<LoginController>();
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _senha = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _senha.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    FocusScope.of(context).unfocus();
    if (!_form.currentState!.validate()) return;

    final erro = await ctrl.entrar(_email.text, _senha.text);
    if (!mounted) return;
    if (erro != null) {
      mostrarMensagem(context, erro, erro: true);
      return;
    }

    g<HomeController>().reiniciar();
    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: Espaco.s4,
              vertical: Espaco.s6,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: ListenableBuilder(
                listenable: ctrl,
                builder: (context, _) => Form(
                  key: _form,
                  child: AutofillGroup(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Image.asset(
                            'assets/images/logo.png',
                            height: 150,
                            semanticLabel: 'Logotipo Old Reece Barbearia',
                          ),
                        ),
                        const SizedBox(height: Espaco.s6),
                        TextoContorno(
                          'BEM-VINDO DE VOLTA',
                          estilo: Estilos.displayMd.copyWith(color: Cores.ink),
                        ),
                        const SizedBox(height: Espaco.s1),
                        const Text(
                          'Entra aí pra marcar teu corte com o melhor do bairro.',
                          style: Estilos.bodySm,
                        ),
                        const SizedBox(height: Espaco.s6),
                        CampoTexto(
                          controller: _email,
                          rotulo: 'E-mail',
                          icone: Icons.alternate_email,
                          teclado: TextInputType.emailAddress,
                          validador: Validadores.email,
                          autofill: const [AutofillHints.email],
                        ),
                        const SizedBox(height: Espaco.s4),
                        CampoTexto(
                          controller: _senha,
                          rotulo: 'Senha',
                          icone: Icons.lock_outline,
                          senha: true,
                          senhaVisivel: ctrl.senhaVisivel,
                          aoAlternarSenha: ctrl.alternarSenha,
                          acao: TextInputAction.done,
                          aoEnviar: (_) => _entrar(),
                          validador: (v) => Validadores.obrigatorio(v, 'senha'),
                          autofill: const [AutofillHints.password],
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => Navigator.pushNamed(
                              context,
                              AppRoutes.recuperarSenha,
                            ),
                            child: const Text('ESQUECEU A SENHA?'),
                          ),
                        ),
                        const SizedBox(height: Espaco.s2),
                        SaBotao.primario(
                          rotulo: 'Entrar',
                          icone: Icons.login,
                          carregando: ctrl.carregando,
                          aoPressionar: _entrar,
                        ),
                        const SizedBox(height: Espaco.s6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Flexible(
                              child: Text(
                                'Ainda não tem conta?',
                                style: Estilos.bodySm,
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pushNamed(
                                context,
                                AppRoutes.cadastrarUsuario,
                              ),
                              child: const Text('CRIAR CONTA'),
                            ),
                          ],
                        ),
                        const SizedBox(height: Espaco.s4),
                        const Text(
                          'Conta de teste: cj@oldreece.com · 123456',
                          textAlign: TextAlign.center,
                          style: Estilos.caption,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
