import 'package:flutter/material.dart';

import '../core/dependencias.dart';
import '../data/dados_mock.dart';
import '../model/agendamento.dart';
import '../model/barbeiro.dart';
import '../model/corte.dart';
import 'auth_controller.dart';

/// Agenda do cliente e o rascunho do agendamento em andamento.
class AgendamentoController extends ChangeNotifier {
  final _auth = g<AuthController>();

  /// Agendamentos por e-mail do usuário.
  final Map<String, List<Agendamento>> _porUsuario = {
    'cj@oldreece.com': _historicoDemo(),
  };

  int _proximoId = 100;

  // ---------------------------------------------------------------------
  // Agenda
  // ---------------------------------------------------------------------

  List<Agendamento> get _lista =>
      _porUsuario.putIfAbsent(_auth.usuario?.email ?? '', () => []);

  List<Agendamento> get proximos =>
      _lista.where((a) => a.status == StatusAgendamento.agendado).toList()
        ..sort((a, b) => a.data.compareTo(b.data));

  List<Agendamento> get historico =>
      _lista.where((a) => a.status != StatusAgendamento.agendado).toList()
        ..sort((a, b) => b.data.compareTo(a.data));

  Agendamento? get proximo => proximos.firstOrNull;

  int get pendentesDeAvaliacao => _lista.where((a) => a.podeAvaliar).length;

  void cancelar(Agendamento agendamento) {
    agendamento.cancelado = true;
    notifyListeners();
  }

  void avaliar(Agendamento agendamento, int estrelas, String comentario) {
    agendamento.avaliacao = estrelas;
    agendamento.comentario = comentario.trim().isEmpty
        ? null
        : comentario.trim();
    notifyListeners();
  }

  // ---------------------------------------------------------------------
  // Rascunho do novo agendamento
  // ---------------------------------------------------------------------

  Barbeiro? barbeiro;
  Corte? corte;
  DateTime? dia;
  int? hora;
  bool salvando = false;

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

  bool horarioLivre(Barbeiro b, DateTime d, int h) {
    final inicio = DateTime(d.year, d.month, d.day, h);
    if (!b.atendeNo(d)) return false;
    if (inicio.isBefore(DateTime.now())) return false;

    for (final lista in _porUsuario.values) {
      for (final a in lista) {
        if (!a.cancelado && a.barbeiro.id == b.id && a.data == inicio) {
          return false;
        }
      }
    }
    // Simula a agenda já ocupada por outros clientes da barbearia.
    final semente = b.id.codeUnits.fold(0, (s, c) => s + c);
    return (semente + d.day * 7 + d.month + h * 3) % 4 != 0;
  }

  Future<Agendamento> confirmar() async {
    salvando = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 700));
    final novo = Agendamento(
      id: '${_proximoId++}',
      barbeiro: barbeiro!,
      corte: corte!,
      data: DateTime(dia!.year, dia!.month, dia!.day, hora!),
    );
    _lista.add(novo);

    salvando = false;
    notifyListeners();
    return novo;
  }

  static List<Agendamento> _historicoDemo() {
    final hoje = DateTime.now();
    DateTime atras(int dias, int h) =>
        DateTime(hoje.year, hoje.month, hoje.day - dias, h);

    return [
      Agendamento(
        id: '1',
        barbeiro: DadosMock.barbeiro('reece'),
        corte: DadosMock.corte('high_fade'),
        data: atras(45, 10),
        avaliacao: 6,
        comentario: 'Saí na régua, como sempre.',
      ),
      Agendamento(
        id: '2',
        barbeiro: DadosMock.barbeiro('cesar'),
        corte: DadosMock.corte('bigode'),
        data: atras(30, 15),
        avaliacao: 5,
      ),
      Agendamento(
        id: '3',
        barbeiro: DadosMock.barbeiro('ryder'),
        corte: DadosMock.corte('barba'),
        data: atras(20, 14),
        cancelado: true,
      ),
      Agendamento(
        id: '4',
        barbeiro: DadosMock.barbeiro('reece'),
        corte: DadosMock.corte('high_fade'),
        data: atras(12, 11),
        avaliacao: 6,
      ),
      Agendamento(
        id: '5',
        barbeiro: DadosMock.barbeiro('ryder'),
        corte: DadosMock.corte('baixo'),
        data: atras(3, 16),
      ),
    ];
  }
}
