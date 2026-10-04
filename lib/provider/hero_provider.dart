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

  // Sincroniza o estado em memória com a tabela SQLite e dispara atualização reativa nos widgets assinantes
  Future<void> loadSquad() async {
    _squad = await _dbHelper.getSquad();
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
      _isLoading = false;
      notifyListeners();
      return;
    }

    // Se o ciclo virou (nova data), gera número pseudoaleatório entre 1 e 563 e armazena os metadados
    final randomId = Random().nextInt(563) + 1;
    _dailyHero = await _apiService.getHeroById(randomId);
    
    // Grava atomicamente o novo carimbo temporal e a semente sorteada
    await prefs.setString('dailyHeroDate', today);
    await prefs.setInt('dailyHeroId', randomId);

    _isLoading = false;
    notifyListeners();
  }
}
