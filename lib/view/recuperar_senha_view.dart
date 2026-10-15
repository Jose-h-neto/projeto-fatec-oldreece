import 'package:flutter/material.dart';

import '../controller/recuperar_senha_controller.dart';
import '../core/dependencias.dart';
import '../core/tema.dart';
import '../core/validadores.dart';
import '../widgets/campo_texto.dart';
import '../widgets/mensagem.dart';
import '../widgets/painel.dart';
import '../widgets/sa_botao.dart';
import '../widgets/texto_contorno.dart';

class RecuperarSenhaView extends StatefulWidget {
  const RecuperarSenhaView({super.key});

  @override
  State<RecuperarSenhaView> createState() => _RecuperarSenhaViewState();
}

class _RecuperarSenhaViewState extends State<RecuperarSenhaView> {
  final ctrl = g<RecuperarSenhaController>();
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();

  @override
  void initState() {
    super.initState();
    ctrl.reiniciar();
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _recuperar() async {
    FocusScope.of(context).unfocus();
    if (!_form.currentState!.validate()) return;

    final erro = await ctrl.recuperar(_email.text);
    if (!mounted) return;
    if (erro != null) mostrarMensagem(context, erro, erro: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('RECUPERAR SENHA')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Espaco.s4),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: ListenableBuilder(
                listenable: ctrl,
                builder: (context, _) => ctrl.emailEnviado == null
                    ? _formulario()
                    : _enviado(ctrl.emailEnviado!),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _formulario() {
    return Form(
      key: _form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.key, size: 56, color: Cores.gold),
          const SizedBox(height: Espaco.s4),
          TextoContorno(
            'ESQUECEU A SENHA?',
            estilo: Estilos.displayMd.copyWith(color: Cores.ink),
          ),
          const SizedBox(height: Espaco.s1),
          const Text(
            'Relaxa. Informa o e-mail da tua conta que a gente manda as '
            'instruções pra criar uma senha nova.',
            style: Estilos.bodySm,
          ),
          const SizedBox(height: Espaco.s6),
          CampoTexto(
            controller: _email,
            rotulo: 'E-mail cadastrado',
            icone: Icons.alternate_email,
            teclado: TextInputType.emailAddress,
            acao: TextInputAction.done,
            aoEnviar: (_) => _recuperar(),
            validador: Validadores.email,
          ),
          const SizedBox(height: Espaco.s6),
          SaBotao.primario(
            rotulo: 'Enviar instruções',
            icone: Icons.send,
            carregando: ctrl.carregando,
            aoPressionar: _recuperar,
          ),
        ],
      ),
    );
  }

  Widget _enviado(String email) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Painel(
          destaque: true,
          child: Column(
            children: [
              const Icon(
                Icons.mark_email_read_outlined,
                size: 56,
                color: Cores.grove,
              ),
              const SizedBox(height: Espaco.s3),
              TextoContorno(
                'E-MAIL ENVIADO!',
                estilo: Estilos.displayMd.copyWith(color: Cores.goldFill),
              ),
              const SizedBox(height: Espaco.s2),
              Text(
                'Mandamos as instruções de redefinição para $email. '
                'Dá uma olhada na caixa de entrada e no spam.',
                textAlign: TextAlign.center,
                style: Estilos.body,
              ),
            ],
          ),
        ),
        const SizedBox(height: Espaco.s6),
        SaBotao.primario(
          rotulo: 'Voltar ao login',
          icone: Icons.arrow_back,
          aoPressionar: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
