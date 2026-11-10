import 'dart:convert';

import 'package:http/http.dart' as http;

import '../model/endereco.dart';

/// Consulta endereços na API REST pública do ViaCEP (https://viacep.com.br).
class ViaCepService {
  final http.Client _cliente;

  ViaCepService(this._cliente);

  /// Busca o endereço de um CEP com 8 dígitos. Retorna `null` se o CEP não
  /// existe e lança uma exceção se a consulta falhar.
  Future<Endereco?> buscar(String cep) async {
    final resposta = await _cliente
        .get(Uri.https('viacep.com.br', '/ws/$cep/json/'))
        .timeout(const Duration(seconds: 8));

    if (resposta.statusCode != 200) {
      throw Exception('ViaCEP respondeu ${resposta.statusCode}');
    }

    final json =
        jsonDecode(utf8.decode(resposta.bodyBytes)) as Map<String, dynamic>;
    // CEP inexistente volta com status 200 e o campo "erro".
    if (json.containsKey('erro')) return null;
    return Endereco.fromJson(json);
  }
}
