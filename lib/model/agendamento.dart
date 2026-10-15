import 'barbeiro.dart';
import 'corte.dart';

enum StatusAgendamento {
  agendado('Agendado'),
  concluido('Concluído'),
  cancelado('Cancelado');

  final String rotulo;
  const StatusAgendamento(this.rotulo);
}

class Agendamento {
  final String id;
  final Barbeiro barbeiro;
  final Corte corte;
  final DateTime data;
  bool cancelado;

  /// Nota de 0 a 6 estrelas dada depois do atendimento.
  int? avaliacao;
  String? comentario;

  Agendamento({
    required this.id,
    required this.barbeiro,
    required this.corte,
    required this.data,
    this.cancelado = false,
    this.avaliacao,
    this.comentario,
  });

  /// O status é derivado da data: o que já passou e não foi cancelado
  /// conta como concluído.
  StatusAgendamento get status {
    if (cancelado) return StatusAgendamento.cancelado;
    if (data.isBefore(DateTime.now())) return StatusAgendamento.concluido;
    return StatusAgendamento.agendado;
  }

  bool get podeAvaliar =>
      status == StatusAgendamento.concluido && avaliacao == null;
}
