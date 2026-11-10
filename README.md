# Old Reece — Barbearia

App Flutter de agendamento para barbearia/cabeleireiro com a estética de GTA San Andreas: HUD com contorno preto, dinheiro verde, estrelas de "procurado" e "Missão cumprida" ao fechar um agendamento.

O cliente escolhe o barbeiro, o corte e um horário em algum dia da semana. Depois acompanha a agenda, cancela quando precisar e avalia o atendimento. Os dados ficam no Firebase e aparecem em tempo real.

**App publicado:** https://old-reece.web.app

**Conta de demonstração:** `cj@oldreece.com` / `Grove@Street1` (já tem histórico e um atendimento esperando avaliação). Também dá para criar uma conta nova pela tela de cadastro.

## Como rodar

```bash
flutter pub get
flutter run -d chrome   # ou -d edge
flutter test            # usa Firebase e API falsos, não precisa de internet
```

O projeto já vem conectado ao Firebase `old-reece` (`lib/firebase_options.dart`), então não precisa configurar nada. A chave desse arquivo só identifica o projeto; quem protege os dados são as regras em `firestore.rules`.

Para publicar uma nova versão:

```bash
flutter build web
firebase deploy --only hosting,firestore:rules
```

## Requisitos atendidos

| Requisito | Onde |
| --- | --- |
| RF001 Autenticação | `lib/controller/auth_controller.dart` (Firebase Authentication), `login_view.dart` e `recuperar_senha_view.dart`. Erros traduzidos em `lib/core/erros.dart` |
| RF002 Registro | `cadastrar_usuario_view.dart` + `auth_controller.dart`: telefone, CEP, bairro e cidade, além do nome, na coleção `usuarios`. Senha validada em `lib/core/validadores.dart` (8 caracteres, maiúscula, minúscula e caractere especial) |
| RF003 Inserção | `AgendamentoController.confirmar` em `lib/controller/agendamento_controller.dart`, com mensagem de sucesso ou erro. Dados separados por usuário em `usuarios/{uid}/agendamentos` e protegidos por `firestore.rules` |
| RF004 Recuperação | `lib/widgets/dados_ao_vivo.dart` (`StreamBuilder`, falha e "tentar de novo") usado com `ListView` em `barbeiros_view.dart` e `agendamentos_view.dart` e com `GridView` em `cortes_view.dart` |
| RF005 API REST | `lib/service/viacep_service.dart`: o ViaCEP preenche bairro e cidade a partir do CEP no cadastro |

## Banco de dados (Firestore)

| Coleção | Conteúdo | Acesso |
| --- | --- | --- |
| `usuarios/{uid}` | nome, e-mail, telefone, CEP, bairro, cidade, criadoEm | Só o próprio usuário |
| `usuarios/{uid}/agendamentos` | barbeiro, corte, preço, data, cancelado, avaliação, comentário | Só o próprio usuário |
| `barbeiros` | nome, foto, especialidade, bio, frase, estrelas, experiência, dias, cortes | Leitura para quem está logado |
| `cortes` | nome, descrição, imagem, preço, duração, categoria, destaque | Leitura para quem está logado |
| `horarios_ocupados` | barbeiro, dia, hora, uid de quem reservou e id do agendamento, sem dados pessoais | Leitura para quem está logado; cada um só apaga a própria reserva |

Cada reserva usa o id `barbeiro_dia_hora`. O agendamento e a reserva são gravados numa transação, então dois clientes não conseguem pegar o mesmo horário. O conteúdo do catálogo também está em `test/dados_teste.dart`.

## Funcionalidades

1. **Início** (`inicio_view.dart`): saudação, próximo horário, atalho para agendar e cortes em alta.
2. **Barbeiros** (`barbeiros_view.dart`): lista com especialidade e avaliação.
3. **Perfil do barbeiro** (`barbeiro_detalhe_view.dart`): foto, bio, dias e serviços com preço.
4. **Catálogo de cortes** (`cortes_view.dart`): grade com filtro por categoria e detalhes do corte.
5. **Agendar horário** (`agendar_view.dart`): barbeiro → serviço → dia da semana → horário livre.
6. **Missão cumprida** (`confirmacao_view.dart`): confirmação com o resumo do agendamento.
7. **Minha agenda** (`agendamentos_view.dart`): próximos horários (com cancelamento) e histórico.
8. **Avaliar atendimento** (`avaliar_view.dart`): nota de 1 a 6 estrelas e comentário.
9. **Perfil** (`perfil_view.dart`) e **Sobre** (`sobre_view.dart`): dados da conta, sair e informações do projeto.

## Arquitetura

- **Estado:** cada tela tem um controller `ChangeNotifier` (`lib/controller/`), registrado como singleton no `get_it` (`lib/core/dependencias.dart`). O `AuthController` guarda o usuário logado, então o nome editado no perfil aparece no app inteiro.
- **Tempo real:** os controllers expõem `Stream`s do Firestore, e o widget `DadosAoVivo` as mostra na tela com `StreamBuilder`.
- **Navegação:** rotas nomeadas em `lib/core/app_routes.dart`. O `onGenerateRoute` em `main.dart` só deixa abrir as telas internas com o usuário autenticado. A sessão continua ativa ao reabrir o app.
- **Design system:** é o "Barbearia SA". Os tokens de cor, tipo, espaçamento e sombra estão em `lib/core/tema.dart` e os componentes em `lib/widgets/` (`SaBotao`, `Painel`, `PrecoHud`, `Estrelas`, `Etiqueta`, `TituloZona`, `PainelMissao`).
- **Fontes:** foram usados os substitutos livres do Google Fonts: Anton (no lugar da Pricedown), Michroma (no lugar da Bank Gothic) e Pirata One (no lugar da Diploma). Os arquivos estão em `assets/fonts/` (licença OFL).
- **Imagens:** os barbeiros estão em `lib/barbers/`, os cortes em `lib/cortes/` e o logotipo em `assets/images/logo.png`.

---

Projeto acadêmico sem fins comerciais. A estética é inspirada em GTA San Andreas, marca da Rockstar Games / Take-Two.
