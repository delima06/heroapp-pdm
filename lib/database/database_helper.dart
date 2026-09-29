import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/HeroModel.dart';
import 'hero_contract.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  Future<Database> initDb() async {
    String? databasesPath = await getDatabasesPath();
    String path = join(databasesPath, "heroapp.db");

    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        //Tabela de Cache dos Heróis da API
        await db.execute('''
          CREATE TABLE ${HeroContract.cacheTable} (
            ${HeroContract.idColumn} INTEGER PRIMARY KEY,
            ${HeroContract.nameColumn} TEXT,
            ${HeroContract.imageUrlColumn} TEXT,
            ${HeroContract.imageLgUrlColumn} TEXT,
            ${HeroContract.intelligenceColumn} INTEGER,
            ${HeroContract.strengthColumn} INTEGER,
            ${HeroContract.speedColumn} INTEGER,
            ${HeroContract.durabilityColumn} INTEGER,
            ${HeroContract.powerColumn} INTEGER,
            ${HeroContract.combatColumn} INTEGER,
            ${HeroContract.genderColumn} TEXT,
            ${HeroContract.raceColumn} TEXT,
            ${HeroContract.alignmentColumn} TEXT,
            ${HeroContract.fullNameColumn} TEXT,
            ${HeroContract.publisherColumn} TEXT
          )
        ''');

        //Tabela do Esquadrão (Heróis recrutados)
        await db.execute('''
          CREATE TABLE ${HeroContract.squadTable} (
            ${HeroContract.idColumn} INTEGER PRIMARY KEY,
            ${HeroContract.nameColumn} TEXT,
            ${HeroContract.imageUrlColumn} TEXT,
            ${HeroContract.imageLgUrlColumn} TEXT,
            ${HeroContract.intelligenceColumn} INTEGER,
            ${HeroContract.strengthColumn} INTEGER,
            ${HeroContract.speedColumn} INTEGER,
            ${HeroContract.durabilityColumn} INTEGER,
            ${HeroContract.powerColumn} INTEGER,
            ${HeroContract.combatColumn} INTEGER,
            ${HeroContract.genderColumn} TEXT,
            ${HeroContract.raceColumn} TEXT,
            ${HeroContract.alignmentColumn} TEXT,
            ${HeroContract.fullNameColumn} TEXT,
            ${HeroContract.publisherColumn} TEXT
          )
        ''');
      },
    );
  }

  // Salva uma lista de heróis em lote no cache
  Future<void> saveHeroesCache(List<HeroModel> heroes) async {
    Database database = await db;
    Batch batch = database.batch();
    for (var hero in heroes) {
      batch.insert(
        HeroContract.cacheTable,
        hero.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  // Busca heróis paginados do cache offline
  Future<List<HeroModel>> getHeroesFromCache({required int offset, required int limit}) async {
    Database database = await db;
    List<Map<String, dynamic>> maps = await database.query(
      HeroContract.cacheTable,
      limit: limit,
      offset: offset,
      orderBy: HeroContract.idColumn,
    );
    return maps.map((m) => HeroModel.fromMap(m)).toList();
  }

  // Busca herói por ID no cache
  Future<HeroModel?> getHeroById(int id) async {
    Database database = await db;
    List<Map<String, dynamic>> maps = await database.query(
      HeroContract.cacheTable,
      where: "${HeroContract.idColumn} = ?",
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return HeroModel.fromMap(maps.first);
    }
    return null;
  }

  // Total de heróis no cache
  Future<int> getHeroesCacheCount() async {
    Database database = await db;
    final result = await database.rawQuery('SELECT COUNT(*) as count FROM ${HeroContract.cacheTable}');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Retorna todos os heróis recrutados no esquadrão
  Future<List<HeroModel>> getSquad() async {
    Database database = await db;
    List<Map<String, dynamic>> maps = await database.query(
      HeroContract.squadTable,
      orderBy: HeroContract.nameColumn,
    );
    return maps.map((m) => HeroModel.fromMap(m)).toList();
  }

  // Quantidade de heróis no esquadrão
  Future<int> getSquadCount() async {
    Database database = await db;
    final result = await database.rawQuery('SELECT COUNT(*) as count FROM ${HeroContract.squadTable}');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Verifica se um herói já está no esquadrão
  Future<bool> isHeroInSquad(int id) async {
    Database database = await db;
    List<Map<String, dynamic>> maps = await database.query(
      HeroContract.squadTable,
      where: "${HeroContract.idColumn} = ?",
      whereArgs: [id],
    );
    return maps.isNotEmpty;
  }

  // Recrutar herói para o esquadrão
  Future<int> recruitHero(HeroModel hero) async {
    Database database = await db;
    return await database.insert(
      HeroContract.squadTable,
      hero.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Dispensar herói do esquadrão 
  Future<int> dismissHero(int id) async {
    Database database = await db;
    return await database.delete(
      HeroContract.squadTable,
      where: "${HeroContract.idColumn} = ?",
      whereArgs: [id],
    );
  }

  // Atualiza atributo do herói (após vitória na missão, ganha +1 no atributo)
  Future<int> updateHeroStats(HeroModel hero) async {
    Database database = await db;
    return await database.update(
      HeroContract.squadTable,
      hero.toMap(),
      where: "${HeroContract.idColumn} = ?",
      whereArgs: [hero.id],
    );
  }
}
