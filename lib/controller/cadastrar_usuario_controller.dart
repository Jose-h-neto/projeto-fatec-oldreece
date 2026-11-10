import 'package:flutter/material.dart';

import '../core/dependencias.dart';
import '../core/erros.dart';
import '../model/endereco.dart';
import '../service/viacep_service.dart';
import 'auth_controller.dart';

class CadastrarUsuarioController extends ChangeNotifier {
  final _auth = g<AuthController>();
  final _viaCep = g<ViaCepService>();

  bool carregando = false;
  bool senhaVisivel = false;
  bool buscandoCep = false;

  /// Último endereço encontrado pelo CEP.
  Endereco? endereco;

  void alternarSenha() {
    senhaVisivel = !senhaVisivel;
    notifyListeners();
  }

  /// Consulta o CEP (só dígitos) e guarda o resultado em [endereco]. Retorna
  /// a mensagem de erro, ou `null` se deu certo.
  Future<String?> buscarCep(String cep) async {
    buscandoCep = true;
    notifyListeners();

    String? erro;
    try {
      endereco = await _viaCep.buscar(cep);
      if (endereco == null) erro = 'Não achamos esse CEP. Confere o número.';
    } on Exception {
      erro = 'Não deu pra buscar o CEP agora. Preenche o bairro e a cidade.';
    }

    buscandoCep = false;
    notifyListeners();
    return erro;
  }

  /// Cria a conta e já autentica o usuário. Retorna a mensagem de erro,
  /// ou `null` se deu certo.
  Future<String?> cadastrar({
    required String nome,
    required String email,
    required String telefone,
    required String cep,
    required String bairro,
    required String cidade,
    required String senha,
  }) async {
    carregando = true;
    notifyListeners();

    String? erro;
    try {
      await _auth.cadastrar(
        nome: nome,
        email: email,
        telefone: telefone,
        cep: cep,
        bairro: bairro,
        cidade: cidade,
        senha: senha,
      );
    } on Exception catch (e) {
      erro = mensagemDeErro(e);
    }

    carregando = false;
    notifyListeners();
    return erro;
  }
}
