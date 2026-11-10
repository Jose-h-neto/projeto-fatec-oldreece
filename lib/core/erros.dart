import 'package:firebase_core/firebase_core.dart';

/// Traduz os erros do Firebase para mensagens que o usuário entende.
String mensagemDeErro(Object erro) {
  final codigo = erro is FirebaseException ? erro.code : null;
  return switch (codigo) {
    'invalid-credential' ||
    'wrong-password' ||
    'user-not-found' => 'E-mail ou senha errados. Tenta de novo, mano.',
    'email-already-in-use' => 'Esse e-mail já tem conta. Tenta entrar.',
    'invalid-email' => 'Esse e-mail tá estranho. Confere o formato.',
    'weak-password' => 'Essa senha tá fraca. Escolhe uma mais forte.',
    'user-disabled' => 'Essa conta foi desativada.',
    'too-many-requests' => 'Muitas tentativas. Espera um pouco e tenta de novo.',
    'network-request-failed' ||
    'unavailable' => 'Sem conexão. Confere a internet e tenta de novo.',
    'permission-denied' => 'Tu não tem permissão pra fazer isso.',
    'perfil-nao-encontrado' => 'Não achamos os dados da tua conta.',
    _ => 'Deu ruim aqui do nosso lado. Tenta de novo.',
  };
}
