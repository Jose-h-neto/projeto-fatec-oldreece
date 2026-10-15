import 'package:flutter/material.dart';

import '../controller/cadastrar_usuario_controller.dart';
import '../controller/home_controller.dart';
import '../core/app_routes.dart';
import '../core/dependencias.dart';
import '../core/tema.dart';
import '../core/validadores.dart';
import '../widgets/campo_texto.dart';
import '../widgets/mensagem.dart';
import '../widgets/sa_botao.dart';
import '../widgets/texto_contorno.dart';

class CadastrarUsuarioView extends StatefulWidget {
  const CadastrarUsuarioView({super.key});

  @override
  State<CadastrarUsuarioView> createState() => _CadastrarUsuarioViewState();
}

class _CadastrarUsuarioViewState extends State<CadastrarUsuarioView> {
  final ctrl = g<CadastrarUsuarioController>();
  final _form = GlobalKey<FormState>();
  final _nome = TextEditingController();
  final _email = TextEditingController();
  final _telefone = TextEditingController();
  final _senha = TextEditingController();
  final _confirmacao = TextEditingController();

  @override
  void dispose() {
    for (final c in [_nome, _email, _telefone, _senha, _confirmacao]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _cadastrar() async {
    FocusScope.of(context).unfocus();
    if (!_form.currentState!.validate()) return;

    final erro = await ctrl.cadastrar(
      nome: _nome.text,
      email: _email.text,
      telefone: _telefone.text,
      senha: _senha.text,
    );
    if (!mounted) return;
    if (erro != null) {
      mostrarMensagem(context, erro, erro: true);
      return;
    }

    g<HomeController>().reiniciar();
    mostrarMensagem(context, 'Conta criada. Bem-vindo ao bairro!');
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CRIAR CONTA')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Espaco.s4),
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
                        TextoContorno(
                          'ENTRA PRA FAMÍLIA',
                          estilo: Estilos.displayMd.copyWith(
                            color: Cores.grove,
                          ),
                        ),
                        const SizedBox(height: Espaco.s1),
                        const Text(
                          'Preenche teus dados pra começar a agendar.',
                          style: Estilos.bodySm,
                        ),
                        const SizedBox(height: Espaco.s6),
                        CampoTexto(
                          controller: _nome,
                          rotulo: 'Nome',
                          icone: Icons.person_outline,
                          teclado: TextInputType.name,
                          validador: Validadores.nome,
                          autofill: const [AutofillHints.name],
                        ),
                        const SizedBox(height: Espaco.s4),
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
                          controller: _telefone,
                          rotulo: 'Telefone com DDD',
                          icone: Icons.phone_outlined,
                          teclado: TextInputType.phone,
                          validador: Validadores.telefone,
                          autofill: const [AutofillHints.telephoneNumber],
                        ),
                        const SizedBox(height: Espaco.s4),
                        CampoTexto(
                          controller: _senha,
                          rotulo: 'Senha',
                          icone: Icons.lock_outline,
                          senha: true,
                          senhaVisivel: ctrl.senhaVisivel,
                          aoAlternarSenha: ctrl.alternarSenha,
                          validador: Validadores.senha,
                          autofill: const [AutofillHints.newPassword],
                        ),
                        const SizedBox(height: Espaco.s4),
                        CampoTexto(
                          controller: _confirmacao,
                          rotulo: 'Confirmar senha',
                          icone: Icons.lock_reset,
                          senha: true,
                          senhaVisivel: ctrl.senhaVisivel,
                          aoAlternarSenha: ctrl.alternarSenha,
                          acao: TextInputAction.done,
                          aoEnviar: (_) => _cadastrar(),
                          validador: (v) =>
                              Validadores.confirmacaoSenha(v, _senha.text),
                        ),
                        const SizedBox(height: Espaco.s6),
                        SaBotao.primario(
                          rotulo: 'Criar conta',
                          icone: Icons.how_to_reg,
                          carregando: ctrl.carregando,
                          aoPressionar: _cadastrar,
                        ),
                        const SizedBox(height: Espaco.s4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Flexible(
                              child: Text(
                                'Já tem conta?',
                                style: Estilos.bodySm,
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('ENTRAR'),
                            ),
                          ],
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
