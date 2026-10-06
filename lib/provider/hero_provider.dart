import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/HeroModel.dart';
import '../database/database_helper.dart';
import '../services/hero_api_service.dart';

// Gerenciador de estado reativo baseado no padrão Observer (ChangeNotifier)
class HeroProvider extends ChangeNotifier {
  // Injeção de dependências das camadas de persistência local e comunicação HTTP
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final HeroApiService _apiService = HeroApiService(); 

  // Estado mutável privado exposto por meio de getters imutáveis (encapsulamento)
  List<HeroModel> _squad = [];
  List<HeroModel> get squad => _squad;
  
  HeroModel? _dailyHero;
  HeroModel? get dailyHero => _dailyHero;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // 5 heróis iniciais pré-definidos para o esquadrão base
  static final List<HeroModel> _initialHeroes = [
    HeroModel(
      id: 620,
      name: 'Spider-Man',
      imageUrl: 'https://cdn.jsdelivr.net/gh/akabab/superhero-api@0.3.0/api/images/sm/620-spider-man.jpg',
      imagelLgUrl: 'https://cdn.jsdelivr.net/gh/akabab/superhero-api@0.3.0/api/images/lg/620-spider-man.jpg',
      intelligence: 90,
      strength: 55,
      speed: 67,
      durability: 75,
      power: 74,
      combat: 85,
      gender: 'Male',
      race: 'Human',
      alignment: 'good',
      publisher: 'Marvel Comics',
      fullName: 'Peter Parker',
    ),
    HeroModel(
      id: 70,
      name: 'Batman',
      imageUrl: 'https://cdn.jsdelivr.net/gh/akabab/superhero-api@0.3.0/api/images/sm/70-batman.jpg',
      imagelLgUrl: 'https://cdn.jsdelivr.net/gh/akabab/superhero-api@0.3.0/api/images/lg/70-batman.jpg',
      intelligence: 100,
      strength: 26,
      speed: 27,
      durability: 50,
      power: 47,
      combat: 100,
      gender: 'Male',
      race: 'Human',
      alignment: 'good',
      publisher: 'DC Comics',
      fullName: 'Bruce Wayne',
    ),
    HeroModel(
      id: 346,
      name: 'Iron Man',
      imageUrl: 'https://cdn.jsdelivr.net/gh/akabab/superhero-api@0.3.0/api/images/sm/346-iron-man.jpg',
      imagelLgUrl: 'https://cdn.jsdelivr.net/gh/akabab/superhero-api@0.3.0/api/images/lg/346-iron-man.jpg',
      intelligence: 100,
      strength: 85,
      speed: 58,
      durability: 85,
      power: 100,
      combat: 64,
      gender: 'Male',
      race: 'Human',
      alignment: 'good',
      publisher: 'Marvel Comics',
      fullName: 'Tony Stark',
    ),
    HeroModel(
      id: 717,
      name: 'Wolverine',
      imageUrl: 'https://cdn.jsdelivr.net/gh/akabab/superhero-api@0.3.0/api/images/sm/717-wolverine.jpg',
      imagelLgUrl: 'https://cdn.jsdelivr.net/gh/akabab/superhero-api@0.3.0/api/images/lg/717-wolverine.jpg',
      intelligence: 63,
      strength: 32,
      speed: 50,
      durability: 100,
      power: 89,
      combat: 100,
      gender: 'Male',
      race: 'Mutant',
      alignment: 'good',
      publisher: 'Marvel Comics',
      fullName: 'Logan',
    ),
    HeroModel(
      id: 659,
      name: 'Thor',
      imageUrl: 'https://cdn.jsdelivr.net/gh/akabab/superhero-api@0.3.0/api/images/sm/659-thor.jpg',
      imagelLgUrl: 'https://cdn.jsdelivr.net/gh/akabab/superhero-api@0.3.0/api/images/lg/659-thor.jpg',
      intelligence: 69,
      strength: 100,
      speed: 83,
      durability: 100,
      power: 100,
      combat: 100,
      gender: 'Male',
      race: 'Asgardian',
      alignment: 'good',
      publisher: 'Marvel Comics',
      fullName: 'Thor Odinson',
    ),
  ];

  // Sincroniza o estado em memória com a tabela SQLite e dispara atualização reativa nos widgets assinantes
  Future<void> loadSquad() async {
    _squad = await _dbHelper.getSquad();
    
    // Se o esquadrão tiver menos de 5 heróis, adiciona os heróis pré-definidos
    if (_squad.length < 5) {
      for (final hero in _initialHeroes) {
        if (!isInSquad(hero.id) && _squad.length < 5) {
          await _dbHelper.recruitHero(hero);
          _squad.add(hero);
        }
      }
    }
    
    notifyListeners();
  }

  // Validação em memória de existência por ID com complexidade O(n)
  bool isInSquad(int id) {
    return _squad.any((squadHero) => squadHero.id == id);
  }

  // Operação atômica de recrutamento: aplica validações de negócio, persiste no SQLite e propaga novo estado
  Future<bool> recruitHero(HeroModel hero) async {
    // Validação 1: Impede extrapolação do teto máximo de 15 agentes no elenco
    if (_squad.length >= 15) {
      return false;
    }
    // Validação 2: Impede duplicação de chave primária no esquadrão
    if (isInSquad(hero.id)) {
      return false;
    }
    await _dbHelper.recruitHero(hero); // Executa INSERT OR REPLACE na tabela squad_table
    await loadSquad(); // Recarrega do banco e executa notifyListeners()
    return true;
  }

  // Exclusão por ID: executa DELETE no SQLite e reconstrói as árvores de UI consumidoras
  Future<void> dismissHero(int id) async {
    await _dbHelper.dismissHero(id);
    await loadSquad();
  }

  // Mutação de atributo: altera a entidade de domínio e sincroniza via UPDATE SQL
  Future<void> upgradeHeroStat(HeroModel hero, String statName) async {
    hero.boostStat(statName); // Incrementa o atributo no objeto em memória
    await _dbHelper.updateHeroStats(hero); // Grava a alteração no banco local
    await loadSquad(); // Notifica os componentes da interface
  }

  // Controle de persistência temporal: garante sorteio determinístico por ciclo de 24 horas usando SharedPreferences
  Future<void> loadDailyHero() async {
    _isLoading = true;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    // Normaliza a data no formato ISO-8601 truncado (YYYY-MM-DD) para conferência diária
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final lastDate = prefs.getString('dailyHeroDate');
    final lastHeroId = prefs.getInt('dailyHeroId');

    // Validação de idempotência diária: se a data do último sorteio coincidir com a atual, reutiliza o ID
    if (lastDate == today && lastHeroId != null) {
      _dailyHero = await _apiService.getHeroById(lastHeroId);
      // Se encontrou com sucesso o herói salvo, finaliza
      if (_dailyHero != null) {
        _isLoading = false;
        notifyListeners();
        return;
      }
      // Se retornou nulo (ID inexistente ou falha anterior), continua para sortear um agente válido
    }

    // Para evitar falha com IDs inexistentes (pois os IDs têm lacunas até 731),
    // sorteamos uma página entre 1 e 563 com limite 1, garantindo sempre um herói real
    final randomPage = Random().nextInt(563) + 1;
    final results = await _apiService.fetchHeroes(page: randomPage, limit: 1);

    if (results.isNotEmpty) {
      _dailyHero = results.first;
    } else {
      // Fallback Offline: sorteia do cache local do SQLite caso esteja sem rede
      _dailyHero = await _dbHelper.getRandomHeroFromCache();
    }
    
    // Grava atomicamente o novo carimbo temporal e o ID sorteado somente se o herói foi obtido com sucesso
    if (_dailyHero != null) {
      await prefs.setString('dailyHeroDate', today);
      await prefs.setInt('dailyHeroId', _dailyHero!.id);
    }

    _isLoading = false;
    notifyListeners();
  }
}
