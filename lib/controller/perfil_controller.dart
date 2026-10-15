import 'package:flutter/material.dart';

import '../core/dependencias.dart';
import 'auth_controller.dart';

class PerfilController extends ChangeNotifier {
  final _auth = g<AuthController>();

  bool salvando = false;

  String get nome => _auth.usuario?.nome ?? '';
  String get email => _auth.usuario?.email ?? '';
  String get telefone => _auth.usuario?.telefone ?? '';

  Future<void> salvar(String nome) async {
    salvando = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));
    _auth.atualizarNome(nome);

    salvando = false;
    notifyListeners();
  }
}
