import 'package:flutter/material.dart';

/// Cores do design system "Barbearia SA" (tema Noite: HUD sobre preto).
abstract class Cores {
  static const surface = Color(0xFF0D0D0B);
  static const surfaceRaised = Color(0xFF1B1A16);
  static const surfaceSunken = Color(0xFF060605);
  static const line = Color(0xFF3A382F);
  static const lineStrong = Color(0xFF6E695A);
  static const frame = Color(0xFF6E695A);
  static const outline = Color(0xFF000000);
  static const ink = Color(0xFFF3ECDA);
  static const inkMuted = Color(0xFFB3AA94);

  static const grove = Color(0xFF5CB555);
  static const groveSoft = Color(0xFF16301A);
  static const onGrove = Color(0xFF0D0D0B);
  static const money = grove;

  static const gold = Color(0xFFEAB53C);
  static const goldSoft = Color(0xFF3A2C0C);
  static const goldFill = Color(0xFFE0A526);
  static const onGold = Color(0xFF17140F);

  static const health = Color(0xFFEF5A50);
  static const healthSoft = Color(0xFF3A1311);
  static const onHealth = Color(0xFF0D0D0B);

  static const hudPanel = Color(0xD1000000);
  static const onHud = Color(0xFFF3ECDA);
}

/// Famílias tipográficas: cada uma com um papel só.
abstract class Fontes {
  static const display = 'Anton'; // substituto livre da Pricedown
  static const script = 'PirataOne'; // substituto livre da Diploma
  static const menu = 'Michroma'; // substituto livre da Bank Gothic
}

/// Estilos de texto do design system.
abstract class Estilos {
  static const displayXl = TextStyle(
    fontFamily: Fontes.display,
    fontSize: 56,
    height: 1,
    letterSpacing: 0.5,
  );
  static const displayLg = TextStyle(
    fontFamily: Fontes.display,
    fontSize: 40,
    height: 1,
    letterSpacing: 0.4,
  );
  static const displayMd = TextStyle(
    fontFamily: Fontes.display,
    fontSize: 26,
    height: 1.1,
    letterSpacing: 0.5,
  );
  static const hudNumber = TextStyle(
    fontFamily: Fontes.display,
    fontSize: 28,
    height: 1,
    letterSpacing: 0.9,
    color: Cores.money,
  );
  static const zone = TextStyle(
    fontFamily: Fontes.script,
    fontSize: 40,
    height: 1.1,
    color: Cores.ink,
  );
  static const menu = TextStyle(
    fontFamily: Fontes.menu,
    fontSize: 12,
    height: 1.5,
    letterSpacing: 1,
  );
  static const label = TextStyle(
    fontFamily: Fontes.menu,
    fontSize: 10,
    height: 1.6,
    letterSpacing: 1.1,
    color: Cores.inkMuted,
  );
  static const subtitle = TextStyle(
    fontSize: 18,
    height: 1.33,
    fontWeight: FontWeight.w700,
  );
  static const body = TextStyle(fontSize: 16, height: 1.5, color: Cores.ink);
  static const bodySm = TextStyle(
    fontSize: 14,
    height: 1.43,
    color: Cores.inkMuted,
  );
  static const caption = TextStyle(
    fontSize: 12,
    height: 1.33,
    fontWeight: FontWeight.w700,
    color: Cores.inkMuted,
  );
}

/// Espaçamento em passos de 4px.
abstract class Espaco {
  static const s1 = 4.0;
  static const s2 = 8.0;
  static const s3 = 12.0;
  static const s4 = 16.0;
  static const s6 = 24.0;
  static const s8 = 32.0;
  static const s12 = 48.0;
}

/// Sombra dura deslocada, sem desfoque (estilo arte de capa).
abstract class Sombras {
  static const hard = [
    BoxShadow(color: Cores.line, offset: Offset(3, 3), blurRadius: 0),
  ];
  static const hardLg = [
    BoxShadow(color: Cores.line, offset: Offset(6, 6), blurRadius: 0),
  ];
}

ThemeData criarTema() {
  const borda = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(2)),
    borderSide: BorderSide(color: Cores.lineStrong, width: 2),
  );

  final esquema =
      ColorScheme.fromSeed(
        seedColor: Cores.grove,
        brightness: Brightness.dark,
      ).copyWith(
        primary: Cores.grove,
        onPrimary: Cores.onGrove,
        secondary: Cores.gold,
        onSecondary: Cores.onGold,
        error: Cores.health,
        onError: Cores.onHealth,
        surface: Cores.surface,
        onSurface: Cores.ink,
        surfaceContainer: Cores.surfaceRaised,
        outline: Cores.lineStrong,
        outlineVariant: Cores.line,
      );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: esquema,
    scaffoldBackgroundColor: Cores.surface,
    canvasColor: Cores.surface,
    dividerColor: Cores.line,
    appBarTheme: const AppBarTheme(
      backgroundColor: Cores.surface,
      foregroundColor: Cores.ink,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: Fontes.display,
        fontSize: 26,
        letterSpacing: 0.6,
        color: Cores.ink,
      ),
      shape: Border(bottom: BorderSide(color: Cores.line, width: 2)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Cores.surfaceRaised,
      border: borda,
      enabledBorder: borda,
      disabledBorder: borda.copyWith(
        borderSide: const BorderSide(color: Cores.line, width: 2),
      ),
      focusedBorder: borda.copyWith(
        borderSide: const BorderSide(color: Cores.gold, width: 2),
      ),
      errorBorder: borda.copyWith(
        borderSide: const BorderSide(color: Cores.health, width: 2),
      ),
      focusedErrorBorder: borda.copyWith(
        borderSide: const BorderSide(color: Cores.health, width: 2),
      ),
      labelStyle: const TextStyle(color: Cores.inkMuted),
      floatingLabelStyle: const TextStyle(color: Cores.gold),
      prefixIconColor: Cores.inkMuted,
      suffixIconColor: Cores.inkMuted,
      errorStyle: const TextStyle(
        color: Cores.health,
        fontWeight: FontWeight.w700,
      ),
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: Cores.gold,
      selectionColor: Cores.goldSoft,
      selectionHandleColor: Cores.gold,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Cores.grove,
        shape: const RoundedRectangleBorder(),
        textStyle: Estilos.menu.copyWith(fontSize: 10),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Cores.surfaceSunken,
      behavior: SnackBarBehavior.floating,
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: Cores.frame, width: 2),
      ),
      contentTextStyle: Estilos.body.copyWith(fontWeight: FontWeight.w700),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: Cores.surfaceRaised,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Cores.frame, width: 3),
      ),
      titleTextStyle: TextStyle(
        fontFamily: Fontes.display,
        fontSize: 26,
        color: Cores.ink,
      ),
      contentTextStyle: Estilos.body,
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: Cores.inkMuted,
      textColor: Cores.ink,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Cores.surfaceSunken,
      indicatorColor: Cores.groveSoft,
      indicatorShape: const RoundedRectangleBorder(),
      surfaceTintColor: Colors.transparent,
      height: 68,
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? Cores.grove
              : Cores.inkMuted,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => Estilos.label.copyWith(
          color: states.contains(WidgetState.selected)
              ? Cores.grove
              : Cores.inkMuted,
        ),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Cores.surfaceRaised,
      selectedColor: Cores.grove,
      disabledColor: Cores.surfaceSunken,
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: Cores.lineStrong, width: 2),
      ),
      labelStyle: Estilos.menu.copyWith(fontSize: 10, color: Cores.ink),
      secondaryLabelStyle: Estilos.menu.copyWith(
        fontSize: 10,
        color: Cores.onGrove,
      ),
      showCheckmark: false,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: Cores.grove,
    ),
  );
}
