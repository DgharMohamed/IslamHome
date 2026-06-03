import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islam_home/core/theme/app_theme.dart';
import 'package:islam_home/l10n/generated/app_localizations.dart';
import 'package:islam_home/presentation/providers/adhkar_providers.dart';
import 'package:islam_home/presentation/widgets/adhkar_item_card.dart';
import 'package:islam_home/presentation/widgets/app_search_field.dart';
import 'package:go_router/go_router.dart';

class AdhkarSearchScreen extends ConsumerStatefulWidget {
  const AdhkarSearchScreen({super.key});

  @override
  ConsumerState<AdhkarSearchScreen> createState() => _AdhkarSearchScreenState();
}

class _AdhkarSearchScreenState extends ConsumerState<AdhkarSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    final resultsAsync = ref.watch(adhkarSearchProvider(_query));

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryColor.withValues(alpha: 0.1),
              AppTheme.backgroundColor,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                left: 16,
                right: 16,
                bottom: 12,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.searchAdhkarHint, // Using hint as title if search title doesn't exist
                    style: GoogleFonts.cairo(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Search Field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: AppSearchField(
                hintText: l10n.searchAdhkarHint,
                controller: _controller,
                onChanged: (value) => setState(() => _query = value),
                onClear: () => setState(() => _query = ''),
              ),
            ),

            // Results
            Expanded(
              child: _query.trim().isEmpty
                  ? _buildEmptyState(l10n, Icons.search_rounded, l10n.typeToSearchAdhkar)
                  : resultsAsync.when(
                      data: (items) {
                        if (items.isEmpty) {
                          return _buildEmptyState(l10n, Icons.search_off_rounded, l10n.noAdhkarMatches);
                        }
                        return ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: AdhkarItemCard(
                                item: item,
                                isEnglish: isEnglish,
                                showCategory: true,
                                onTap: () {
                                  final category = Uri.encodeComponent(item.category);
                                  context.push(
                                    '/azkar/details/${item.id}?category=$category',
                                  );
                                },
                              ),
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
                          style: GoogleFonts.montserrat(color: Colors.white70),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n, IconData icon, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: Colors.white.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 16,
              color: Colors.white54,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
