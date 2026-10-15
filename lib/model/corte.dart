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
}
