import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/HeroModel.dart';
import '../database/database_helper.dart';

class HeroApiService {
  static const String localApiUrl = 'http://192.168.0.12:3000/heroes';
  static const String fallbackApiUrl = 'https://cdn.jsdelivr.net/gh/akabab/superhero-api@0.3.0/api/all.json';

  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<HeroModel>> fetchHeroes({required int page, required int limit}) async {
    try {
      final uri = Uri.parse('$localApiUrl?_page=$page&_limit=$limit');
      final response = await http.get(uri).timeout(const Duration(seconds: 4));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final heroes = data.map((json) => HeroModel.fromJson(json)).toList();
        await _dbHelper.saveHeroesCache(heroes);
        return heroes;
      } else {
        throw Exception('Erro ao carregar herois: ${response.statusCode}');
      }
    } catch (e) {
      final offset = (page - 1) * limit;
      final cachedHeroes = await _dbHelper.getHeroesFromCache(offset: offset, limit: limit);
      if (cachedHeroes.isNotEmpty) {
        return cachedHeroes;
      }
      try {
        final response = await http.get(Uri.parse(fallbackApiUrl)).timeout(const Duration(seconds: 5));
        if (response.statusCode == 200) {
          final List<dynamic> allData = json.decode(response.body);
          final allHeroes = allData.map((json) => HeroModel.fromJson(json)).toList();
          await _dbHelper.saveHeroesCache(allHeroes);
          return allHeroes.skip(offset).take(limit).toList();
        }
      } catch (_) {}
      return [];
    }
  }

  Future<HeroModel?> getHeroById(int id) async {
    try {
      final uri = Uri.parse('$localApiUrl/$id');
      final response = await http.get(uri).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        return HeroModel.fromJson(json.decode(response.body));
      }
    } catch (_) {}
    return await _dbHelper.getHeroById(id);
  }
}
