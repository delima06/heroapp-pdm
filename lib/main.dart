import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'provider/configure_providers.dart';
import 'screens/home_screen.dart';
import 'screens/agents.screen.dart';
import 'screens/agent_detail_screen.dart';
import 'screens/daily_contract_screen.dart';
import 'screens/squad_screen.dart';
import 'screens/squad_detail_screen.dart';
import 'screens/mission_screen.dart';

void main() async {
  // Garante a inicialização do Flutter antes de operações assíncronas
  WidgetsFlutterBinding.ensureInitialized();
  // Padrão Aula 11: Carrega dependências e dados do SQLite antes do primeiro frame
  final data = await ConfigureProviders.createDependencyTree();

  runApp(
    MultiProvider(
      providers: data.providers, // Injeta a lista de SingleChildWidget
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HeroApp PDM',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/agents': (context) => const AgentsScreen(),
        '/agent_detail': (context) => const AgentDetailScreen(),
        '/daily_contract': (context) => const DailyContractScreen(),
        '/squad': (context) => const SquadScreen(),
        '/squad_detail': (context) => const SquadDetailScreen(),
        '/missions': (context) => const MissionScreen(),
      },
    );
  }
}
