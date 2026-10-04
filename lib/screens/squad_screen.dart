import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../provider/hero_provider.dart';

class SquadScreen extends StatelessWidget {
  const SquadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Esquadrão'),
        backgroundColor: Colors.deepPurple.shade800,
        foregroundColor: Colors.white,
      ),
      body: Consumer<HeroProvider>(
        builder: (context, provider, child) {
          final squad = provider.squad;

          if (squad.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.groups_outlined,
                      size: 80,
                      color: Colors.deepPurple.shade200,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Seu esquadrão está vazio!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Acesse o Contrato Diário para recrutar seu primeiro herói para a equipe.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple.shade700,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.calendar_month),
                      label: const Text('Ir para Contrato Diário'),
                      onPressed: () {
                        Navigator.pushNamed(context, '/daily_contract');
                      },
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: Colors.deepPurple.shade50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Agentes em Serviço:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple.shade900,
                      ),
                    ),
                    Text(
                      '${squad.length} / 15',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple.shade900,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: squad.length,
                  itemBuilder: (context, index) {
                    final hero = squad[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(8),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: hero.imageUrl.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: hero.imageUrl,
                                  width: 55,
                                  height: 55,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    width: 55,
                                    height: 55,
                                    color: Colors.grey.shade200,
                                    child: const Center(
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Container(
                                    width: 55,
                                    height: 55,
                                    color: Colors.grey.shade300,
                                    child: const Icon(Icons.person, color: Colors.grey),
                                  ),
                                )
                              : Container(
                                  width: 55,
                                  height: 55,
                                  color: Colors.grey.shade300,
                                  child: const Icon(Icons.person, color: Colors.grey),
                                ),
                        ),
                        title: Text(
                          hero.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hero.fullName.isNotEmpty && hero.fullName != 'Desconhecido'
                                  ? hero.fullName
                                  : hero.publisher,
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.deepPurple.shade50,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.deepPurple.shade200),
                              ),
                              child: Text(
                                'Papel Tático: ${hero.dominantStat}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple.shade900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/squad_detail',
                            arguments: hero,
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
