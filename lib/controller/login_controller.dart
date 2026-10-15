import 'package:flutter/material.dart';

import '../core/dependencias.dart';
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

    await Future.delayed(const Duration(milliseconds: 600));
    final ok = _auth.entrar(email, senha);

    carregando = false;
    notifyListeners();
    return ok ? null : 'E-mail ou senha errados. Tenta de novo, mano.';
  }
}
