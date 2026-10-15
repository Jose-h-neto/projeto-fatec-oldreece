import 'package:flutter/material.dart';

import '../core/dependencias.dart';
import '../model/usuario.dart';
import 'auth_controller.dart';

class CadastrarUsuarioController extends ChangeNotifier {
  final _auth = g<AuthController>();

  bool carregando = false;
  bool senhaVisivel = false;

  void alternarSenha() {
    senhaVisivel = !senhaVisivel;
    notifyListeners();
  }

  /// Cria a conta e já autentica o usuário. Retorna a mensagem de erro,
  /// ou `null` se deu certo.
  Future<String?> cadastrar({
    required String nome,
    required String email,
    required String telefone,
    required String senha,
  }) async {
    if (_auth.buscar(email) != null) {
      return 'Esse e-mail já tem conta. Tenta entrar.';
    }

    carregando = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));
    _auth.cadastrar(
      Usuario(
        nome: nome.trim(),
        email: email.trim(),
        telefone: telefone.trim(),
        senha: senha,
      ),
    );

    carregando = false;
    notifyListeners();
    return null;
  }
}
