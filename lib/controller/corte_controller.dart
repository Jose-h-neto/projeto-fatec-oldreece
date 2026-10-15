import 'package:flutter/material.dart';

import '../data/dados_mock.dart';
import '../model/corte.dart';

class CorteController extends ChangeNotifier {
  final List<Corte> todos = DadosMock.cortes;

  /// Filtro por categoria do catálogo (null = todos).
  CategoriaCorte? categoria;

  List<Corte> get cortes => categoria == null
      ? todos
      : todos.where((c) => c.categoria == categoria).toList();

  List<Corte> get destaques => todos.where((c) => c.destaque).toList();

  void filtrar(CategoriaCorte? nova) {
    categoria = nova;
    notifyListeners();
  }
}
