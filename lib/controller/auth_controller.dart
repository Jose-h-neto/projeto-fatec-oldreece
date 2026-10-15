import 'package:flutter/material.dart';

import '../model/usuario.dart';

/// Guarda os usuários cadastrados (em memória) e quem está autenticado.
class AuthController extends ChangeNotifier {
  final List<Usuario> _usuarios = [
    Usuario(
      nome: 'Carl Johnson',
      email: 'cj@oldreece.com',
      telefone: '(11) 91234-5678',
      senha: '123456',
    ),
  ];

  Usuario? _usuario;

  Usuario? get usuario => _usuario;
  bool get logado => _usuario != null;

  /// Primeiro nome, usado nas saudações do app.
  String get primeiroNome => _usuario?.nome.trim().split(' ').first ?? '';

  Usuario? buscar(String email) {
    final alvo = email.trim().toLowerCase();
    for (final u in _usuarios) {
      if (u.email.toLowerCase() == alvo) return u;
    }
    return null;
  }

  bool entrar(String email, String senha) {
    final u = buscar(email);
    if (u == null || u.senha != senha) return false;
    _usuario = u;
    notifyListeners();
    return true;
  }

  void cadastrar(Usuario novo) {
    _usuarios.add(novo);
    _usuario = novo;
    notifyListeners();
  }

  void atualizarNome(String nome) {
    if (_usuario == null) return;
    _usuario!.nome = nome.trim();
    notifyListeners();
  }

  void sair() {
    _usuario = null;
    notifyListeners();
  }
}
