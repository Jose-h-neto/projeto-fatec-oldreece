import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mock_exceptions/mock_exceptions.dart';
import 'package:old_reece/controller/auth_controller.dart';
import 'package:old_reece/core/dependencias.dart';
import 'package:old_reece/main.dart';
import 'package:old_reece/widgets/sa_botao.dart';

import 'dados_teste.dart';

/// Coloca o catálogo no banco falso, na mesma ordem usada no Firestore real.
Future<void> popularCatalogo(FirebaseFirestore firestore) async {
  for (final (i, c) in DadosTeste.cortes.indexed) {
    await firestore.collection('cortes').doc(c.id).set({
      ...c.toMap(),
      'ordem': i,
    });
  }
  for (final (i, b) in DadosTeste.barbeiros.indexed) {
    await firestore.collection('barbeiros').doc(b.id).set({
      ...b.toMap(),
      'ordem': i,
    });
  }
}

Finder botao(String rotulo) =>
    find.descendant(of: find.byType(SaBotao), matching: find.text(rotulo));

Future<void> tocar(WidgetTester tester, Finder alvo) async {
  await tester.ensureVisible(alvo);
  await tester.pumpAndSettle();
  await tester.tap(alvo);
  await tester.pumpAndSettle();
}

void main() {
  late MockFirebaseAuth auth;

  /// Sobe o app com Firebase e ViaCEP falsos e o cliente CJ já cadastrado.
  setUp(() async {
    await g.reset();
    auth = MockFirebaseAuth(
      mockUser: MockUser(uid: 'cj', email: 'cj@oldreece.com'),
    );
    final firestore = FakeFirebaseFirestore();
    await firestore.collection('usuarios').doc('cj').set({
      'nome': 'Carl Johnson',
      'email': 'cj@oldreece.com',
      'telefone': '(11) 91234-5678',
      'cep': '01001-000',
      'bairro': 'Sé',
      'cidade': 'São Paulo',
    });
    await popularCatalogo(firestore);
    configurarDependencias(
      firestore: firestore,
      auth: auth,
      clienteHttp: MockClient(
        (_) async => http.Response.bytes(
          utf8.encode('{"bairro": "Sé", "localidade": "São Paulo"}'),
          200,
        ),
      ),
    );
  });

  testWidgets('login mostra o erro do Firebase e continua na tela', (
    tester,
  ) async {
    whenCalling(
      Invocation.method(#signInWithEmailAndPassword, null),
    ).on(auth).thenThrow(FirebaseAuthException(code: 'invalid-credential'));
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.6;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MainApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'cj@oldreece.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'senha-errada');
    await tocar(tester, find.text('ENTRAR'));

    expect(
      find.text('E-mail ou senha errados. Tenta de novo, mano.'),
      findsOneWidget,
    );
    expect(g<AuthController>().logado, isFalse);
    expect(find.text('BEM-VINDO DE VOLTA'), findsWidgets);
  });

  testWidgets('cadastro mostra quando o e-mail já tem conta', (tester) async {
    whenCalling(
      Invocation.method(#createUserWithEmailAndPassword, null),
    ).on(auth).thenThrow(FirebaseAuthException(code: 'email-already-in-use'));
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.6;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MainApp());
    await tester.pumpAndSettle();

    await tocar(tester, find.text('CRIAR CONTA'));
    final campos = find.byType(TextFormField);
    await tester.enterText(campos.at(0), 'Carl Johnson');
    await tester.enterText(campos.at(1), 'cj@oldreece.com');
    await tester.enterText(campos.at(2), '11912345678');
    await tester.enterText(campos.at(3), '01001-000');
    await tester.pumpAndSettle();
    await tester.enterText(campos.at(6), 'Abcdef@1');
    await tester.enterText(campos.at(7), 'Abcdef@1');
    await tocar(tester, botao('CRIAR CONTA'));

    expect(find.text('Esse e-mail já tem conta. Tenta entrar.'), findsOneWidget);
    expect(g<AuthController>().logado, isFalse);
  });

  testWidgets('login valida campos vazios e e-mail inválido', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.6;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MainApp());
    await tester.pumpAndSettle();

    await tocar(tester, find.text('ENTRAR'));
    expect(find.text('Preenche o campo e-mail, mano.'), findsOneWidget);
    expect(find.text('Preenche o campo senha, mano.'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'cj@');
    await tocar(tester, find.text('ENTRAR'));
    expect(
      find.text('Esse e-mail tá estranho. Confere o formato.'),
      findsOneWidget,
    );
  });

  testWidgets('fluxo completo: login, agendar, cancelar, perfil', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.6;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MainApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'cj@oldreece.com');
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tocar(tester, find.text('ENTRAR'));

    // Início
    expect(find.text('E aí, Carl'), findsWidgets);
    expect(find.text('Nenhum horário marcado ainda.'), findsOneWidget);

    // Agendar
    await tocar(tester, botao('AGENDAR HORÁRIO').first);
    expect(find.text('1. BARBEIRO'), findsOneWidget);
    await tocar(tester, find.text('OLD REECE').last);
    await tocar(tester, find.textContaining('HIGH FADE').first);

    // Primeiro dia em que o Reece atende e primeiro horário livre.
    final dias = find.descendant(
      of: find.byType(ListView).first,
      matching: find.byWidgetPredicate(
        (w) =>
            w is Semantics &&
            w.properties.enabled == true &&
            w.properties.button == true &&
            (w.properties.label ?? '').contains(', ') &&
            !(w.properties.label ?? '').startsWith('Barbeiro'),
      ),
    );
    expect(dias, findsWidgets);
    await tocar(tester, dias.at(1));

    // Só os horários livres aparecem, cada um com a chave "hora-<h>".
    final livres = find.byWidgetPredicate(
      (w) =>
          w is ChoiceChip &&
          w.key is ValueKey<String> &&
          (w.key as ValueKey<String>).value.startsWith('hora-'),
    );
    expect(livres, findsWidgets);
    await tocar(tester, livres.first);

    await tocar(tester, botao('CONFIRMAR'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('MISSÃO CUMPRIDA!'), findsWidgets);

    // Agenda
    await tocar(tester, find.text('VER MINHA AGENDA'));
    expect(find.text('MINHA AGENDA'), findsOneWidget);
    expect(find.text('CANCELAR'), findsOneWidget);

    await tocar(tester, find.text('CANCELAR'));
    await tocar(tester, find.text('CANCELAR HORÁRIO'));
    expect(find.text('CANCELAR'), findsNothing);

    // Perfil: nome curto é rejeitado; nome válido atualiza o app.
    await tocar(tester, find.byTooltip('Meu perfil'));
    await tester.enterText(find.byType(TextFormField).first, 'CJ');
    await tocar(tester, botao('SALVAR'));
    expect(find.text('O nome precisa de pelo menos 3 letras.'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, 'Carlão Johnson');
    await tocar(tester, botao('SALVAR'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(g<AuthController>().usuario?.nome, 'Carlão Johnson');
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tocar(tester, find.text('Início'));
    await tester.drag(find.byType(ListView).first, const Offset(0, 3000));
    await tester.pumpAndSettle();
    expect(find.text('E aí, Carlão'), findsWidgets);
  });

  testWidgets('barbeiro que não faz o serviço escolhido fica indisponível', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.6;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MainApp());
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'cj@oldreece.com');
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tocar(tester, find.text('ENTRAR'));

    // High Fade (em alta) não é feito pelo Ryder.
    await tocar(tester, find.text('HIGH FADE').first);
    expect(find.text('NÃO FAZ'), findsOneWidget);
    expect(
      find.text('Os apagados não fazem High Fade. '
          'Troca ou desmarca o serviço pra liberar.'),
      findsOneWidget,
    );

    // Desmarcar o serviço libera todo mundo.
    await tocar(tester, find.textContaining('HIGH FADE').first);
    expect(find.text('NÃO FAZ'), findsNothing);
  });

  testWidgets('telas de barbeiros, cortes, cadastro, recuperar e sobre abrem', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.6;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MainApp());
    await tester.pumpAndSettle();

    await tocar(tester, find.text('ESQUECEU A SENHA?'));
    await tester.enterText(find.byType(TextFormField).first, 'cj@oldreece.com');
    await tocar(tester, find.text('ENVIAR INSTRUÇÕES'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('E-MAIL ENVIADO!'), findsWidgets);
    await tocar(tester, find.text('VOLTAR AO LOGIN'));

    await tocar(tester, find.text('CRIAR CONTA'));
    final campos = find.byType(TextFormField);
    await tester.enterText(campos.at(0), 'Sweet Johnson');
    await tester.enterText(campos.at(1), 'sweet@grove.com');
    await tester.enterText(campos.at(2), '11912345678');

    // CEP completo preenche bairro e cidade pelo ViaCEP.
    await tester.enterText(campos.at(3), '01001-000');
    await tester.pumpAndSettle();
    expect(find.text('Sé'), findsOneWidget);
    expect(find.text('São Paulo'), findsOneWidget);

    await tester.enterText(campos.at(6), 'abcdefgh');
    await tester.enterText(campos.at(7), 'abcdefgh');
    await tocar(tester, botao('CRIAR CONTA'));
    expect(
      find.text('A senha precisa de pelo menos uma letra maiúscula.'),
      findsOneWidget,
    );
    await tester.enterText(campos.at(6), 'Abcdef@1');
    await tester.enterText(campos.at(7), 'Abcdef@X');
    await tocar(tester, botao('CRIAR CONTA'));
    expect(find.text('As senhas não batem.'), findsOneWidget);
    await tester.enterText(campos.at(7), 'Abcdef@1');
    await tocar(tester, botao('CRIAR CONTA'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('E aí, Sweet'), findsWidgets);

    // Os campos extras ficam na coleção "usuarios" do Firestore.
    final documento = await g<FirebaseFirestore>()
        .collection('usuarios')
        .doc(g<AuthController>().usuario!.uid)
        .get();
    expect(documento.data(), containsPair('nome', 'Sweet Johnson'));
    expect(documento.data(), containsPair('telefone', '11912345678'));
    expect(documento.data(), containsPair('cep', '01001-000'));
    expect(documento.data(), containsPair('bairro', 'Sé'));
    expect(documento.data(), containsPair('cidade', 'São Paulo'));

    await tocar(tester, find.text('Barbeiros'));
    expect(find.text('CÉSAR'), findsWidgets);
    await tocar(tester, find.text('RYDER').first);
    expect(find.text('AGENDAR COM RYDER'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tocar(tester, find.text('Cortes'));
    await tocar(tester, find.text('BARBA'));
    expect(find.text('MOICANO'), findsNothing);
    await tocar(tester, find.text('BIGODE'));
    expect(find.text('AGENDAR ESTE CORTE'), findsOneWidget);
    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();

    await tocar(tester, find.byTooltip('Meu perfil'));
    await tocar(tester, find.text('Sobre o app'));
    expect(find.text('OBJETIVO'), findsOneWidget);
  });
}
