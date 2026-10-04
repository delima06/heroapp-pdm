import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../provider/hero_provider.dart';

class DailyContractScreen extends StatefulWidget {
  const DailyContractScreen({super.key});

  @override
  State<DailyContractScreen> createState() => _DailyContractScreenState();
}

class _DailyContractScreenState extends State<DailyContractScreen> {
  @override
  void initState() {
    super.initState();
    // addPostFrameCallback adia a chamada assíncrona até a conclusão da primeira renderização da árvore de widgets,
    // prevenindo exceções de setState() durante a fase de build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HeroProvider>().loadDailyHero();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contrato Diário'),
        backgroundColor: Colors.teal.shade800,
        foregroundColor: Colors.white,
      ),
      // Consumer<HeroProvider>: escuta mudanças no HeroProvider e reconstrói reativamente apenas esta subárvore
      body: Consumer<HeroProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.teal),
                  SizedBox(height: 16),
                  Text('Localizando sinal de convocação diária...'),
                ],
              ),
            );
          }

          final hero = provider.dailyHero;
          if (hero == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 12),
                  const Text('Não foi possível sortear o agente diário.'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => provider.loadDailyHero(),
                    child: const Text('Tentar Convocação Novamente'),
                  ),
                ],
              ),
            );
          }

          final squadCount = provider.squad.length;
          final isAlreadyRecruited = provider.isInSquad(hero.id);
          final isSquadFull = squadCount >= 15;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Banner informativo de capacidade do esquadrão
                Card(
                  color: isSquadFull ? Colors.red.shade50 : Colors.teal.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: isSquadFull ? Colors.red.shade300 : Colors.teal.shade300,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Capacidade do Esquadrão:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Text(
                          '$squadCount / 15 heróis',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: isSquadFull ? Colors.red.shade800 : Colors.teal.shade900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Card Principal com Imagem, Nome e Powerstats
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Imagem com CachedNetworkImage
                      CachedNetworkImage(
                        imageUrl: hero.imagelLgUrl.isNotEmpty
                            ? hero.imagelLgUrl
                            : hero.imageUrl,
                        height: 280,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          height: 280,
                          color: Colors.grey.shade200,
                          child: const Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (context, url, error) => Container(
                          height: 280,
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.person, size: 80, color: Colors.grey),
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
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Editora: ${hero.publisher}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const Divider(height: 24),

                            const Text(
                              'POWER STATS',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                                letterSpacing: 1.1,
                              ),
                            ),
                            const SizedBox(height: 12),

                            GridView.count(
                              crossAxisCount: 2,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                              childAspectRatio: 3.2,
                              children: [
                                _buildMiniStat('Inteligência', hero.intelligence, Colors.blue),
                                _buildMiniStat('Força', hero.strength, Colors.red),
                                _buildMiniStat('Velocidade', hero.speed, Colors.amber.shade800),
                                _buildMiniStat('Durabilidade', hero.durability, Colors.green),
                                _buildMiniStat('Poder', hero.power, Colors.purple),
                                _buildMiniStat('Combate', hero.combat, Colors.orange),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isAlreadyRecruited
                          ? Colors.grey
                          : (isSquadFull ? Colors.grey.shade400 : Colors.teal.shade700),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: (isAlreadyRecruited || isSquadFull) ? 0 : 3,
                    ),
                    icon: Icon(
                      isAlreadyRecruited
                          ? Icons.check
                          : (isSquadFull ? Icons.block : Icons.person_add),
                    ),
                    label: Text(
                      isAlreadyRecruited
                          ? 'Agente já Recrutado'
                          : (isSquadFull
                              ? 'Esquadrão Cheio (Máx. 15)'
                              : 'Recrutar para o Esquadrão'),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    onPressed: (isAlreadyRecruited || isSquadFull)
                        ? null
                        : () async {
                            final success = await provider.recruitHero(hero);
                            if (mounted) {
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${hero.name} foi recrutado para o esquadrão!'),
                                    backgroundColor: Colors.teal.shade800,
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Não foi possível recrutar (limite de 15 atingido).'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMiniStat(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          Text(
            '$value',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
