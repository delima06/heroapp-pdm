# 🛡️ Vanguard Heroes - Comando Tático

Aplicativo móvel desenvolvido em **Flutter** para a disciplina de **Desenvolvimento para Dispositivos Móveis (PDM)** do curso de Tecnologia em Análise e Desenvolvimento de Sistemas (TADS) da **Universidade Federal do Rio Grande do Norte (UFRN)**, sob orientação do professor **Taniro C. Rodrigues**.

---

## 📱 Sobre o Projeto

O **Vanguard Heroes** é uma plataforma tática de gerenciamento e combate de super-heróis inspirada no universo dos quadrinhos. O aplicativo consome um banco de dados de mais de 560 heróis, permitindo ao usuário explorar o catálogo geral, recrutar novos agentes diariamente, administrar um esquadrão exclusivo de até 15 integrantes e participar de missões táticas por rodadas com evolução de atributos.

O app adota arquitetura **Offline-First**, garantindo que todas as telas e operações essenciais continuem funcionando perfeitamente mesmo sem conexão ativa com a internet.

---

## 🚀 Funcionalidades Principais

### 1. 🏢 Quartel-General (Home)
* Tela inicial com identidade visual moderna e logo oficial do **Vanguard Heroes**.
* Acesso direto e fluido aos 4 módulos operacionais do aplicativo.

### 2. 👥 Catálogo de Agentes
* Listagem completa e paginada de todos os 563 super-heróis utilizando `infinite_scroll_pagination`.
* Cards informativos com foto em miniatura (`cached_network_image`), nome, editora (Marvel, DC, etc.), gênero, raça e powerstats principais.
* Cache automático no banco local **SQLite** à medida que novas páginas são navegadas.

### 3. 🔍 Ficha Técnica do Agente
* Exibição da imagem oficial em alta resolução com tratamento de carregamento e erro.
* Seção biográfica completa: nome real, local de nascimento, primeira aparição, alinhamento moral e afiliações.
* Gráfico de barras dos 6 atributos táticos (`primer_progress_bar`): Inteligência, Força, Velocidade, Durabilidade, Poder e Combate.

### 4. 📅 Contrato Diário (Convocação 24h)
* Sistema determinístico de sorteio de 1 agente a cada ciclo de 24 horas utilizando `SharedPreferences`.
* O herói sorteado pode ser analisado e recrutado para o esquadrão tático com um clique.
* Validação de limite máximo de 15 agentes e proteção contra recrutamento duplicado.

### 5. 🎖️ Meu Esquadrão
* Gestão completa dos heróis recrutados pelo jogador através do Contrato Diário (limite máximo de 15 agentes).
* Identificação do **Papel Tático** do agente com base no seu maior atributo (ex: *Líder Estrategista*, *Tanque de Choque*, *Especialista em Combate*, *Velocista Tático*).
* Tela individual com opção de dispensar agente do esquadrão, com diálogo de confirmação interativo estilizado via `awesome_dialog`.

### 6. ⚔️ Central de Missões Táticas
* Exige esquadrão mínimo de 5 agentes operacionais.
* Simulação de batalhas dinâmicas de 3 a 5 rounds contra vilões e rivais sorteados.
* Cada round sorteia um atributo em disputa (ex: Força contra Força, Inteligência contra Inteligência).
* Grid de seleção tática com regra estrita: **cada agente só pode lutar em 1 round por missão**.
* Ao vencer a missão, todos os agentes do esquadrão que triunfaram em seus rounds recebem **+1 permanente no atributo vitorioso**, persistido no SQLite local.
* Diálogos de vitória ou derrota com ilustrações temáticas via `awesome_dialog`.

---

## 🏛️ Arquitetura e Padrões de Projeto

```text
               ┌─────────────────────────────────┐
               │     Telas e Widgets (UI)        │
               └────────────────┬────────────────┘
                                │ Consumer / context.watch / context.read
               ┌────────────────▼────────────────┐
               │    HeroProvider (ChangeNotifier)│
               └────────┬────────────────┬───────┘
                        │                │
         Requisições    │                │ Operações CRUD
         com Fallback   ▼                ▼ Local
               ┌────────────────┐┌───────────────┐
               │ HeroApiService ││DatabaseHelper │
               │  (Render API)  ││ (SQLite Local)│
               └────────────────┘└───────────────┘
```

* **Offline-First:** O app consome a API REST hospedada na nuvem e grava o espelho dos dados na tabela `heroes_cache` do SQLite. Caso a rede falhe ou fique sem sinal, o aplicativo lê instantaneamente do banco local.
* **Singleton Pattern:** Implementado na classe `DatabaseHelper` (`_internal()`), garantindo uma única instância e conexão ativa com o banco `heroapp.db`.
* **State Management (Provider):** Gerenciamento centralizado reativo com `HeroProvider` estendendo `ChangeNotifier`.
* **Dependency Tree (`ConfigureProviders`):** Inicialização antecipada assíncrona antes da renderização do primeiro frame (`WidgetsFlutterBinding.ensureInitialized()`).
* **Persistência Temporal:** `SharedPreferences` para controle de data ISO e controle de sorteio diário de 24h.

---

## 📦 Bibliotecas e Tecnologias

| Pacote | Finalidade no Projeto |
| :--- | :--- |
| **`flutter`** / **`dart`** | SDK e linguagem base do projeto |
| **`provider`** | Gerenciamento de estado reativo e injeção de dependência |
| **`sqflite`** & **`path`** | Banco de dados relacional SQLite local |
| **`http`** | Consumo de API REST remota com paginação |
| **`shared_preferences`** | Persistência leve chave-valor para o ciclo de 24h |
| **`infinite_scroll_pagination`** | Paginação infinita otimizada no catálogo de heróis |
| **`cached_network_image`** | Download, cache em disco e placeholder de imagens |
| **`primer_progress_bar`** | Barras de progresso estilizadas para os 6 powerstats |
| **`awesome_dialog`** | Diálogos modais animados para confirmações e missões |

---

## 💻 Como Executar o Projeto

### Pré-requisitos
* Flutter SDK (versão 3.x ou superior)
* Android Studio / SDK configurado
* Dispositivo físico Android conectado via USB/Wi-Fi com depuração ativada (ou emulador Android)

### Passo a Passo

1. **Clone o repositório:**
   ```bash
   git clone https://github.com/delima06/heroapp-pdm.git
   cd heroapp-pdm
   ```

2. **Instale as dependências:**
   ```bash
   flutter pub get
   ```

3. **Execute o aplicativo:**
   ```bash
   flutter run
   ```

---

## 👨‍💻 Autor

* **Thiago de Lima** - [GitHub](https://github.com/delima06)  
* Curso de Tecnologia em Análise e Desenvolvimento de Sistemas (TADS) - UFRN  
* Disciplina de Desenvolvimento para Dispositivos Móveis (PDM) - 2026