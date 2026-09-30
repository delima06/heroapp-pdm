import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/HeroModel.dart';
import '../database/database_helper.dart';
import '../services/hero_api_service.dart';

class HeroProvider extends ChangeNotifier {
    final DatabaseHelper _dbhelper = DatabaseHelper();
    final HeroApiService _apiService = HeroApiService(); 

    List<HeroModel> _squad = [];
    List <HeroModel> get squad => _squad;
    
    HeroModel? _dailyHero;
    HeroModel? get dailyHero => _dailyHero;

    bool _isLoading = false;
    bool get isLoading => _isLoading;

    Future<void> loadSquad() async {
        _squad = await _dbhelper.getSquad();
        notifyListeners();
    }

    bool isInSquad(HeroModel hero) {
      return _squad.any((squadHero) => hero.id == squadHero.id);
    }
    Future<bool> recruitHero(HeroModel hero) async {
        if(_squad.length >= 15){
            return false;
        }
        if (isInSquad(hero.id)){
            return false;
        }
        await _dbHelper.recruitHero(hero);
        await loadSquad();
        return true;
    }
    Future<void> dismissHero(int id) async{
        await _dbHelper.dismissHero(id);
        await loadSquad();
    }

    Future<void> upgradeHeroStat(HeroModel hero, String statName) async {
        hero.boostStat(statName);
        await _dbHelper.updateHeroStats(hero);
        await loadSquad();
    }
    Future <void> loadDailyHero() async{
        _isLoadingDaily = true;
        notifyListeners();
        
        final prefs = await SharedPreferences.getInstance();
        final today = DateTime.now().toIso8601String().substring(0, 10);
        final lastDate = prefs.getString('dailyHeroDate');

        if(lastDate == today && lastHeroId != null){
            _dailyHero = await _dbhelper.getHeroById(int.parse(lastHeroId));
            _isLoadingDaily = false;
            notifyListeners();
            return;
        }
        final randomId = Random().nextInt(563) + 1;
        _dailyHero = await _apiService.getHeroById(randomId);
        
        await prefss.setString('dailyHeroDate', today);
        await prefs.setInt('dailyHeroId',randomId);

        _isLoadingDaily = false;
        notifyListeners();
    }
    

    
}