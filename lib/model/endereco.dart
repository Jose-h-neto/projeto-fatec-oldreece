class Endereco {
  final String bairro;
  final String cidade;

  const Endereco({required this.bairro, required this.cidade});

  /// Monta a partir da resposta do ViaCEP (a cidade vem em `localidade`).
  factory Endereco.fromJson(Map<String, dynamic> json) => Endereco(
    bairro: json['bairro'] as String? ?? '',
    cidade: json['localidade'] as String? ?? '',
  );
}
