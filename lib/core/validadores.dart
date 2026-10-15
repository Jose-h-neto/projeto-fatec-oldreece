/// Validações reutilizadas pelos formulários. Retornam a mensagem de erro
/// ou `null` quando o valor é válido.
abstract class Validadores {
  static final _email = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');

  static const tamanhoMinimoNome = 3;
  static const tamanhoMinimoSenha = 6;

  static String? obrigatorio(String? valor, String campo) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Preenche o campo $campo, mano.';
    }
    return null;
  }

  static String? email(String? valor) {
    final vazio = obrigatorio(valor, 'e-mail');
    if (vazio != null) return vazio;
    if (!_email.hasMatch(valor!.trim())) {
      return 'Esse e-mail tá estranho. Confere o formato.';
    }
    return null;
  }

  static String? senha(String? valor) {
    final vazio = obrigatorio(valor, 'senha');
    if (vazio != null) return vazio;
    if (valor!.length < tamanhoMinimoSenha) {
      return 'A senha precisa de pelo menos $tamanhoMinimoSenha caracteres.';
    }
    return null;
  }

  static String? confirmacaoSenha(String? valor, String senha) {
    final vazio = obrigatorio(valor, 'confirmação de senha');
    if (vazio != null) return vazio;
    if (valor != senha) return 'As senhas não batem.';
    return null;
  }

  static String? nome(String? valor) {
    final vazio = obrigatorio(valor, 'nome');
    if (vazio != null) return vazio;
    if (valor!.trim().length < tamanhoMinimoNome) {
      return 'O nome precisa de pelo menos $tamanhoMinimoNome letras.';
    }
    return null;
  }

  static String? telefone(String? valor) {
    final vazio = obrigatorio(valor, 'telefone');
    if (vazio != null) return vazio;
    final digitos = valor!.replaceAll(RegExp(r'\D'), '');
    if (digitos.length < 10 || digitos.length > 11) {
      return 'Telefone com DDD, tipo (11) 91234-5678.';
    }
    return null;
  }
}
