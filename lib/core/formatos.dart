/// Formatação de datas, horas e valores sem dependências externas.
abstract class Formatos {
  static const diasCurtos = ['SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SÁB', 'DOM'];
  static const diasLongos = [
    'Segunda',
    'Terça',
    'Quarta',
    'Quinta',
    'Sexta',
    'Sábado',
    'Domingo',
  ];
  static const meses = [
    'jan',
    'fev',
    'mar',
    'abr',
    'mai',
    'jun',
    'jul',
    'ago',
    'set',
    'out',
    'nov',
    'dez',
  ];

  static String diaCurto(DateTime d) => diasCurtos[d.weekday - 1];

  static String diaLongo(DateTime d) => diasLongos[d.weekday - 1];

  static String hora(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  /// Ex.: "Ter, 14 out · 15:30"
  static String dataHora(DateTime d) {
    final dia = diasLongos[d.weekday - 1].substring(0, 3);
    return '$dia, ${d.day} ${meses[d.month - 1]} · ${hora(d)}';
  }

  /// Ex.: "Terça, 14 de out"
  static String dataLonga(DateTime d) =>
      '${diaLongo(d)}, ${d.day} de ${meses[d.month - 1]}';

  /// Preço simples: "R$ 45"
  static String preco(int reais) => 'R\$ $reais';

  /// Preço no estilo contador do HUD: "R$00000045"
  static String precoHud(int reais) => 'R\$${reais.toString().padLeft(8, '0')}';

  static String duracao(int minutos) => '$minutos MIN';
}
