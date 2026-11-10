import 'package:flutter/material.dart';

import '../core/dependencias.dart';
import '../core/erros.dart';
import 'auth_controller.dart';

class RecuperarSenhaController extends ChangeNotifier {
  final _auth = g<AuthController>();

  bool carregando = false;

  /// E-mail para onde as instruções foram enviadas (null = ainda não enviou).
  String? emailEnviado;

  /// Pede ao Firebase o e-mail de redefinição. Retorna a mensagem de erro, ou
  /// `null` se deu certo. Por segurança, o Firebase não revela se o e-mail tem
  /// conta, então um e-mail sem cadastro também conta como sucesso.
  Future<String?> recuperar(String email) async {
    carregando = true;
    notifyListeners();

    String? erro;
    try {
      await _auth.recuperarSenha(email);
      emailEnviado = email.trim();
    } on Exception catch (e) {
      erro = mensagemDeErro(e);
    }

    carregando = false;
    notifyListeners();
    return erro;
  }

  void reiniciar() {
    emailEnviado = null;
    carregando = false;
  }
}
