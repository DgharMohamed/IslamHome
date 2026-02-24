import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islam_home/core/theme/app_theme.dart';
import 'package:islam_home/presentation/providers/api_providers.dart';
import 'package:islam_home/data/models/quran_content_model.dart';
import 'package:go_router/go_router.dart';
import 'package:islam_home/l10n/generated/app_localizations.dart';

class QuranSearchScreen extends ConsumerStatefulWidget {
  final String? from;
  const QuranSearchScreen({super.key, this.from});

  @override
  ConsumerState<QuranSearchScreen> createState() => _QuranSearchScreenState();
}

class _QuranSearchScreenState extends ConsumerState<QuranSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final searchResults = ref.watch(quranSearchProvider(_query));

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: GoogleFonts.cairo(color: Colors.white),
          decoration: InputDecoration(
            hintText: l10n.searchHint,
            hintStyle: GoogleFonts.cairo(color: Colors.white54),
            border: InputBorder.none,
          ),
          onChanged: (value) {
            setState(() {
              _query = value;
            });
          },
        ),
        actions: [
          if (_query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _query = '';
                });
              },
            ),
        ],
      ),
      body: _query.isEmpty
          ? _buildInitialState(l10n)
          : searchResults.when(
              data: (results) => results.isEmpty
                  ? _buildNoResults(l10n)
                  : _buildResultsList(results, l10n),
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryColor),
              ),
              error: (err, stack) => Center(
                child: Text(
                  l10n.errorLoadingPage,
                  style: GoogleFonts.cairo(color: Colors.white54),
                ),
              ),
            ),
    );
  }

  Widget _buildInitialState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_rounded,
            size: 80,
            color: Colors.white.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.searchDescription,
            style: GoogleFonts.cairo(color: Colors.white54),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 80,
            color: Colors.white.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noSearchResults,
            style: GoogleFonts.cairo(color: Colors.white54, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(List<Ayah> results, AppLocalizations l10n) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final ayah = results[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: AppTheme.surfaceColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: InkWell(
            onTap: () {
              final targetRoute = widget.from == 'text'
                  ? '/quran-text'
                  : '/mushaf';
              final queryParams = widget.from == 'text'
                  ? 'surah=${ayah.surah?.number}&ayah=${ayah.numberInSurah}'
                  : 'page=${ayah.page}&ayah=${ayah.numberInSurah}&surah=${ayah.surah?.number}';

              context.pushReplacement('$targetRoute?$queryParams');
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${ayah.surah?.name} : ${ayah.numberInSurah}',
                          style: GoogleFonts.cairo(
                            color: AppTheme.primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '${l10n.page} ${ayah.page}',
                        style: GoogleFonts.cairo(
                          color: Colors.white38,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    ayah.text ?? '',
                    style: GoogleFonts.amiri(
                      fontSize: 20,
                      color: Colors.white,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
