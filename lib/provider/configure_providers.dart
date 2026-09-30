import 'package:nested/nested.dart';
import 'package:provider/provider.dart';
import 'hero_provider.dart';

class ConfigureProviders {
    final List<SingleChildStatelesWidget> providers;

    ConfigureProviders({
        required this.providers;
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