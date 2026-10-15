import 'package:flutter/material.dart';

/// Campo de texto padrão do app, com botão de mostrar senha quando
/// [senha] é verdadeiro.
class CampoTexto extends StatelessWidget {
  final TextEditingController controller;
  final String rotulo;
  final IconData icone;
  final FormFieldValidator<String>? validador;
  final TextInputType? teclado;
  final TextInputAction acao;
  final bool senha;
  final bool senhaVisivel;
  final VoidCallback? aoAlternarSenha;
  final bool habilitado;
  final bool somenteLeitura;
  final ValueChanged<String>? aoEnviar;
  final Iterable<String>? autofill;

  const CampoTexto({
    super.key,
    required this.controller,
    required this.rotulo,
    required this.icone,
    this.validador,
    this.teclado,
    this.acao = TextInputAction.next,
    this.senha = false,
    this.senhaVisivel = false,
    this.aoAlternarSenha,
    this.habilitado = true,
    this.somenteLeitura = false,
    this.aoEnviar,
    this.autofill,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validador,
      keyboardType: teclado,
      textInputAction: acao,
      obscureText: senha && !senhaVisivel,
      enabled: habilitado,
      readOnly: somenteLeitura,
      onFieldSubmitted: aoEnviar,
      autofillHints: autofill,
      decoration: InputDecoration(
        labelText: rotulo,
        prefixIcon: Icon(icone),
        suffixIcon: senha
            ? IconButton(
                tooltip: senhaVisivel ? 'Esconder senha' : 'Mostrar senha',
                icon: Icon(
                  senhaVisivel ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: aoAlternarSenha,
              )
            : somenteLeitura
            ? const Tooltip(
                message: 'Não pode ser alterado',
                child: Icon(Icons.lock_outline),
              )
            : null,
      ),
    );
  }
}
