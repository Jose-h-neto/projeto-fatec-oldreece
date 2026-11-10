import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../core/dependencias.dart';
import '../model/corte.dart';

class CorteController extends ChangeNotifier {
  final _db = g<FirebaseFirestore>();

  /// Filtro por categoria do catálogo (null = todos).
  CategoriaCorte? categoria;

  /// Cortes da coleção `cortes`, atualizados em tempo real.
  Stream<List<Corte>> observar() => _db
      .collection('cortes')
      .orderBy('ordem')
      .snapshots()
      .map(
        (consulta) => consulta.docs
            .map((doc) => Corte.fromJson(doc.id, doc.data()))
            .toList(),
      );

  List<Corte> filtrar(List<Corte> cortes) => categoria == null
      ? cortes
      : cortes.where((c) => c.categoria == categoria).toList();

  void escolherCategoria(CategoriaCorte? nova) {
    categoria = nova;
    notifyListeners();
  }
}
