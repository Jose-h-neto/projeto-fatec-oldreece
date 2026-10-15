class Barbeiro {
  final String id;
  final String nome;
  final String foto;
  final String especialidade;
  final String bio;
  final String frase;

  /// Avaliação de 0 a 6 estrelas, como o nível de procurado.
  final int estrelas;
  final int anosExperiencia;

  /// Dias de atendimento (DateTime.monday = 1 ... DateTime.sunday = 7).
  final List<int> diasAtendimento;

  /// Ids dos cortes que o barbeiro faz.
  final List<String> cortes;

  const Barbeiro({
    required this.id,
    required this.nome,
    required this.foto,
    required this.especialidade,
    required this.bio,
    required this.frase,
    required this.estrelas,
    required this.anosExperiencia,
    required this.diasAtendimento,
    required this.cortes,
  });

  bool atendeNo(DateTime dia) => diasAtendimento.contains(dia.weekday);
}
