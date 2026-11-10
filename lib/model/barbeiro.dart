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

  factory Barbeiro.fromJson(String id, Map<String, dynamic> dados) => Barbeiro(
    id: id,
    nome: dados['nome'] as String,
    foto: dados['foto'] as String,
    especialidade: dados['especialidade'] as String,
    bio: dados['bio'] as String,
    frase: dados['frase'] as String,
    estrelas: dados['estrelas'] as int,
    anosExperiencia: dados['anosExperiencia'] as int,
    diasAtendimento: List<int>.from(dados['diasAtendimento'] as List),
    cortes: List<String>.from(dados['cortes'] as List),
  );

  Map<String, dynamic> toJson() => {
    'nome': nome,
    'foto': foto,
    'especialidade': especialidade,
    'bio': bio,
    'frase': frase,
    'estrelas': estrelas,
    'anosExperiencia': anosExperiencia,
    'diasAtendimento': diasAtendimento,
    'cortes': cortes,
  };

  bool atendeNo(DateTime dia) => diasAtendimento.contains(dia.weekday);
}
