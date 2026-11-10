import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:old_reece/controller/agendamento_controller.dart';
import 'package:old_reece/controller/auth_controller.dart';
import 'package:old_reece/core/dependencias.dart';
import 'package:old_reece/model/agendamento.dart';
import 'package:old_reece/widgets/dados_ao_vivo.dart';

import 'dados_teste.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late AgendamentoController ctrl;
  final amanha = DateTime.now().add(const Duration(days: 1));
  final dia = DateTime(amanha.year, amanha.month, amanha.day);
  // Um barbeiro que atende nesse dia, qualquer que seja o dia da semana.
  final barbeiro = DadosTeste.barbeiros.firstWhere((b) => b.atendeNo(dia));
  final corte = DadosTeste.corte(barbeiro.cortes.first);

  setUp(() async {
    await g.reset();
    firestore = FakeFirebaseFirestore();
    await firestore.collection('usuarios').doc('cj').set({
      'nome': 'Carl Johnson',
      'email': 'cj@oldreece.com',
      'telefone': '11912345678',
      'cep': '01001-000',
      'bairro': 'Sé',
      'cidade': 'São Paulo',
    });
    configurarDependencias(
      firestore: firestore,
      auth: MockFirebaseAuth(
        mockUser: MockUser(uid: 'cj', email: 'cj@oldreece.com'),
      ),
    );
    await g<AuthController>().entrar('cj@oldreece.com', 'x');
    ctrl = g<AgendamentoController>();
  });

  void rascunho() {
    ctrl.iniciar(barbeiro: barbeiro, corte: corte);
    ctrl.escolherDia(dia);
    ctrl.escolherHora(10);
  }

  test('confirmar grava o agendamento do usuário e reserva o horário', () async {
    rascunho();

    expect(await ctrl.confirmar(), isNull);

    final novo = ctrl.confirmado!;
    final salvo = await firestore
        .doc('usuarios/cj/agendamentos/${novo.id}')
        .get();
    expect(salvo.data(), containsPair('barbeiroId', barbeiro.id));
    expect(salvo.data(), containsPair('preco', corte.preco));
    expect(salvo.data(), containsPair('cancelado', false));

    final reserva = await firestore
        .doc('horarios_ocupados/${novo.horarioId}')
        .get();
    expect(reserva.data(), containsPair('uid', 'cj'));
    expect(await ctrl.horasOcupadas(barbeiro, dia).first, {10});
  });

  test('horário já reservado é recusado e nada é gravado', () async {
    rascunho();
    await ctrl.confirmar();

    rascunho();
    final erro = await ctrl.confirmar();

    expect(erro, 'Esse horário acabou de ser ocupado. Escolhe outro.');
    expect(ctrl.hora, isNull);
    expect(ctrl.salvando, isFalse);
    final meus = await firestore.collection('usuarios/cj/agendamentos').get();
    expect(meus.docs, hasLength(1));
  });

  test('cancelar marca o agendamento e libera o horário', () async {
    rascunho();
    await ctrl.confirmar();
    final novo = ctrl.confirmado!;

    expect(await ctrl.cancelar(novo), isNull);

    final salvo = await firestore
        .doc('usuarios/cj/agendamentos/${novo.id}')
        .get();
    expect(salvo.data(), containsPair('cancelado', true));
    expect(await ctrl.horasOcupadas(barbeiro, dia).first, isEmpty);

    rascunho();
    expect(await ctrl.confirmar(), isNull);
  });

  test('observar entrega a mudança em tempo real', () async {
    final recebidos = <int>[];
    final inscricao = ctrl.observar().listen((l) => recebidos.add(l.length));
    await pumpEventQueue();

    rascunho();
    await ctrl.confirmar();
    await pumpEventQueue();

    expect(recebidos.first, 0);
    expect(recebidos.last, 1);
    await inscricao.cancel();
  });

  test('avaliar salva a nota e ignora comentário vazio', () async {
    final passado = dia.subtract(const Duration(days: 5));
    final antigo = Agendamento(
      id: 'antigo',
      barbeiroId: barbeiro.id,
      barbeiroNome: barbeiro.nome,
      barbeiroFoto: barbeiro.foto,
      corteId: corte.id,
      corteNome: corte.nome,
      preco: corte.preco,
      data: passado,
    );
    await firestore
        .doc('usuarios/cj/agendamentos/antigo')
        .set(antigo.toMap());
    expect(antigo.podeAvaliar, isTrue);

    expect(await ctrl.avaliar(antigo, 5, '   '), isNull);

    final lista = await ctrl.observar().first;
    expect(lista.single.avaliacao, 5);
    expect(lista.single.comentario, isNull);
    expect(lista.single.podeAvaliar, isFalse);
  });

  test('o histórico vem do mais novo para o mais antigo', () {
    Agendamento em(String id, DateTime data, {bool cancelado = false}) =>
        Agendamento(
          id: id,
          barbeiroId: 'b',
          barbeiroNome: 'B',
          barbeiroFoto: 'f',
          corteId: 'c',
          corteNome: 'C',
          preco: 1,
          data: data,
          cancelado: cancelado,
        );
    final lista = [
      em('velho', DateTime(2020)),
      em('novo', DateTime(2021)),
      em('cancelado', dia, cancelado: true),
      em('futuro', dia),
    ];

    expect(ctrl.proximos(lista).map((a) => a.id), ['futuro']);
    expect(ctrl.historico(lista).map((a) => a.id), [
      'cancelado',
      'novo',
      'velho',
    ]);
  });

  testWidgets('DadosAoVivo mostra a falha e tenta de novo', (tester) async {
    var tentativas = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DadosAoVivo<String>(
            consulta: () {
              tentativas++;
              return tentativas == 1
                  ? Stream.error(
                      FirebaseException(plugin: 'teste', code: 'unavailable'),
                    )
                  : Stream.value('carregou');
            },
            construtor: (_, dados) => Text(dados),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Sem conexão. Confere a internet e tenta de novo.'),
      findsOneWidget,
    );

    await tester.tap(find.text('TENTAR DE NOVO'));
    await tester.pumpAndSettle();

    expect(tentativas, 2);
    expect(find.text('carregou'), findsOneWidget);
    expect(find.textContaining('Sem conexão'), findsNothing);
  });
}
