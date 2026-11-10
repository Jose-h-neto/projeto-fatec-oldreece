import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:old_reece/core/validadores.dart';
import 'package:old_reece/service/viacep_service.dart';

void main() {
  group('Validadores.senha', () {
    test('aceita senha com todos os critérios', () {
      expect(Validadores.senha('Abcdef@1'), isNull);
    });

    test('rejeita cada critério que falta', () {
      expect(Validadores.senha(''), contains('Preenche'));
      expect(Validadores.senha('Ab@1'), contains('8 caracteres'));
      expect(Validadores.senha('abcdef@1'), contains('maiúscula'));
      expect(Validadores.senha('ABCDEF@1'), contains('minúscula'));
      expect(Validadores.senha('Abcdefg1'), contains('especial'));
    });

    test('espaço e letra acentuada não contam como caractere especial', () {
      expect(Validadores.senha('Abc defg'), contains('especial'));
      expect(Validadores.senha('Ábcdéfgh'), contains('especial'));
    });
  });

  group('Validadores.cep', () {
    test('aceita 8 dígitos, com ou sem traço', () {
      expect(Validadores.cep('01001-000'), isNull);
      expect(Validadores.cep('01001000'), isNull);
    });

    test('rejeita vazio e tamanho errado', () {
      expect(Validadores.cep(''), contains('Preenche'));
      expect(Validadores.cep('0100'), contains('8 números'));
    });
  });

  group('ViaCepService', () {
    http.Response resposta(String corpo, [int status = 200]) =>
        http.Response.bytes(utf8.encode(corpo), status);

    test('consulta a URL certa e lê bairro e cidade com acento', () async {
      late Uri chamada;
      final servico = ViaCepService(
        MockClient((req) async {
          chamada = req.url;
          return resposta('{"bairro": "Sé", "localidade": "São Paulo"}');
        }),
      );

      final endereco = await servico.buscar('01001000');

      expect(chamada.toString(), 'https://viacep.com.br/ws/01001000/json/');
      expect(endereco?.bairro, 'Sé');
      expect(endereco?.cidade, 'São Paulo');
    });

    test('retorna null quando o CEP não existe', () async {
      final servico = ViaCepService(
        MockClient((_) async => resposta('{"erro": "true"}')),
      );

      expect(await servico.buscar('99999999'), isNull);
    });

    test('lança exceção quando a API falha', () async {
      final servico = ViaCepService(
        MockClient((_) async => resposta('', 500)),
      );

      expect(servico.buscar('01001000'), throwsException);
    });
  });
}
