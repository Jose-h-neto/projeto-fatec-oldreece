import 'package:flutter/material.dart';

/// Controla a aba ativa da barra de navegação inferior.
class HomeController extends ChangeNotifier {
  static const inicio = 0;
  static const barbeiros = 1;
  static const cortes = 2;
  static const agenda = 3;

  int aba = inicio;

  void irPara(int indice) {
    if (aba == indice) return;
    aba = indice;
    notifyListeners();
  }

  void reiniciar() => aba = inicio;
}
