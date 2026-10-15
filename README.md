# Old Reece — Barbearia

App Flutter de agendamento para barbearia/cabeleireiro com a estética de GTA San Andreas: HUD com contorno preto, dinheiro verde, estrelas de "procurado" e "Missão cumprida" ao fechar um agendamento.

O cliente escolhe o barbeiro, o corte e um horário em algum dia da semana. Depois acompanha a agenda, cancela quando precisar e avalia o atendimento.

## Como rodar

```bash
flutter pub get
flutter run
flutter test   # testes do fluxo principal
```

**Conta de teste:** `cj@oldreece.com` / `123456`. Também dá para criar uma conta nova pela tela de cadastro. Os dados ficam em memória e são mockados.

## Requisitos atendidos

| Requisito | Onde |
| --- | --- |
| RF001 Login | `lib/view/login_view.dart` + `lib/controller/login_controller.dart` |
| RF002 Cadastro | `lib/view/cadastrar_usuario_view.dart` + `cadastrar_usuario_controller.dart` |
| RF003 Esqueceu a senha | `lib/view/recuperar_senha_view.dart` + `recuperar_senha_controller.dart` |
| RF004 Sobre | `lib/view/sobre_view.dart` (Perfil → Sobre o app) + `sobre_controller.dart` |
| RF005 Perfil | `lib/view/perfil_view.dart` (ícone na barra superior; também tem o botão de sair) + `perfil_controller.dart` |
| RF007 Listagem | `ListView` em `barbeiros_view.dart` e `agendamentos_view.dart`; `GridView` em `cortes_view.dart` |

### RF006: funcionalidades do tema (cada uma num arquivo próprio)

1. **Início** (`inicio_view.dart`): saudação, próximo horário, atalho para agendar e cortes em alta.
2. **Barbeiros** (`barbeiros_view.dart`): lista com especialidade e avaliação.
3. **Perfil do barbeiro** (`barbeiro_detalhe_view.dart`): foto, bio, dias e serviços com preço.
4. **Catálogo de cortes** (`cortes_view.dart`): grade com filtro por categoria e detalhes do corte.
5. **Agendar horário** (`agendar_view.dart`): barbeiro → serviço → dia da semana → horário livre.
6. **Missão cumprida** (`confirmacao_view.dart`): confirmação com o resumo do agendamento.
7. **Minha agenda** (`agendamentos_view.dart`): próximos horários (com cancelamento) e histórico.
8. **Avaliar atendimento** (`avaliar_view.dart`): nota de 0 a 6 estrelas e comentário.

## Arquitetura

- **Estado:** cada tela tem um controller `ChangeNotifier` (`lib/controller/`), registrado como singleton no `get_it` (`lib/core/dependencias.dart`). As telas escutam esses controllers com `ListenableBuilder`. O `AuthController` guarda o usuário logado, então o nome editado no perfil aparece no app inteiro.
- **Navegação:** rotas nomeadas em `lib/core/app_routes.dart`. O `onGenerateRoute` em `main.dart` só deixa abrir as telas internas (perfil, agenda etc.) com o usuário autenticado. Depois do login, a `HomeView` tem uma `NavigationBar` com 4 abas e o ícone de perfil na barra superior.
- **Design system:** é o "Barbearia SA". Os tokens de cor, tipo, espaçamento e sombra estão em `lib/core/tema.dart` e os componentes em `lib/widgets/` (`SaBotao`, `Painel`, `PrecoHud`, `Estrelas`, `Etiqueta`, `TituloZona`, `PainelMissao`).
- **Fontes:** foram usados os substitutos livres do Google Fonts: Anton (no lugar da Pricedown), Michroma (no lugar da Bank Gothic) e Pirata One (no lugar da Diploma). Os arquivos estão em `assets/fonts/` (licença OFL).
- **Imagens:** os barbeiros estão em `lib/barbers/`, os cortes em `lib/cortes/` e o logotipo em `assets/images/logo.png`.

---

Projeto acadêmico sem fins comerciais. A estética é inspirada em GTA San Andreas, marca da Rockstar Games / Take-Two.
