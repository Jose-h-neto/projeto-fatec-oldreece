import 'package:flutter/material.dart';

import '../controller/auth_controller.dart';
import '../controller/perfil_controller.dart';
import '../core/app_routes.dart';
import '../core/dependencias.dart';
import '../core/tema.dart';
import '../core/validadores.dart';
import '../widgets/campo_texto.dart';
import '../widgets/hud.dart';
import '../widgets/mensagem.dart';
import '../widgets/painel.dart';
import '../widgets/sa_botao.dart';
import '../widgets/texto_contorno.dart';

class PerfilView extends StatefulWidget {
  const PerfilView({super.key});

  @override
  State<PerfilView> createState() => _PerfilViewState();
}

class _PerfilViewState extends State<PerfilView> {
  final ctrl = g<PerfilController>();
  final _form = GlobalKey<FormState>();
  late final _nome = TextEditingController(text: ctrl.nome);
  late final _email = TextEditingController(text: ctrl.email);
  late final _telefone = TextEditingController(text: ctrl.telefone);

  @override
  void dispose() {
    _nome.dispose();
    _email.dispose();
    _telefone.dispose();
    super.dispose();
  }

  String get _iniciais {
    final partes = ctrl.nome.trim().split(RegExp(r'\s+'));
    final letras = partes.where((p) => p.isNotEmpty).take(2).map((p) => p[0]);
    return letras.join().toUpperCase();
  }

  Future<void> _salvar() async {
    FocusScope.of(context).unfocus();
    if (!_form.currentState!.validate()) return;
    await ctrl.salvar(_nome.text);
    if (!mounted) return;
    mostrarMensagem(context, 'Perfil atualizado.');
  }

  Future<void> _sair() async {
    final ok = await confirmar(
      context,
      titulo: 'Sair da conta?',
      mensagem: 'Vai precisar entrar de novo pra agendar.',
      rotuloConfirmar: 'Sair',
      perigo: true,
    );
    if (!ok || !mounted) return;
    g<AuthController>().sair();
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MEU PERFIL')),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: ctrl,
          builder: (context, _) => ListView(
            padding: const EdgeInsets.all(Espaco.s4),
            children: [
              Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Cores.groveSoft,
                      border: Border.all(color: Cores.grove, width: 3),
                    ),
                    child: TextoContorno(
                      _iniciais,
                      estilo: Estilos.displayMd.copyWith(color: Cores.grove),
                    ),
                  ),
                  const SizedBox(width: Espaco.s4),
                  Expanded(child: TituloZona(ctrl.nome, tamanho: 30)),
                ],
              ),
              const SizedBox(height: Espaco.s6),
              Form(
                key: _form,
                child: Column(
                  children: [
                    CampoTexto(
                      controller: _nome,
                      rotulo: 'Nome',
                      icone: Icons.person_outline,
                      teclado: TextInputType.name,
                      acao: TextInputAction.done,
                      validador: Validadores.nome,
                      aoEnviar: (_) => _salvar(),
                    ),
                    const SizedBox(height: Espaco.s4),
                    CampoTexto(
                      controller: _email,
                      rotulo: 'E-mail',
                      icone: Icons.alternate_email,
                      somenteLeitura: true,
                    ),
                    const SizedBox(height: Espaco.s4),
                    CampoTexto(
                      controller: _telefone,
                      rotulo: 'Telefone',
                      icone: Icons.phone_outlined,
                      somenteLeitura: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Espaco.s6),
              SaBotao.primario(
                rotulo: 'Salvar',
                icone: Icons.save_outlined,
                carregando: ctrl.salvando,
                aoPressionar: _salvar,
              ),
              const SizedBox(height: Espaco.s8),
              Painel(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: const Text('Sobre o app'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.sobre),
                    ),
                    const Divider(height: 2, thickness: 2),
                    ListTile(
                      leading: const Icon(Icons.logout, color: Cores.health),
                      title: const Text(
                        'Sair da conta',
                        style: TextStyle(color: Cores.health),
                      ),
                      onTap: _sair,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
