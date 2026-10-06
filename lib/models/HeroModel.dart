class HeroModel {
  final int id;
  final String name;
  final String imageUrl;
  final String imagelLgUrl;

  int intelligence;
  int strength;
  int speed;
  int durability;
  int power;
  int combat;

  final String gender;
  final String race;
  final String alignment;
  final String publisher;
  final String fullName;

  HeroModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.imagelLgUrl,
    required this.intelligence,
    required this.strength,
    required this.speed,
    required this.durability,
    required this.power,
    required this.combat,
    required this.gender,
    required this.race,
    required this.alignment,
    required this.publisher,
    required this.fullName,
  });

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  factory HeroModel.fromJson(Map<String, dynamic> json) {
    var images = json['images'] ?? {};
    var stats = json['powerstats'] ?? {};
    var appearance = json['appearance'] ?? {};
    var biography = json['biography'] ?? {};
    return HeroModel(
      id: _parseInt(json['id']),
      name: json['name']?.toString() ?? 'Desconhecido',
      imageUrl: (images['sm'] ?? images['md'] ?? '').toString(),
      imagelLgUrl: (images['lg'] ?? images['md'] ?? '').toString(),
      intelligence: _parseInt(stats['intelligence']),
      strength: _parseInt(stats['strength']),
      speed: _parseInt(stats['speed']),
      durability: _parseInt(stats['durability']),
      power: _parseInt(stats['power']),
      combat: _parseInt(stats['combat']),
      gender: (appearance['gender'] ?? 'Desconhecido').toString(),
      race: (appearance['race'] ?? 'Não informado').toString(),
      alignment: (biography['alignment'] ?? 'Neutro').toString(),
      publisher: (biography['publisher'] ?? 'Não informado').toString(),
      fullName: (biography['fullName'] ?? 'Desconhecido').toString(),
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'imageLgUrl': imagelLgUrl,
      'intelligence': intelligence,
      'strength': strength,
      'speed': speed,
      'durability': durability,
      'power': power,
      'combat': combat,
      'gender': gender,
      'race': race,
      'alignment': alignment,
      'publisher': publisher,
      'fullName': fullName,
    };
  }
  factory HeroModel.fromMap(Map<String, dynamic> map) {
    return HeroModel(
      id: map['id'] as int,
      name: map['name'] as String,
      imageUrl: map['imageUrl'] as String,
      imagelLgUrl: (map['imageLgUrl'] ?? map['imagelLgUrl'] ?? '') as String,
      intelligence: map['intelligence'] as int,
      strength: map['strength'] as int,
      speed: map['speed'] as int,
      durability: map['durability'] as int,
      power: map['power'] as int,
      combat: map['combat'] as int,
      gender: map['gender'] as String,
      race: map['race'] as String,
      alignment: map['alignment'] as String,
      publisher: map['publisher'] as String,
      fullName: map['fullName'] as String,
    );
  }
  String get dominantStat {
    final stats = {
      'Inteligência': intelligence,
      'Força': strength,
      'Velocidade': speed,
      'Durabilidade': durability,
      'Poder': power,
      'Combate': combat,
    };
    var highest = stats.entries.first;
    for (var entry in stats.entries) {
      if (entry.value > highest.value) {
        highest = entry;
      }
    }
    return '${highest.key}: ${highest.value}';
  }

  int getStatByName(String statName) {
    switch(statName.toLowerCase()) {
      case 'intelligence': return intelligence;
      case 'strength': return strength;
      case 'speed': return speed;
      case 'durability': return durability;
      case 'power': return power;
      case 'combat': return combat;
      default: return 0;
    }
  }
  void boostStat(String statName) {
    switch(statName.toLowerCase()) {
      case 'intelligence': intelligence += 1; break;
      case 'strength': strength += 1; break;
      case 'speed': speed += 1; break;
      case 'durability': durability += 1; break;
      case 'power': power += 1; break;
      case 'combat': combat += 1; break;
      default: break;
    }
  }
}
