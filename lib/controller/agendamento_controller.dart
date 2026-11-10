import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../core/dependencias.dart';
import '../core/erros.dart';
import '../model/agendamento.dart';
import '../model/barbeiro.dart';
import '../model/corte.dart';
import 'auth_controller.dart';

/// Agenda do cliente e o rascunho do agendamento em andamento.
class AgendamentoController extends ChangeNotifier {
  final _auth = g<AuthController>();
  final _db = g<FirebaseFirestore>();

  /// Horários de funcionamento (almoço ao meio-dia).
  static const horarios = [9, 10, 11, 13, 14, 15, 16, 17, 18];

  // ---------------------------------------------------------------------
  // Agenda
  // ---------------------------------------------------------------------

  /// Agendamentos ficam dentro do documento do usuário, separados por conta.
  CollectionReference<Map<String, dynamic>> get _meus => _db
      .collection('usuarios')
      .doc(_auth.usuario!.uid)
      .collection('agendamentos');

  DocumentReference<Map<String, dynamic>> _ocupado(String horarioId) =>
      _db.collection('horarios_ocupados').doc(horarioId);

  /// Agendamentos do usuário logado, atualizados em tempo real.
  Stream<List<Agendamento>> observar() => _meus
      .orderBy('data')
      .snapshots()
      .map(
        (consulta) => consulta.docs
            .map((doc) => Agendamento.fromJson(doc.id, doc.data()))
            .toList(),
      );

  List<Agendamento> proximos(List<Agendamento> lista) =>
      lista.where((a) => a.status == StatusAgendamento.agendado).toList();

  List<Agendamento> historico(List<Agendamento> lista) =>
      lista.where((a) => a.status != StatusAgendamento.agendado).toList()
        ..sort((a, b) => b.data.compareTo(a.data));

  /// Cancela e libera o horário para outros clientes, nas duas coleções de
  /// uma vez. Retorna a mensagem de erro, ou `null` se deu certo.
  Future<String?> cancelar(Agendamento agendamento) async {
    try {
      final lote = _db.batch()
        ..update(_meus.doc(agendamento.id), {'cancelado': true})
        ..delete(_ocupado(agendamento.horarioId));
      await lote.commit();
      return null;
    } on Exception catch (e) {
      return mensagemDeErro(e);
    }
  }

  /// Salva a nota. Retorna a mensagem de erro, ou `null` se deu certo.
  Future<String?> avaliar(
    Agendamento agendamento,
    int estrelas,
    String comentario,
  ) async {
    try {
      await _meus.doc(agendamento.id).update({
        'avaliacao': estrelas,
        if (comentario.trim().isNotEmpty) 'comentario': comentario.trim(),
      });
      return null;
    } on Exception catch (e) {
      return mensagemDeErro(e);
    }
  }

  // ---------------------------------------------------------------------
  // Rascunho do novo agendamento
  // ---------------------------------------------------------------------

  Barbeiro? barbeiro;
  Corte? corte;
  DateTime? dia;
  int? hora;
  bool salvando = false;

  /// Último agendamento criado por [confirmar].
  Agendamento? confirmado;

  bool get podeConfirmar =>
      barbeiro != null && corte != null && dia != null && hora != null;

  /// Começa um agendamento novo, opcionalmente já com barbeiro ou corte.
  void iniciar({Barbeiro? barbeiro, Corte? corte}) {
    this.barbeiro = barbeiro;
    this.corte = corte;
    if (barbeiro != null &&
        corte != null &&
        !barbeiro.cortes.contains(corte.id)) {
      this.corte = null;
    }
    dia = null;
    hora = null;
    salvando = false;
    notifyListeners();
  }

  void escolherBarbeiro(Barbeiro novo) {
    barbeiro = novo;
    if (corte != null && !novo.cortes.contains(corte!.id)) corte = null;
    if (dia != null && !novo.atendeNo(dia!)) dia = null;
    hora = null;
    notifyListeners();
  }

  /// Escolhe o serviço; `null` desmarca.
  void escolherCorte(Corte? novo) {
    corte = novo;
    notifyListeners();
  }

  void escolherDia(DateTime novo) {
    dia = novo;
    hora = null;
    notifyListeners();
  }

  void escolherHora(int nova) {
    hora = nova;
    notifyListeners();
  }

  /// Os próximos 7 dias, a partir de hoje.
  List<DateTime> get diasDaSemana {
    final hoje = DateTime.now();
    final base = DateTime(hoje.year, hoje.month, hoje.day);
    return List.generate(7, (i) => base.add(Duration(days: i)));
  }

  /// Horas já reservadas do barbeiro no dia, por qualquer cliente, atualizadas
  /// em tempo real. A coleção só guarda o horário, sem dados pessoais.
  Stream<Set<int>> horasOcupadas(Barbeiro b, DateTime d) => _db
      .collection('horarios_ocupados')
      .where('barbeiroId', isEqualTo: b.id)
      .where('dia', isEqualTo: Agendamento.diaChave(d))
      .snapshots()
      .map(
        (consulta) =>
            consulta.docs.map((doc) => doc.data()['hora'] as int).toSet(),
      );

  bool horarioLivre(Barbeiro b, DateTime d, int h, Set<int> ocupadas) {
    if (!b.atendeNo(d)) return false;
    if (DateTime(d.year, d.month, d.day, h).isBefore(DateTime.now())) {
      return false;
    }
    return !ocupadas.contains(h);
  }

  /// Reserva o horário e cria o agendamento numa transação: se outro cliente
  /// reservou antes, nada é gravado. Retorna a mensagem de erro, ou `null` se
  /// deu certo e o resultado está em [confirmado].
  Future<String?> confirmar() async {
    salvando = true;
    notifyListeners();

    final novo = Agendamento(
      id: _meus.doc().id,
      barbeiroId: barbeiro!.id,
      barbeiroNome: barbeiro!.nome,
      barbeiroFoto: barbeiro!.foto,
      corteId: corte!.id,
      corteNome: corte!.nome,
      preco: corte!.preco,
      data: DateTime(dia!.year, dia!.month, dia!.day, hora!),
    );
    final ocupado = _ocupado(novo.horarioId);

    String? erro;
    var horarioTomado = false;
    try {
      await _db.runTransaction((transacao) async {
        if ((await transacao.get(ocupado)).exists) {
          horarioTomado = true;
          throw StateError('horário ocupado');
        }
        transacao.set(ocupado, {
          'barbeiroId': novo.barbeiroId,
          'dia': Agendamento.diaChave(novo.data),
          'hora': novo.data.hour,
          'uid': _auth.usuario!.uid,
          'agendamentoId': novo.id,
        });
        transacao.set(_meus.doc(novo.id), {
          ...novo.toJson(),
          'criadoEm': FieldValue.serverTimestamp(),
        });
      });
      confirmado = novo;
    } catch (e) {
      erro = horarioTomado
          ? 'Esse horário acabou de ser ocupado. Escolhe outro.'
          : mensagemDeErro(e);
      if (horarioTomado) hora = null;
    }

    salvando = false;
    notifyListeners();
    return erro;
  }
}
