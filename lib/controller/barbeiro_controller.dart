import 'package:flutter/material.dart';

import '../data/dados_mock.dart';
import '../model/barbeiro.dart';
import '../model/corte.dart';

class BarbeiroController extends ChangeNotifier {
  final List<Barbeiro> barbeiros = DadosMock.barbeiros;

  List<Corte> cortesDe(Barbeiro barbeiro) =>
      barbeiro.cortes.map(DadosMock.corte).toList();

  List<Barbeiro> quemFaz(Corte corte) =>
      barbeiros.where((b) => b.cortes.contains(corte.id)).toList();
}
