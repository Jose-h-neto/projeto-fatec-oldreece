import 'package:cloud_firestore/cloud_firestore.dart';

enum StatusAgendamento {
  agendado('Agendado'),
  concluido('Concluído'),
  cancelado('Cancelado');

  final String rotulo;
  const StatusAgendamento(this.rotulo);
}

/// Horário marcado por um cliente, guardado em
/// `usuarios/{uid}/agendamentos`. Copia os dados do barbeiro e do corte para o
/// histórico continuar igual mesmo se o catálogo ou o preço mudarem depois.
class Agendamento {
  final String id;
  final String barbeiroId;
  final String barbeiroNome;
  final String barbeiroFoto;
  final String corteId;
  final String corteNome;
  final int preco;
  final DateTime data;
  final bool cancelado;

  /// Nota de 1 a 6 estrelas dada depois do atendimento.
  final int? avaliacao;
  final String? comentario;

  const Agendamento({
    required this.id,
    required this.barbeiroId,
    required this.barbeiroNome,
    required this.barbeiroFoto,
    required this.corteId,
    required this.corteNome,
    required this.preco,
    required this.data,
    this.cancelado = false,
    this.avaliacao,
    this.comentario,
  });

  factory Agendamento.fromMap(String id, Map<String, dynamic> dados) =>
      Agendamento(
        id: id,
        barbeiroId: dados['barbeiroId'] as String,
        barbeiroNome: dados['barbeiroNome'] as String,
        barbeiroFoto: dados['barbeiroFoto'] as String,
        corteId: dados['corteId'] as String,
        corteNome: dados['corteNome'] as String,
        preco: dados['preco'] as int,
        data: (dados['data'] as Timestamp).toDate(),
        cancelado: dados['cancelado'] as bool? ?? false,
        avaliacao: dados['avaliacao'] as int?,
        comentario: dados['comentario'] as String?,
      );

  Map<String, dynamic> toMap() => {
    'barbeiroId': barbeiroId,
    'barbeiroNome': barbeiroNome,
    'barbeiroFoto': barbeiroFoto,
    'corteId': corteId,
    'corteNome': corteNome,
    'preco': preco,
    'data': Timestamp.fromDate(data),
    'cancelado': cancelado,
  };

  /// Dia no formato `aaaammdd`, usado para consultar os horários ocupados.
  static String diaChave(DateTime dia) =>
      '${dia.year}'
      '${dia.month.toString().padLeft(2, '0')}'
      '${dia.day.toString().padLeft(2, '0')}';

  /// Id do documento em `horarios_ocupados`: o mesmo barbeiro, dia e hora
  /// sempre geram o mesmo id, o que impede dois clientes no mesmo horário.
  String get horarioId => '${barbeiroId}_${diaChave(data)}_${data.hour}';

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
