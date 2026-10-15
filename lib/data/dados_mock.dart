import '../model/barbeiro.dart';
import '../model/corte.dart';

/// Dados estáticos (mockados) da barbearia.
abstract class DadosMock {
  static const cortes = <Corte>[
    Corte(
      id: 'high_fade',
      nome: 'High Fade',
      descricao:
          'Laterais na zero subindo no degradê, topo baixinho. O clássico do bairro.',
      imagem: 'lib/cortes/high_fade.webp',
      preco: 45,
      duracaoMin: 40,
      categoria: CategoriaCorte.cabelo,
      destaque: true,
    ),
    Corte(
      id: 'baixo',
      nome: 'Baixinho',
      descricao: 'Máquina por igual, curto e fácil de manter.',
      imagem: 'lib/cortes/baixo.webp',
      preco: 30,
      duracaoMin: 25,
      categoria: CategoriaCorte.cabelo,
    ),
    Corte(
      id: 'raspado',
      nome: 'Raspado',
      descricao: 'Careca lisa na navalha com toalha quente no final.',
      imagem: 'lib/cortes/raspado.webp',
      preco: 35,
      duracaoMin: 30,
      categoria: CategoriaCorte.cabelo,
    ),
    Corte(
      id: 'social',
      nome: 'Social',
      descricao: 'Corte na tesoura com risca lateral. Pronto pra entrevista.',
      imagem: 'lib/cortes/social.webp',
      preco: 40,
      duracaoMin: 35,
      categoria: CategoriaCorte.cabelo,
    ),
    Corte(
      id: 'black_power',
      nome: 'Black Power',
      descricao:
          'Volume redondo, contorno alinhado e finalização com pente garfo.',
      imagem: 'lib/cortes/black_power.webp',
      preco: 60,
      duracaoMin: 50,
      categoria: CategoriaCorte.cabelo,
    ),
    Corte(
      id: 'dread',
      nome: 'Dreads',
      descricao: 'Manutenção de dreads: raiz, retwist e acabamento.',
      imagem: 'lib/cortes/dread.webp',
      preco: 90,
      duracaoMin: 90,
      categoria: CategoriaCorte.cabelo,
    ),
    Corte(
      id: 'moicano',
      nome: 'Moicano',
      descricao:
          'Laterais raspadas e faixa central em pé. Pra quem não é tímido.',
      imagem: 'lib/cortes/moicano.webp',
      preco: 50,
      duracaoMin: 40,
      categoria: CategoriaCorte.cabelo,
    ),
    Corte(
      id: 'topete',
      nome: 'Topete',
      descricao: 'Topete alto penteado pra trás, estilo rei do rock.',
      imagem: 'lib/cortes/topete.webp',
      preco: 55,
      duracaoMin: 45,
      categoria: CategoriaCorte.cabelo,
    ),
    Corte(
      id: 'barba',
      nome: 'Barba Cheia',
      descricao:
          'Aparar, desenhar o contorno e hidratar. Toalha quente inclusa.',
      imagem: 'lib/cortes/barba.webp',
      preco: 35,
      duracaoMin: 30,
      categoria: CategoriaCorte.barba,
      destaque: true,
    ),
    Corte(
      id: 'cavanhaque',
      nome: 'Cavanhaque',
      descricao: 'Queixo desenhado na navalha, rosto limpo.',
      imagem: 'lib/cortes/cavanhaque.webp',
      preco: 25,
      duracaoMin: 20,
      categoria: CategoriaCorte.barba,
    ),
    Corte(
      id: 'bigode',
      nome: 'Bigode',
      descricao: 'Bigode aparado e alinhado, com cera pra fixar.',
      imagem: 'lib/cortes/bigode.webp',
      preco: 20,
      duracaoMin: 15,
      categoria: CategoriaCorte.barba,
    ),
  ];

  static const barbeiros = <Barbeiro>[
    Barbeiro(
      id: 'reece',
      nome: 'Old Reece',
      foto: 'lib/barbers/reece.webp',
      especialidade: 'Cortes clássicos e barba',
      bio:
          'Corta cabelo no bairro há mais de trinta anos. Conhece todo mundo '
          'pelo nome e, principalmente, pelo corte que cada um usava em 1992.',
      frase: 'Senta aí, filho. Vai sair daqui na régua.',
      estrelas: 6,
      anosExperiencia: 32,
      diasAtendimento: [
        DateTime.monday,
        DateTime.tuesday,
        DateTime.wednesday,
        DateTime.thursday,
        DateTime.friday,
        DateTime.saturday,
      ],
      cortes: [
        'high_fade',
        'baixo',
        'raspado',
        'social',
        'black_power',
        'topete',
        'barba',
        'cavanhaque',
        'bigode',
      ],
    ),
    Barbeiro(
      id: 'cesar',
      nome: 'César',
      foto: 'lib/barbers/cesar.webp',
      especialidade: 'Raspados, moicano e bigode',
      bio:
          'Fã de carro rebaixado e de corte bem marcado. Se é pra ter estilo, '
          'é com ele: risca na navalha e bigode impecável.',
      frase: 'Estilo é tudo, hermano.',
      estrelas: 5,
      anosExperiencia: 9,
      diasAtendimento: [
        DateTime.tuesday,
        DateTime.wednesday,
        DateTime.thursday,
        DateTime.friday,
        DateTime.saturday,
      ],
      cortes: [
        'raspado',
        'baixo',
        'moicano',
        'high_fade',
        'bigode',
        'cavanhaque',
      ],
    ),
    Barbeiro(
      id: 'ryder',
      nome: 'Ryder',
      foto: 'lib/barbers/ryder.webp',
      especialidade: 'Dreads, black power e barba',
      bio:
          'Rápido no pente e mais rápido ainda na conversa. Cuida de dreads e '
          'black power como ninguém, mas não aceita reclamação do boné dele.',
      frase: 'Relaxa, tá ficando zica.',
      estrelas: 4,
      anosExperiencia: 6,
      diasAtendimento: [
        DateTime.monday,
        DateTime.wednesday,
        DateTime.friday,
        DateTime.saturday,
      ],
      cortes: ['dread', 'black_power', 'baixo', 'barba', 'cavanhaque'],
    ),
  ];

  static Corte corte(String id) => cortes.firstWhere((c) => c.id == id);

  static Barbeiro barbeiro(String id) =>
      barbeiros.firstWhere((b) => b.id == id);

  /// Horários de funcionamento (almoço ao meio-dia).
  static const horarios = [9, 10, 11, 13, 14, 15, 16, 17, 18];
}
