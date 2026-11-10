import 'package:flutter/material.dart';

import '../core/dependencias.dart';
import '../core/erros.dart';
import 'auth_controller.dart';

class PerfilController extends ChangeNotifier {
  final _auth = g<AuthController>();

  bool salvando = false;

  String get nome => _auth.usuario?.nome ?? '';
  String get email => _auth.usuario?.email ?? '';
  String get telefone => _auth.usuario?.telefone ?? '';
  String get cep => _auth.usuario?.cep ?? '';
  String get bairro => _auth.usuario?.bairro ?? '';
  String get cidade => _auth.usuario?.cidade ?? '';

  /// Salva o nome. Retorna a mensagem de erro, ou `null` se deu certo.
  Future<String?> salvar(String nome) async {
    salvando = true;
    notifyListeners();

    String? erro;
    try {
      await _auth.atualizarNome(nome);
    } on Exception catch (e) {
      erro = mensagemDeErro(e);
    }

    salvando = false;
    notifyListeners();
    return erro;
  }
}
