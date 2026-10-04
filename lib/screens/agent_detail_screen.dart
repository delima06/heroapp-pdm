import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:primer_progress_bar/primer_progress_bar.dart';
import '../models/HeroModel.dart';

class AgentDetailScreen extends StatelessWidget {
  const AgentDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final hero = ModalRoute.of(context)!.settings.arguments as HeroModel;

    return Scaffold(
      appBar: AppBar(
        title: Text(hero.name),
        backgroundColor: Colors.indigo.shade800,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Hero(
              tag: 'hero-image-${hero.id}',
              child: CachedNetworkImage(
                imageUrl: hero.imagelLgUrl.isNotEmpty
                    ? hero.imagelLgUrl
                    : hero.imageUrl,
                height: 320,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 320,
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 320,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.broken_image, size: 80, color: Colors.grey),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hero.name,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'Editora: ${hero.publisher}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.indigo.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'INFORMAÇÕES GERAIS',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                              letterSpacing: 1.1,
                            ),
                          ),
                          const Divider(),
                          _buildInfoRow('Nome Completo', hero.fullName),
                          _buildInfoRow('Gênero', hero.gender),
                          _buildInfoRow('Raça', hero.race),
                          _buildInfoRow('Alinhamento', hero.alignment.toUpperCase()),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'ATRIBUTOS DE PODER (POWERSTATS)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildStatBar('Inteligência', hero.intelligence, Colors.blue),
                  _buildStatBar('Força', hero.strength, Colors.red),
                  _buildStatBar('Velocidade', hero.speed, Colors.amber.shade700),
                  _buildStatBar('Durabilidade', hero.durability, Colors.green),
                  _buildStatBar('Poder', hero.power, Colors.purple),
                  _buildStatBar('Combate', hero.combat, Colors.orange),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final displayVal = (value.isEmpty || value == '-') ? 'Não informado' : value;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(displayVal, style: TextStyle(color: Colors.grey.shade700)),
        ],
      ),
    );
  }

  Widget _buildStatBar(String title, int value, Color color) {
    final validValue = value.clamp(0, 100);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              Text(
                '$validValue / 100',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          PrimerProgressBar(
            segments: [
              Segment(
                value: validValue,
                color: color,
                valueLabel: Text('$validValue%'),
              ),
            ],
            maxTotalValue: 100,
          ),
        ],
      ),
    );
  }
}
