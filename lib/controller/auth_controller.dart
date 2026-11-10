import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../core/dependencias.dart';
import '../model/usuario.dart';

/// Autentica no Firebase Authentication e guarda os dados de quem está logado,
/// lidos da coleção `usuarios` do Firestore.
class AuthController extends ChangeNotifier {
  final _auth = g<FirebaseAuth>();
  final _db = g<FirebaseFirestore>();

  Usuario? _usuario;

  Usuario? get usuario => _usuario;
  bool get logado => _usuario != null;

  /// Primeiro nome, usado nas saudações do app.
  String get primeiroNome => _usuario?.nome.trim().split(' ').first ?? '';

  DocumentReference<Map<String, dynamic>> _documento(String uid) =>
      _db.collection('usuarios').doc(uid);

  Future<Usuario> _carregar(String uid) async {
    final documento = await _documento(uid).get();
    final dados = documento.data();
    if (dados == null) {
      throw FirebaseException(
        plugin: 'old_reece',
        code: 'perfil-nao-encontrado',
      );
    }
    return Usuario.fromMap(uid, dados);
  }

  /// Recupera a sessão salva pelo Firebase ao abrir o app. Sem conexão, o app
  /// só começa pela tela de Login.
  Future<void> restaurarSessao() async {
    try {
      final atual = await _auth.authStateChanges().first;
      if (atual == null) return;
      _usuario = await _carregar(atual.uid).timeout(const Duration(seconds: 5));
    } on Exception {
      _usuario = null;
    }
  }

  Future<void> entrar(String email, String senha) async {
    final credencial = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: senha,
    );
    try {
      _usuario = await _carregar(credencial.user!.uid);
    } on Exception {
      await _auth.signOut();
      rethrow;
    }
    notifyListeners();
  }

  /// Cria a conta no Authentication e os dados na coleção `usuarios`. Se a
  /// gravação falhar, desfaz a conta para o e-mail poder ser usado de novo.
  Future<void> cadastrar({
    required String nome,
    required String email,
    required String telefone,
    required String cep,
    required String bairro,
    required String cidade,
    required String senha,
  }) async {
    final credencial = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: senha,
    );
    final conta = credencial.user!;
    final novo = Usuario(
      uid: conta.uid,
      nome: nome.trim(),
      email: conta.email ?? email.trim(),
      telefone: telefone.trim(),
      cep: cep.trim(),
      bairro: bairro.trim(),
      cidade: cidade.trim(),
    );

    try {
      await _documento(novo.uid).set({
        ...novo.toMap(),
        'criadoEm': FieldValue.serverTimestamp(),
      });
    } on Exception {
      await conta.delete();
      rethrow;
    }

    _usuario = novo;
    notifyListeners();
  }

  Future<void> recuperarSenha(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());

  Future<void> atualizarNome(String nome) async {
    final usuario = _usuario;
    if (usuario == null) return;
    await _documento(usuario.uid).update({'nome': nome.trim()});
    usuario.nome = nome.trim();
    notifyListeners();
  }

  Future<void> sair() async {
    await _auth.signOut();
    _usuario = null;
    notifyListeners();
  }
}
