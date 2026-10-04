import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/HeroModel.dart';
import '../database/database_helper.dart';

class HeroApiService {
  static const String localApiUrl = 'http://192.168.0.12:3000/heroes';
  static const String fallbackApiUrl = 'https://cdn.jsdelivr.net/gh/akabab/superhero-api@0.3.0/api/all.json';

  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Executa busca paginada com resiliência de rede e sincronização em cache local (padrão Offline-First)
  Future<List<HeroModel>> fetchHeroes({required int page, required int limit}) async {
    try {
      // 1. Camada Primária: Realiza requisição HTTP GET para a API REST com timeout defensivo de 4 segundos
      final uri = Uri.parse('$localApiUrl?_page=$page&_limit=$limit');
      final response = await http.get(uri).timeout(const Duration(seconds: 4));
      
      if (response.statusCode == 200) {
        // Desserializa o JSON recebido em lista de objetos de domínio HeroModel
        final List<dynamic> data = json.decode(response.body);
        final heroes = data.map((json) => HeroModel.fromJson(json)).toList();
        
        // Persiste os dados recebidos no banco SQLite local para viabilizar consultas desconectadas posteriores
        await _dbHelper.saveHeroesCache(heroes);
        return heroes;
      } else {
        throw Exception('Falha na resposta do servidor: código HTTP ${response.statusCode}');
      }
    } catch (e) {
      // 2. Camada Secundária (Cache): Em caso de erro de rede/timeout, calcula o deslocamento (offset = (page - 1) * limit)
      // e recupera a fatia correspondente diretamente da tabela SQLite local
      final offset = (page - 1) * limit;
      final cachedHeroes = await _dbHelper.getHeroesFromCache(offset: offset, limit: limit);
      if (cachedHeroes.isNotEmpty) {
        return cachedHeroes;
      }
      
      // 3. Camada Terciária (Fallback Remoto): Caso o banco local esteja frio (vazio) e a API local inacessível,
      // consome o dump completo remoto via CDN, armazena no cache local e aplica paginação em memória (skip/take)
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

  // Busca entidade por chave primária (ID): primeiro na API remota; se indisponível, faz fallback no SQLite local
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
