import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'HERO APP - QG DOS HERÓIS',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo.shade800,
        foregroundColor: Colors.white,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.indigo.shade50,
              Colors.indigo.shade100,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.shield_outlined,
              size: 80,
              color: Colors.indigo,
            ),
            const SizedBox(height: 16),
            const Text(
              'COMANDO TÁTICO',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 36),

            _buildMenuButton(
              context: context,
              title: 'Agentes',
              subtitle: 'Catálogo geral de heróis',
              icon: Icons.people_alt,
              color: Colors.blue.shade700,
              route: '/agents',
            ),
            const SizedBox(height: 16),

            _buildMenuButton(
              context: context,
              title: 'Contrato Diário',
              subtitle: 'Convocação diária para recrutar heróis',
              icon: Icons.calendar_month,
              color: Colors.teal.shade700,
              route: '/daily_contract',
            ),
            const SizedBox(height: 16),

            _buildMenuButton(
              context: context,
              title: 'Meu Esquadrão',
              subtitle: 'Gerencie heróis recrutados (máx 15)',
              icon: Icons.groups_sharp,
              color: Colors.deepPurple.shade700,
              route: '/squad',
            ),
            const SizedBox(height: 16),

            _buildMenuButton(
              context: context,
              title: 'Missões',
              subtitle: 'Central tática de simulação de combate',
              icon: Icons.military_tech,
              color: Colors.red.shade700,
              route: '/missions',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String route,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 3,
      ),
      onPressed: () {
        Navigator.pushNamed(context, route);
      },
      child: Row(
        children: [
          Icon(
            icon,
            size: 28,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            size: 16,
          ),
        ],
      ),
    );
  }
}
