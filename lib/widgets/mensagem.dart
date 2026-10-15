import 'package:flutter/material.dart';

import '../core/tema.dart';

/// Mostra uma mensagem curta no rodapé, no tom do app.
void mostrarMensagem(BuildContext context, String texto, {bool erro = false}) {
  final cor = erro ? Cores.health : Cores.grove;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        shape: RoundedRectangleBorder(side: BorderSide(color: cor, width: 2)),
        content: Row(
          children: [
            Icon(
              erro ? Icons.error_outline : Icons.check_circle_outline,
              color: cor,
            ),
            const SizedBox(width: Espaco.s3),
            Expanded(child: Text(texto)),
          ],
        ),
      ),
    );
}

/// Diálogo de confirmação. Retorna `true` se o usuário confirmar.
Future<bool> confirmar(
  BuildContext context, {
  required String titulo,
  required String mensagem,
  required String rotuloConfirmar,
  bool perigo = false,
}) async {
  final resposta = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(titulo.toUpperCase()),
      content: Text(mensagem),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          style: TextButton.styleFrom(foregroundColor: Cores.inkMuted),
          child: const Text('VOLTAR'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(
            foregroundColor: perigo ? Cores.health : Cores.grove,
          ),
          child: Text(rotuloConfirmar.toUpperCase()),
        ),
      ],
    ),
  );
  return resposta ?? false;
}
