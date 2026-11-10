import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../core/dependencias.dart';
import '../model/barbeiro.dart';

class BarbeiroController extends ChangeNotifier {
  final _db = g<FirebaseFirestore>();

  /// Barbeiros da coleção `barbeiros`, atualizados em tempo real.
  Stream<List<Barbeiro>> observar() => _db
      .collection('barbeiros')
      .orderBy('ordem')
      .snapshots()
      .map(
        (consulta) => consulta.docs
            .map((doc) => Barbeiro.fromMap(doc.id, doc.data()))
            .toList(),
      );
}
