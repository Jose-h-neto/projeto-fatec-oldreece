/// Dados do cliente, guardados na coleção `usuarios` do Firestore. O id do
/// documento é o uid do Firebase Authentication, que também guarda a senha.
class Usuario {
  final String uid;
  String nome;
  final String email;
  final String telefone;
  final String cep;
  final String bairro;
  final String cidade;

  Usuario({
    required this.uid,
    required this.nome,
    required this.email,
    required this.telefone,
    required this.cep,
    required this.bairro,
    required this.cidade,
  });

  factory Usuario.fromJson(String uid, Map<String, dynamic> dados) => Usuario(
    uid: uid,
    nome: dados['nome'] as String,
    email: dados['email'] as String,
    telefone: dados['telefone'] as String,
    cep: dados['cep'] as String,
    bairro: dados['bairro'] as String,
    cidade: dados['cidade'] as String,
  );

  Map<String, dynamic> toJson() => {
    'nome': nome,
    'email': email,
    'telefone': telefone,
    'cep': cep,
    'bairro': bairro,
    'cidade': cidade,
  };
}
