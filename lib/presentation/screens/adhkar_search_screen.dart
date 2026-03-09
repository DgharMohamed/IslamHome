import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:islam_home/core/theme/app_theme.dart';
import 'package:islam_home/l10n/generated/app_localizations.dart';
import 'package:islam_home/presentation/providers/adhkar_providers.dart';
import 'package:islam_home/presentation/widgets/adhkar_item_card.dart';

class AdhkarSearchScreen extends ConsumerStatefulWidget {
  const AdhkarSearchScreen({super.key});

  @override
  ConsumerState<AdhkarSearchScreen> createState() => _AdhkarSearchScreenState();
}

class _AdhkarSearchScreenState extends ConsumerState<AdhkarSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    final resultsAsync = ref.watch(adhkarSearchProvider(_query));

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          onChanged: (value) => setState(() => _query = value),
          style: const TextStyle(
            fontFamily: 'Montserrat',
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: l10n.searchAdhkarHint,
            hintStyle: const TextStyle(
              fontFamily: 'Cairo',
              color: Colors.white54,
              fontSize: 14,
            ),
          ),
        ),
        actions: [
          if (_query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_rounded),
              onPressed: () {
                _controller.clear();
                setState(() => _query = '');
              },
            ),
        ],
      ),
      body: _query.trim().isEmpty
          ? Center(
              child: Text(
                l10n.typeToSearchAdhkar,
                style: const TextStyle(fontFamily: 'Cairo', fontSize: 16),
              ),
            )
          : resultsAsync.when(
              data: (items) {
                if (items.isEmpty) {
                  return Center(
                    child: Text(
                      l10n.noAdhkarMatches,
                      style: const TextStyle(fontFamily: 'Cairo', fontSize: 16),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(14),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return AdhkarItemCard(
                      item: item,
                      isEnglish: isEnglish,
                      showCategory: true,
                      onTap: () {
                        final category = Uri.encodeComponent(item.category);
                        context.push(
                          '/azkar/details/${item.id}?category=$category',
                        );
                      },
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryColor),
              ),
              error: (error, _) => Center(
                child: Text(
                  error.toString(),
                  style: const TextStyle(fontFamily: 'Montserrat'),
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
