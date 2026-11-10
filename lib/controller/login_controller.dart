import 'package:flutter/material.dart';

import '../core/dependencias.dart';
import '../core/erros.dart';
import 'auth_controller.dart';

class LoginController extends ChangeNotifier {
  final _auth = g<AuthController>();

  bool carregando = false;
  bool senhaVisivel = false;

  void alternarSenha() {
    senhaVisivel = !senhaVisivel;
    notifyListeners();
  }

  /// Tenta autenticar. Retorna a mensagem de erro, ou `null` se deu certo.
  Future<String?> entrar(String email, String senha) async {
    carregando = true;
    notifyListeners();

    String? erro;
    try {
      await _auth.entrar(email, senha);
    } on Exception catch (e) {
      erro = mensagemDeErro(e);
    }

    carregando = false;
    notifyListeners();
    return erro;
  }
}
