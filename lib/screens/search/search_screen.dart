import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../core/app_colors.dart';
import '../../providers/search_provider.dart';
import '../../providers/language_provider.dart';
import '../../services/search_service.dart';
import '../../utils/app_localizations.dart';
import '../../widgets/empty_state.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    context.read<SearchProvider>().clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations(context.watch<LanguageProvider>().locale);
    final searchProvider = context.watch<SearchProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: TextField(
            controller: _searchController,
            focusNode: _focusNode,
            onChanged: (v) => context.read<SearchProvider>().search(v),
            style: GoogleFonts.inter(
                color: AppColors.textPrimary, fontSize: 15),
            decoration: InputDecoration(
              hintText: l.translate('searchHint'),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              fillColor: Colors.transparent,
              filled: false,
              suffixIcon: searchProvider.hasQuery
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded,
                          color: AppColors.textHint, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        context.read<SearchProvider>().clear();
                      },
                    )
                  : null,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                _filterChip(context, l.translate('filterAll'), null,
                    searchProvider.filter),
                const SizedBox(width: 8),
                _filterChip(context, l.translate('filterNotes'),
                    SearchResultType.note, searchProvider.filter),
                const SizedBox(width: 8),
                _filterChip(context, l.translate('filterImages'),
                    SearchResultType.image, searchProvider.filter),
                const SizedBox(width: 8),
                _filterChip(context, l.translate('filterVoice'),
                    SearchResultType.voice, searchProvider.filter),
                const SizedBox(width: 8),
                _filterChip(context, l.translate('filterPdfs'),
                    SearchResultType.pdf, searchProvider.filter),
              ],
            ),
          ),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 8),
          // Results
          Expanded(
            child: !searchProvider.hasQuery
                ? EmptyState(
                    icon: Icons.search_rounded,
                    title: l.translate('startSearching'),
                    subtitle: l.translate('startSearchingSub'),
                    iconColor: AppColors.primary,
                  )
                : searchProvider.results.isEmpty
                    ? EmptyState(
                        icon: Icons.search_off_rounded,
                        title: l.translate('noResults'),
                        subtitle: l.translate('noDataSub'),
                        iconColor: AppColors.textHint,
                      )
                    : AnimationLimiter(
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                          itemCount: searchProvider.results.length,
                          itemBuilder: (context, index) {
                            final result = searchProvider.results[index];
                            return AnimationConfiguration.staggeredList(
                              position: index,
                              duration: const Duration(milliseconds: 300),
                              child: SlideAnimation(
                                verticalOffset: 20,
                                child: FadeInAnimation(
                                  child: _buildResultCard(context, result),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(BuildContext context, String label,
      SearchResultType? type, SearchResultType? current) {
    final isSelected = current == type;
    return GestureDetector(
      onTap: () => context.read<SearchProvider>().setFilter(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard(BuildContext context, SearchResult result) {
    Color color;
    IconData icon;
    switch (result.type) {
      case SearchResultType.note:
        color = AppColors.notesColor;
        icon = Icons.sticky_note_2_rounded;
        break;
      case SearchResultType.image:
        color = AppColors.imagesColor;
        icon = Icons.photo_rounded;
        break;
      case SearchResultType.voice:
        color = AppColors.voiceColor;
        icon = Icons.mic_rounded;
        break;
      case SearchResultType.pdf:
        color = AppColors.pdfColor;
        icon = Icons.picture_as_pdf_rounded;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  result.subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
