import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:old_reece/controller/auth_controller.dart';
import 'package:old_reece/core/dependencias.dart';
import 'package:old_reece/main.dart';
import 'package:old_reece/widgets/sa_botao.dart';

Finder botao(String rotulo) =>
    find.descendant(of: find.byType(SaBotao), matching: find.text(rotulo));

Future<void> tocar(WidgetTester tester, Finder alvo) async {
  await tester.ensureVisible(alvo);
  await tester.pumpAndSettle();
  await tester.tap(alvo);
  await tester.pumpAndSettle();
}

void main() {
  setUp(() async {
    await g.reset();
    configurarDependencias();
  });

  testWidgets('login valida campos vazios e e-mail inválido', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.6;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MainApp());
    await tester.pumpAndSettle();

    await tocar(tester, find.text('ENTRAR'));
    expect(find.text('Preenche o campo e-mail, mano.'), findsOneWidget);
    expect(find.text('Preenche o campo senha, mano.'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'cj@');
    await tocar(tester, find.text('ENTRAR'));
    expect(
      find.text('Esse e-mail tá estranho. Confere o formato.'),
      findsOneWidget,
    );
  });

  testWidgets('fluxo completo: login, agendar, cancelar, perfil', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.6;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MainApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'cj@oldreece.com');
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tocar(tester, find.text('ENTRAR'));

    // Início
    expect(find.text('E aí, Carl'), findsWidgets);
    expect(find.text('Nenhum horário marcado ainda.'), findsOneWidget);

    // Agendar
    await tocar(tester, botao('AGENDAR HORÁRIO').first);
    expect(find.text('1. BARBEIRO'), findsOneWidget);
    await tocar(tester, find.text('OLD REECE').last);
    await tocar(tester, find.textContaining('HIGH FADE').first);

    // Primeiro dia em que o Reece atende e primeiro horário livre.
    final dias = find.descendant(
      of: find.byType(ListView).first,
      matching: find.byWidgetPredicate(
        (w) =>
            w is Semantics &&
            w.properties.enabled == true &&
            w.properties.button == true &&
            (w.properties.label ?? '').contains(', ') &&
            !(w.properties.label ?? '').startsWith('Barbeiro'),
      ),
    );
    expect(dias, findsWidgets);
    await tocar(tester, dias.at(1));

    // Só os horários livres aparecem, cada um com a chave "hora-<h>".
    final livres = find.byWidgetPredicate(
      (w) =>
          w is ChoiceChip &&
          w.key is ValueKey<String> &&
          (w.key as ValueKey<String>).value.startsWith('hora-'),
    );
    expect(livres, findsWidgets);
    await tocar(tester, livres.first);

    await tocar(tester, botao('CONFIRMAR'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('MISSÃO CUMPRIDA!'), findsWidgets);

    // Agenda
    await tocar(tester, find.text('VER MINHA AGENDA'));
    expect(find.text('MINHA AGENDA'), findsOneWidget);
    expect(find.text('CANCELAR'), findsOneWidget);

    await tocar(tester, find.text('CANCELAR'));
    await tocar(tester, find.text('CANCELAR HORÁRIO'));
    expect(find.text('CANCELAR'), findsNothing);

    // Perfil: nome curto é rejeitado; nome válido atualiza o app.
    await tocar(tester, find.byTooltip('Meu perfil'));
    await tester.enterText(find.byType(TextFormField).first, 'CJ');
    await tocar(tester, botao('SALVAR'));
    expect(find.text('O nome precisa de pelo menos 3 letras.'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, 'Carlão Johnson');
    await tocar(tester, botao('SALVAR'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(g<AuthController>().usuario?.nome, 'Carlão Johnson');
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tocar(tester, find.text('Início'));
    await tester.drag(find.byType(ListView).first, const Offset(0, 3000));
    await tester.pumpAndSettle();
    expect(find.text('E aí, Carlão'), findsWidgets);
  });

  testWidgets('barbeiro que não faz o serviço escolhido fica indisponível', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.6;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MainApp());
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'cj@oldreece.com');
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tocar(tester, find.text('ENTRAR'));

    // High Fade (em alta) não é feito pelo Ryder.
    await tocar(tester, find.text('HIGH FADE').first);
    expect(find.text('NÃO FAZ'), findsOneWidget);
    expect(
      find.text('Os apagados não fazem High Fade. '
          'Troca ou desmarca o serviço pra liberar.'),
      findsOneWidget,
    );

    // Desmarcar o serviço libera todo mundo.
    await tocar(tester, find.textContaining('HIGH FADE').first);
    expect(find.text('NÃO FAZ'), findsNothing);
  });

  testWidgets('telas de barbeiros, cortes, cadastro, recuperar e sobre abrem', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.6;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MainApp());
    await tester.pumpAndSettle();

    await tocar(tester, find.text('ESQUECEU A SENHA?'));
    await tester.enterText(find.byType(TextFormField).first, 'ninguem@x.com');
    await tocar(tester, find.text('ENVIAR INSTRUÇÕES'));
    expect(find.text('Não achamos conta com esse e-mail.'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).first, 'cj@oldreece.com');
    await tocar(tester, find.text('ENVIAR INSTRUÇÕES'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('E-MAIL ENVIADO!'), findsWidgets);
    await tocar(tester, find.text('VOLTAR AO LOGIN'));

    await tocar(tester, find.text('CRIAR CONTA'));
    final campos = find.byType(TextFormField);
    await tester.enterText(campos.at(0), 'Sweet Johnson');
    await tester.enterText(campos.at(1), 'sweet@grove.com');
    await tester.enterText(campos.at(2), '11912345678');
    await tester.enterText(campos.at(3), 'abcdef');
    await tester.enterText(campos.at(4), 'abcdeX');
    await tocar(tester, botao('CRIAR CONTA'));
    expect(find.text('As senhas não batem.'), findsOneWidget);
    await tester.enterText(campos.at(4), 'abcdef');
    await tocar(tester, botao('CRIAR CONTA'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('E aí, Sweet'), findsWidgets);

    await tocar(tester, find.text('Barbeiros'));
    expect(find.text('CÉSAR'), findsWidgets);
    await tocar(tester, find.text('RYDER').first);
    expect(find.text('AGENDAR COM RYDER'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tocar(tester, find.text('Cortes'));
    await tocar(tester, find.text('BARBA'));
    expect(find.text('MOICANO'), findsNothing);
    await tocar(tester, find.text('BIGODE'));
    expect(find.text('AGENDAR ESTE CORTE'), findsOneWidget);
    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();

    await tocar(tester, find.byTooltip('Meu perfil'));
    await tocar(tester, find.text('Sobre o app'));
    expect(find.text('OBJETIVO'), findsOneWidget);
  });
}
