# 🦸 Guia Definitivo de Estudo - Entrevista Oral (HeroApp PDM)
**Disciplina:** Desenvolvimento para Dispositivos Móveis (PDM)  
**Professor:** Taniro C. Rodrigues - UFRN  

---

## 📌 1. Visão Geral da Arquitetura do Aplicativo

O projeto adota uma arquitetura em camadas clara, modular e orientada a componentes:

```text
               ┌───────────────────────────────┐
               │    Screens (UI / Widgets)     │
               └──────────────┬────────────────┘
                              │ Consome estado reativo (Consumer / watch / read)
               ┌──────────────▼────────────────┐
               │   Provider (HeroProvider)     │
               └──────┬─────────────────┬──────┘
                      │                 │
       Busca/Persiste │                 │ Consulta / Sincroniza
                      ▼                 ▼
   ┌───────────────────────┐       ┌────────────────────────┐
   │ SQLite/DatabaseHelper │◄──────┤  HeroApiService (HTTP) │
   └───────────────────────┘ Cache └────────────────────────┘
```

---

## 🎯 2. Perguntas Estratégicas para a Entrevista Oral

### ❓ P1: Como funciona o padrão Offline-First neste aplicativo?
> **O que responder:**
> O aplicativo foi construído para funcionar perfeitamente com ou sem internet.
> 1. Quando o app solicita heróis no `HeroApiService.fetchHeroes()`, ele tenta primeiro consumir o servidor local mockado (`http://...:3000/heroes`) com um `timeout` de 4 segundos.
> 2. Se a requisição for bem-sucedida, os dados recebidos são salvos em lote (`Batch`) na tabela de cache do SQLite (`cache_heroes`) com o algoritmo `ConflictAlgorithm.replace`.
> 3. Se a internet falhar, o servidor cair ou houver timeout, o bloco `catch` intercepta o erro e busca os dados paginados diretamente do cache local do SQLite através de `_dbHelper.getHeroesFromCache(offset, limit)`.
> 4. Há ainda um terceiro fallback para a CDN online pública caso o SQLite ainda esteja vazio.

---

### ❓ P2: Por que você utilizou a classe `ConfigureProviders` com `createDependencyTree()`?
> **O que responder (Exigência da Aula 11):**
> O método estático `ConfigureProviders.createDependencyTree()` implementa o padrão de Inversão de Controle e Injeção de Dependências.
> No `main()`, antes de chamar `runApp()`, chamamos `WidgetsFlutterBinding.ensureInitialized()` e aguardamos `ConfigureProviders.createDependencyTree()`.
> Esse método carrega os dados persistidos do SQLite na memória (`await heroProvider.loadSquad()`) **antes** de construir o primeiro widget. Isso garante que, ao montar a árvore com `MultiProvider`, o estado da aplicação já esteja pronto, prevenindo travamentos ou telas piscando.

---

### ❓ P3: Qual a diferença prática entre `context.read()`, `context.watch()` e `Consumer`?
> **O que responder:**
> - **`context.read<HeroProvider>()`**: Usado em chamadas de ação pontuais (ex: botões `onPressed`). Ele apenas executa o método (`recruitHero`, `dismissHero`) sem assinar o widget para redesenho quando o provider chamar `notifyListeners()`.
> - **`context.watch<HeroProvider>()`**: Assina o widget inteiro. Sempre que qualquer alteração de estado ocorrer no provider, o método `build` daquele widget é completamente reexecutado.
> - **`Consumer<HeroProvider>`**: Reconstrói **apenas** o bloco de widgets envolvido pelo seu `builder`, otimizando a performance e evitando reconstruções desnecessárias da tela inteira.

---

### ❓ P4: Como funciona a paginação infinita com o pacote `infinite_scroll_pagination`?
> **O que responder:**
> O componente central é o `PagingController<int, HeroModel>(firstPageKey: 1)`.
> Ele registra um ouvinte com `addPageRequestListener((pageKey) => _fetchPage(pageKey))`.
> Conforme o usuário rola o `PagedListView`, a biblioteca detecta quando o final da lista está próximo e solicita a próxima página. Se a quantidade de itens retornados for menor que o limite (`pageSize = 20`), chamamos `appendLastPage()`, indicando o fim da paginação; caso contrário, chamamos `appendPage(novosItens, nextPageKey)`.

---

### ❓ P5: Como foi garantido que o sorteio diário ocorra apenas 1 vez a cada 24 horas?
> **O que responder:**
> Usamos a biblioteca **`shared_preferences`**.
> No método `loadDailyHero()` do `HeroProvider`:
> 1. Salvamos a data atual formatada (`YYYY-MM-DD`, ex: `2026-10-03`) na chave `'dailyHeroDate'` e o ID do herói sorteado na chave `'dailyHeroId'`.
> 2. Toda vez que a tela de Contrato Diário é aberta, o app recupera esses valores. Se a data for igual à data de hoje e houver um ID salvo, o app busca diretamente o herói correspondente daquele ID.
> 3. Se a data for diferente (ou seja, virou o dia), o app sorteia um novo ID aleatório entre 1 e 563 e atualiza os valores salvos no `SharedPreferences`.

---

### ❓ P6: Como foi modelado o banco de dados SQLite local?
> **O que responder (Aulas 08 e 12):**
> Usamos o pacote `sqflite` e `path`. Criamos duas classes principais:
> - **`HeroContract`**: Define como constantes os nomes das tabelas e das colunas, evitando erros de digitação (*magic strings*).
> - **`DatabaseHelper`**: Implementa o padrão **Singleton** (`_internal()`), garantindo que apenas uma instância de conexão com o banco `heroapp.db` exista em todo o ciclo de vida do app.
> Criamos 2 tabelas distintas:
> 1. `cache_heroes`: Armazena todos os heróis recebidos da API para leitura offline.
> 2. `squad_table`: Armazena os heróis recrutados pelo jogador (máximo de 15), permitindo atualização independente de atributos após as missões.

---

### ❓ P7: Como funciona a mecânica da tela de Missões?
> **O que responder (Slides 10 a 13 da Aula 12):**
> 1. **Mínimo de Agentes:** A tela valida se `provider.squad.length >= 5`. Se tiver menos de 5, bloqueia a batalha.
> 2. **Sorteio do Desafio:** Sorteia de 3 a 5 rounds. Para cada round, sorteia um vilão que **não pertence ao esquadrão** (usando um `while` com `squadIds.contains(enemy.id)`), e sorteia qual dos 6 powerstats será o critério de disputa.
> 3. **Escalação sem repetição:** O usuário escolhe 1 agente no Grid. Ao combater, o ID do herói vai para o conjunto `Set<int> _usedHeroIds`. Esse herói fica com opacidade reduzida e o status "Exausto", impedindo que seja usado duas vezes na mesma missão.
> 4. **Resolução:** Compara o atributo do herói com o do vilão (Vitória, Derrota ou Empate).
> 5. **Premiação e Feedback:** Ao final, se o jogador venceu a maioria dos rounds, um dos heróis vitoriosos é sorteado, ganha **+1 de atributo** salvo no banco pelo `provider.upgradeHeroStat()` e o `AwesomeDialog` do tipo `DialogType.success` é exibido. Caso contrário, exibe `DialogType.error`.

---

## 🛠️ 3. Resumo dos Pacotes Obrigatórios e sua Finalidade

| Pacote | Finalidade no Projeto |
| :--- | :--- |
| **`provider`** | Gerenciamento de estado reativo e injeção de dependências |
| **`sqflite` + `path`** | Banco de dados local SQLite (cache offline e tabela do esquadrão) |
| **`http`** | Consumo do backend mock (`json-server`) e APIs REST |
| **`shared_preferences`** | Persistência de chave-valor para controle do sorteio diário de 24h |
| **`infinite_scroll_pagination`** | Paginação infinita sob demanda no catálogo de heróis |
| **`cached_network_image`** | Download em segundo plano e cache em disco das fotos dos heróis |
| **`primer_progress_bar`** | Renderização das 6 barras de atributos com segmentos coloridos |
| **`awesome_dialog`** | Diálogos animados de confirmação (dispensar agente) e feedback de missões |
