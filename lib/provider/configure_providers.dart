import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'hero_provider.dart';

class ConfigureProviders {
  final List<SingleChildWidget> providers;

  ConfigureProviders({
    required this.providers,
  });

  static Future<ConfigureProviders> createDependencyTree() async {
    final heroProvider = HeroProvider();
    await heroProvider.loadSquad();
    return ConfigureProviders(
      providers: [
        ChangeNotifierProvider<HeroProvider>.value(value: heroProvider),
      ],
    );
  }
}
