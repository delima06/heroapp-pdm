# HeroApp PDM - Guia do Projeto e Diretrizes para IA

Este repositório contém o trabalho prático da disciplina de **Desenvolvimento para Dispositivos Móveis (PDM)**, ministrada pelo professor **Taniro C. Rodrigues** na UFRN.

---

## ⚠️ DIRETRIZES CRÍTICAS PARA A IA (LEIA ANTES DE ORIENTAR O ALUNO)

Se uma nova sessão for iniciada, a IA **DEVE** seguir estas regras estritamente:

1. **MODO PAIR PROGRAMMING PEDAGÓGICO:**
   - **NÃO crie ou edite arquivos de código Dart diretamente** com ferramentas automáticas.
   - Forneça o código no chat, explique **linha por linha o que faz e o porquê**, e deixe o **ALUNO escrever/colar** e entender ativamente. O professor fará uma entrevista oral individual cobrando a explicação do código.
   - Sempre aponte pequenos erros de digitação (typos, imports, pontos e vírgulas) com clareza.

2. **REGRAS E ESCOPO DAS AULAS (SEM CÓDIGO AVANÇADO):**
   - O projeto deve seguir estritamente o que foi ensinado nos slides das Aulas 04, 05, 06, 08, 09, 11 e 12 presentes na raiz do repositório.
   - Não use arquiteturas complexas (como Clean Architecture com BLoC, Riverpod, MobX, GetX, etc.). O gerenciamento de estado obrigatório é com **`provider`**.
   - Se for necessário algo fora dos slides, a IA **deve avisar o aluno antes**.

3. **PADRÃO ESPECÍFICO DO PROFESSOR PARA PROVIDER (AULA 11):**
   - O professor exige a classe `ConfigureProviders` com o método estático `Future<ConfigureProviders> createDependencyTree() async`.
   - Ela retorna uma lista de `SingleChildWidget` contendo `ChangeNotifierProvider<...>.value(...)`.
   - No `main()`, o app inicializa com `WidgetsFlutterBinding.ensureInitialized()`, aguarda `ConfigureProviders.createDependencyTree()` e envolve o `MyApp` em um `MultiProvider(providers: data.providers, child: MyApp())`.

4. **REQUISITOS DA AULA 12 (TRABALHO 1):**
   - **Offline-First:** Dados da API salvos no SQLite local (`sqflite`). Sem internet, o app busca do cache local.
   - **Bibliotecas Obrigatórias:**
     - `http` (ou `dio`) para consumir o mock.
     - `sqflite` e `path` para banco local (contrato + helper).
     - `provider` (com `ConfigureProviders`).
     - `shared_preferences` (sorteio diário de 1 herói).
     - `infinite_scroll_pagination` (listagem do catálogo com `PagedListView`).
     - `cached_network_image` (cache de imagens).
     - `primer_progress_bar` (barras dos 6 atributos na tela de detalhes).
     - `awesome_dialog` (confirmação ao dispensar herói e feedback da missão).
   - **Telas:**
     1. *Tela Inicial*: 4 opções (Agentes, Contrato Diário, Meu Esquadrão, Missões).
     2. *Agentes (Catálogo Geral)*: Scroll infinito, cache SQLite, miniatura e card com powerstats.
     3. *Detalhes do Agente*: Imagem alta resolução, dados gerais e 6 barras de progresso (`primer_progress_bar`).
     4. *Contrato Diário*: 1 sorteio a cada 24h via `SharedPreferences`. Botão "Recrutar" salva no SQLite (limite 15 heróis).
     5. *Meu Esquadrão*: Lista os heróis recrutados (máx 15) com papel tático / maior atributo. Toque abre tela de detalhes com botão "Dispensar" usando `awesome_dialog`.
     6. *Missões*: Mínimo 5 agentes no esquadrão. Batalha de 3 a 5 rounds contra vilão sorteado. Grid 3x5 de seleção. Sem repetição de agente por missão. Resultado e premiação (+1 de atributo) via `awesome_dialog`.

---

## 📁 Estrutura de Pastas do Projeto

```text
heroapp-pdm/
├── lib/
│   ├── database/
│   │   ├── hero_contract.dart     # Contrato de tabelas e colunas (Aula 08)
│   │   └── database_helper.dart   # Singleton Helper com SQLite/sqflite (Aula 08)
│   ├── models/
│   │   └── HeroModel.dart         # Modelo com fromJson, toMap, fromMap, stats (Aula 06/08)
│   ├── provider/ (ou providers/)
│   │   ├── hero_provider.dart     # ChangeNotifier com estado do esquadrão e sorteio diário
│   │   └── configure_providers.dart # Árvore de dependências (Aula 11)
│   ├── screens/                   # Telas do aplicativo
│   │   ├── home_screen.dart
│   │   ├── agents_screen.dart
│   │   ├── agent_detail_screen.dart
│   │   ├── daily_contract_screen.dart
│   │   ├── squad_screen.dart
│   │   ├── squad_detail_screen.dart
│   │   └── mission_screen.dart
│   ├── services/
│   │   └── hero_api_service.dart  # Chamadas HTTP com fallback offline
│   └── main.dart                  # Inicialização com MultiProvider
├── db.json                        # Mock dos heróis para o json-server
└── pubspec.yaml                   # Dependências do projeto
```

---

## 🛠️ Status Atual do Projeto

- [x] Criação do projeto Flutter (`heroapp_pdm`).
- [x] Instalação de todas as dependências no `pubspec.yaml`.
- [x] Configuração de permissões de internet e `usesCleartextTraffic` no `AndroidManifest.xml`.
- [x] Geração do arquivo `db.json` com os 563 heróis.
- [x] Criação de `lib/models/HeroModel.dart`.
- [x] Criação de `lib/database/hero_contract.dart`.
- [x] Criação de `lib/database/database_helper.dart`.
- [x] Criação de `lib/services/hero_api_service.dart`.
- [x] Criação de `lib/provider/hero_provider.dart` e `configure_providers.dart` (necessita de pequenos ajustes de sintaxe listados abaixo).
- [ ] Ajustar sintaxe em `hero_provider.dart` e `configure_providers.dart`.
- [ ] Configuração do `lib/main.dart` com rotas e `ConfigureProviders`.
- [ ] Construção das Telas (`screens/`).
- [ ] Testes no dispositivo móvel / emulador.