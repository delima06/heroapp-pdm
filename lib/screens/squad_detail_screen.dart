import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:primer_progress_bar/primer_progress_bar.dart';
import '../models/HeroModel.dart';
import '../provider/hero_provider.dart';

class SquadDetailScreen extends StatelessWidget {
  const SquadDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final hero = ModalRoute.of(context)!.settings.arguments as HeroModel;

    return Scaffold(
      appBar: AppBar(
        title: Text(hero.name),
        backgroundColor: Colors.deepPurple.shade800,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Hero(
              tag: 'squad-hero-${hero.id}',
              child: CachedNetworkImage(
                imageUrl: hero.imagelLgUrl.isNotEmpty
                    ? hero.imagelLgUrl
                    : hero.imageUrl,
                height: 300,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 300,
                  color: Colors.grey.shade200,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 300,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.person, size: 80, color: Colors.grey),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hero.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Papel Tático: ${hero.dominantStat}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.deepPurple.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Chip(
                        backgroundColor: Colors.deepPurple.shade50,
                        avatar: const Icon(Icons.shield, size: 18, color: Colors.deepPurple),
                        label: const Text(
                          'No Esquadrão',
                          style: TextStyle(
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Informações Gerais
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildInfoRow('Nome Real', hero.fullName),
                          _buildInfoRow('Editora', hero.publisher),
                          _buildInfoRow('Alinhamento', hero.alignment.toUpperCase()),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'ATRIBUTOS DE PODER',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildStatBar('Inteligência', hero.intelligence, Colors.blue),
                  _buildStatBar('Força', hero.strength, Colors.red),
                  _buildStatBar('Velocidade', hero.speed, Colors.amber.shade800),
                  _buildStatBar('Durabilidade', hero.durability, Colors.green),
                  _buildStatBar('Poder', hero.power, Colors.purple),
                  _buildStatBar('Combate', hero.combat, Colors.orange),

                  const SizedBox(height: 24),

                  // Botão Dispensar do Esquadrão com AwesomeDialog
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.person_remove),
                      label: const Text(
                        'Dispensar do Esquadrão',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        // Modal com AwesomeDialog: bloqueia a interface até confirmação explícita do usuário
                        AwesomeDialog(
                          context: context,
                          dialogType: DialogType.warning, // Indicador semântico de ação destrutiva
                          animType: AnimType.bottomSlide,
                          title: 'Dispensar Agente',
                          desc: 'Tem certeza que deseja dispensar ${hero.name} do esquadrão? Essa vaga ficará livre.',
                          btnCancelText: 'Cancelar',
                          btnOkText: 'Sim, Dispensar',
                          btnCancelOnPress: () {},
                          btnOkOnPress: () async {
                            // Usa context.read dentro do callback assíncrono para despachar a ação sem redesenhar o modal
                            final provider = context.read<HeroProvider>();
                            await provider.dismissHero(hero.id);
                            if (context.mounted) {
                              Navigator.pop(context); // Fecha a tela de detalhes retornando à listagem do esquadrão
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${hero.name} foi dispensado do esquadrão.'),
                                  backgroundColor: Colors.red.shade800,
                                ),
                              );
                            }
                          },
                        ).show();
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
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
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              Text('$validValue / 100',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          const SizedBox(height: 4),
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
