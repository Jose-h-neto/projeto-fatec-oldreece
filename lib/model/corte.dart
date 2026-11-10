enum CategoriaCorte {
  cabelo('Cabelo'),
  barba('Barba');

  final String rotulo;
  const CategoriaCorte(this.rotulo);
}

class Corte {
  final String id;
  final String nome;
  final String descricao;
  final String imagem;
  final int preco;
  final int duracaoMin;
  final CategoriaCorte categoria;
  final bool destaque;

  const Corte({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.imagem,
    required this.preco,
    required this.duracaoMin,
    required this.categoria,
    this.destaque = false,
  });

  factory Corte.fromMap(String id, Map<String, dynamic> dados) => Corte(
    id: id,
    nome: dados['nome'] as String,
    descricao: dados['descricao'] as String,
    imagem: dados['imagem'] as String,
    preco: dados['preco'] as int,
    duracaoMin: dados['duracaoMin'] as int,
    categoria: CategoriaCorte.values.byName(dados['categoria'] as String),
    destaque: dados['destaque'] as bool? ?? false,
  );

  Map<String, dynamic> toMap() => {
    'nome': nome,
    'descricao': descricao,
    'imagem': imagem,
    'preco': preco,
    'duracaoMin': duracaoMin,
    'categoria': categoria.name,
    'destaque': destaque,
  };
}
