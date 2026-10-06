import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import '../models/HeroModel.dart';
import '../provider/hero_provider.dart';
import '../services/hero_api_service.dart';
import '../database/database_helper.dart';

class MissionScreen extends StatefulWidget {
  const MissionScreen({super.key});

  @override
  State<MissionScreen> createState() => _MissionScreenState();
}

class _MissionRound {
  final HeroModel enemy;
  final String statKey;
  final String statLabel;

  _MissionRound({
    required this.enemy,
    required this.statKey,
    required this.statLabel,
  });
}

class _MissionScreenState extends State<MissionScreen> {
  final HeroApiService _apiService = HeroApiService();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final Random _random = Random();

  bool _isLoading = true;
  List<_MissionRound> _rounds = [];
  int _currentRoundIndex = 0;

  // Controle de resultados da missão
  int _victories = 0;
  int _defeats = 0;
  int _draws = 0;

  // Guarda quais heróis do esquadrão já lutaram (não podem repetir)
  final Set<int> _usedHeroIds = {};
  final List<HeroModel> _winningHeroes = [];

  HeroModel? _selectedAgent;
  bool _roundResolved = false;
  String _roundResultMessage = '';
  Color _roundResultColor = Colors.grey;

  static const List<Map<String, String>> _availableStats = [
    {'key': 'intelligence', 'label': 'Inteligência'},
    {'key': 'strength', 'label': 'Força'},
    {'key': 'speed', 'label': 'Velocidade'},
    {'key': 'durability', 'label': 'Durabilidade'},
    {'key': 'power', 'label': 'Poder'},
    {'key': 'combat', 'label': 'Combate'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeMission();
    });
  }

  Future<void> _initializeMission() async {
    final provider = context.read<HeroProvider>();
    if (provider.squad.length < 5) {
      setState(() => _isLoading = false);
      return;
    }

    setState(() => _isLoading = true);

    // Sorteia de 3 a 5 rounds (Slide 10)
    final totalRounds = _random.nextInt(3) + 3;
    final List<_MissionRound> generatedRounds = [];

    final squadIds = provider.squad.map((h) => h.id).toSet();

    for (int i = 0; i < totalRounds; i++) {
      // Sorteia um inimigo fora do esquadrão
      HeroModel? enemy;
      while (enemy == null || squadIds.contains(enemy.id)) {
        final randomPage = _random.nextInt(563) + 1;
        final pool = await _apiService.fetchHeroes(page: randomPage, limit: 1);
        if (pool.isNotEmpty && !squadIds.contains(pool.first.id)) {
          enemy = pool.first;
        } else {
          final cached = await _dbHelper.getRandomHeroFromCache();
          if (cached != null && !squadIds.contains(cached.id)) {
            enemy = cached;
          }
        }
      }

      // Sorteia o atributo em disputa na rodada
      final chosenStat = _availableStats[_random.nextInt(_availableStats.length)];

      generatedRounds.add(
        _MissionRound(
          enemy: enemy,
          statKey: chosenStat['key']!,
          statLabel: chosenStat['label']!,
        ),
      );
    }

    setState(() {
      _rounds = generatedRounds;
      _currentRoundIndex = 0;
      _victories = 0;
      _defeats = 0;
      _draws = 0;
      _usedHeroIds.clear();
      _winningHeroes.clear();
      _selectedAgent = null;
      _roundResolved = false;
      _isLoading = false;
    });
  }

  // Executa a resolução do turno: compara os valores dos atributos e registra métricas
  void _confirmCombat() {
    if (_selectedAgent == null || _roundResolved) return;

    final round = _rounds[_currentRoundIndex];
    // Recupera o valor numérico do atributo exigido na rodada atual
    final agentStat = _selectedAgent!.getStatByName(round.statKey);
    final enemyStat = round.enemy.getStatByName(round.statKey);

    setState(() {
      _roundResolved = true;
      // Registra o ID do herói no Set de utilizados para bloqueá-lo em rodadas futuras da mesma missão
      _usedHeroIds.add(_selectedAgent!.id);

      // Avaliação determinística do confronto
      if (agentStat > enemyStat) {
        _victories++;
        _winningHeroes.add(_selectedAgent!); // Entra na lista elegível para premiação (+1 stat)
        _roundResultMessage = 'Vitória na Rodada! ($agentStat vs $enemyStat)';
        _roundResultColor = Colors.green.shade700;
      } else if (agentStat < enemyStat) {
        _defeats++;
        _roundResultMessage = 'Derrota na Rodada! ($agentStat vs $enemyStat)';
        _roundResultColor = Colors.red.shade700;
      } else {
        _draws++;
        _roundResultMessage = 'Empate Tático! ($agentStat vs $enemyStat)';
        _roundResultColor = Colors.amber.shade800;
      }
    });
  }

  void _nextRoundOrFinish() {
    if (_currentRoundIndex + 1 < _rounds.length) {
      setState(() {
        _currentRoundIndex++;
        _selectedAgent = null;
        _roundResolved = false;
        _roundResultMessage = '';
      });
    } else {
      _finishMission();
    }
  }

    void _finishMission() {
    final provider = context.read<HeroProvider>();
    // Slide 13: Venceu mais da metade dos rounds
    final isVictory = _victories > (_rounds.length / 2);

    if (isVictory) {
      // Sorteia um dos heróis vitoriosos para receber +1 de atributo
      final rewardingHero = _winningHeroes.isNotEmpty
          ? _winningHeroes[_random.nextInt(_winningHeroes.length)]
          : provider.squad.first;

      final rewardedStat = _availableStats[_random.nextInt(_availableStats.length)];
      provider.upgradeHeroStat(rewardingHero, rewardedStat['key']!);

      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.bottomSlide,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            children: [
              const Text(
                'Missão Cumprida!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              // Slide 13: Exibe a imagem do herói premiado
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: rewardingHero.imageUrl,
                  height: 120,
                  width: 120,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const SizedBox(
                    height: 120,
                    width: 120,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.person, size: 80),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Placar Final: $_victories Vitórias x $_defeats Derrotas ($_draws Empates)',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade300),
                ),
                child: Text(
                  '⭐ Recompensa de Honra:\n${rewardingHero.name} subiu de nível e ganhou +1 em ${rewardedStat['label']}!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.green.shade900,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        btnOkText: 'Concluir',
        btnOkColor: Colors.green.shade700,
        btnOkOnPress: () => Navigator.pop(context),
      ).show();
    } else {
      // Slide 13: Operação Fracassada com imagem de derrota
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.bottomSlide,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            children: [
              const Text(
                'Operação Fracassada!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red),
              ),
              const SizedBox(height: 12),
              // Imagem / ilustração de derrota
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.sentiment_very_dissatisfied,
                  size: 70,
                  color: Colors.red.shade700,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'O esquadrão não resistiu à investida inimiga.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 6),
              Text(
                'Placar Final: $_victories Vitórias x $_defeats Derrotas',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        btnOkText: 'Retornar ao QG',
        btnOkColor: Colors.red.shade700,
        btnOkOnPress: () => Navigator.pop(context),
      ).show();
    }
  }

  @override
  Widget build(BuildContext context) {
    final squad = context.watch<HeroProvider>().squad;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Simulação de Missão'),
        backgroundColor: Colors.red.shade800,
        foregroundColor: Colors.white,
      ),
      body: _buildBody(squad),
    );
  }

  Widget _buildBody(List<HeroModel> squad) {
    if (squad.length < 5) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shield_outlined, size: 80, color: Colors.red.shade300),
              const SizedBox(height: 16),
              const Text(
                'Esquadrão Incompleto!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'É necessário ter pelo menos 5 agentes no esquadrão para iniciar missões.\nVocê possui atualmente ${squad.length} agentes.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 15),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade700,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.person_add),
                label: const Text('Recrutar no Contrato Diário'),
                onPressed: () => Navigator.pushReplacementNamed(context, '/daily_contract'),
              ),
            ],
          ),
        ),
      );
    }

    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.red),
            SizedBox(height: 16),
            Text('Gerando Desafio de Crise e Inimigos...'),
          ],
        ),
      );
    }

    final currentRound = _rounds[_currentRoundIndex];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Placar e Progresso da Missão
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ROUND ${_currentRoundIndex + 1} DE ${_rounds.length}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade900,
                    letterSpacing: 1.1,
                  ),
                ),
                Text(
                  'V: $_victories | D: $_defeats',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.red.shade900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Card do Inimigo da Rodada (atributos ocultos)
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    'AMEAÇA DA RODADA',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: CachedNetworkImage(
                      imageUrl: currentRound.enemy.imageUrl,
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 90,
                        height: 90,
                        color: Colors.grey.shade200,
                        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 90,
                        height: 90,
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.person, size: 50, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentRound.enemy.name,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Disputa em: ${currentRound.statLabel.toUpperCase()}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.brown.shade800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Seletor de Agentes do Esquadrão (Grid 3x5)
          const Text(
            'ESCALAÇÃO DO ESQUADRÃO (SELECIONE 1 AGENTE)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 10),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: squad.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.9,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              final hero = squad[index];
              final isUsed = _usedHeroIds.contains(hero.id);
              final isSelected = _selectedAgent?.id == hero.id;

              return InkWell(
                onTap: (isUsed || _roundResolved)
                    ? null
                    : () {
                        setState(() => _selectedAgent = hero);
                      },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.red.shade50 : Colors.white,
                    border: Border.all(
                      color: isSelected
                          ? Colors.red.shade800
                          : (isUsed ? Colors.grey.shade300 : Colors.grey.shade400),
                      width: isSelected ? 2.5 : 1.0,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(6),
                  child: Opacity(
                    opacity: isUsed ? 0.35 : 1.0,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: hero.imageUrl,
                            width: 45,
                            height: 45,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              width: 45,
                              height: 45,
                              color: Colors.grey.shade200,
                            ),
                            errorWidget: (context, url, error) => Container(
                              width: 45,
                              height: 45,
                              color: Colors.grey.shade300,
                              child: const Icon(Icons.person, size: 24),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          hero.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                        if (isUsed)
                          const Text(
                            'Exausto',
                            style: TextStyle(fontSize: 10, color: Colors.red),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          // Feedback do resultado da rodada
          if (_roundResolved)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _roundResultColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _roundResultColor),
              ),
              child: Text(
                _roundResultMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _roundResultColor,
                ),
              ),
            ),

          // Botão de ação (Confirmar ou Próximo Round)
          SizedBox(
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _roundResolved ? Colors.indigo.shade800 : Colors.red.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _selectedAgent == null
                  ? null
                  : (_roundResolved ? _nextRoundOrFinish : _confirmCombat),
              child: Text(
                _roundResolved
                    ? (_currentRoundIndex + 1 < _rounds.length
                        ? 'Avançar para o Próximo Round'
                        : 'Ver Resultado da Missão')
                    : 'Confirmar Batalha com ${_selectedAgent!.name}',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
