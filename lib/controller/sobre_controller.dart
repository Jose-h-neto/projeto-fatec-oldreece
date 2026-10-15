import 'package:flutter/material.dart';

class SobreController extends ChangeNotifier {
  final String nomeApp = 'Old Reece';
  final String versao = '1.0.0';
  final String objetivo =
      'O Old Reece é um app de agendamento para barbearia e cabeleireiro '
      'inspirado na estética de GTA San Andreas. O cliente escolhe o barbeiro, '
      'o corte e um horário em algum dia da semana, acompanha a agenda, '
      'cancela quando precisar e avalia o atendimento com estrelas.';

  final List<String> integrantes = [
    'José Hipólito Neto',
    'Ruan Vinícius de Sousa',
  ];
  final String disciplina = 'Programação para Dispositivos Móveis';
  final String instituicao = 'Fatec Ribeirão Preto';
  final String professor = 'Rodrigo Plotze';
}
