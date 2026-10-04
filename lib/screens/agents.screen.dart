import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/HeroModel.dart';
import '../services/hero_api_service.dart';

class AgentsScreen extends StatefulWidget {
  const AgentsScreen({super.key});

  @override
  State<AgentsScreen> createState() => _AgentsScreenState();
}

class _AgentsScreenState extends State<AgentsScreen> {
  static const _pageSize = 20;
  final HeroApiService _apiService = HeroApiService();

  final PagingController<int, HeroModel> _pagingController =
      PagingController(firstPageKey: 1);

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newItems = await _apiService.fetchHeroes(
        page: pageKey,
        limit: _pageSize,
      );

      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo de Agentes'),
        backgroundColor: Colors.indigo.shade800,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: () => Future.sync(() => _pagingController.refresh()),
        child: PagedListView<int, HeroModel>(
          pagingController: _pagingController,
          builderDelegate: PagedChildBuilderDelegate<HeroModel>(
            itemBuilder: (context, hero, index) => Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
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
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Poder Máximo: ${hero.dominantStat}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.indigo.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/agent_detail',
                    arguments: hero,
                  );
                },
              ),
            ),
            firstPageErrorIndicatorBuilder: (context) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Erro ao carregar agentes.'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _pagingController.refresh(),
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            ),
            noItemsFoundIndicatorBuilder: (context) => const Center(
              child: Text('Nenhum agente encontrado.'),
            ),
          ),
        ),
      ),
    );
  }
}
