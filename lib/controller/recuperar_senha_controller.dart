import 'package:flutter/material.dart';

import '../core/dependencias.dart';
import 'auth_controller.dart';

class RecuperarSenhaController extends ChangeNotifier {
  final _auth = g<AuthController>();

  bool carregando = false;

  /// E-mail para onde as instruções foram enviadas (null = ainda não enviou).
  String? emailEnviado;

  /// Simula o envio das instruções de redefinição. Retorna a mensagem de
  /// erro, ou `null` se deu certo.
  Future<String?> recuperar(String email) async {
    if (_auth.buscar(email) == null) {
      return 'Não achamos conta com esse e-mail.';
    }

    carregando = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    carregando = false;
    emailEnviado = email.trim();
    notifyListeners();
    return null;
  }

  void reiniciar() {
    emailEnviado = null;
    carregando = false;
  }
}
