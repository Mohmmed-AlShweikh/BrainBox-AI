import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../core/app_colors.dart';
import '../../models/image_model.dart';
import '../../models/pdf_model.dart';
import '../../providers/language_provider.dart';
import '../../screens/images/image_detail_screen.dart';
import '../../screens/notes/note_detail_screen.dart';
import '../../screens/pdf/pdf_viewer_screen.dart';
import '../../screens/voice/voice_notes_screen.dart';
import '../../services/search_service.dart';
import '../../utils/app_localizations.dart';

class _AskResult {
  final String? answer;
  final List<SearchResult> results;
  final int count;
  _AskResult({this.answer, required this.results, required this.count});
}

class AskBrainBoxScreen extends StatefulWidget {
  const AskBrainBoxScreen({super.key});

  @override
  State<AskBrainBoxScreen> createState() => _AskBrainBoxScreenState();
}

class _AskBrainBoxScreenState extends State<AskBrainBoxScreen> {
  final _questionController = TextEditingController();
  _AskResult? _result;
  bool _isThinking = false;
  String _currentQuestion = '';

  final List<String> _exampleQueries = [
    'Where did I save my car papers?',
    'Show me my meeting notes',
    'Find images from last week',
    'Voice notes about work',
  ];

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  Future<void> _ask() async {
    final question = _questionController.text.trim();
    if (question.isEmpty) return;

    FocusScope.of(context).unfocus();
    _questionController.clear();

    setState(() {
      _isThinking = true;
      _currentQuestion = question;
    });

    // Simulate processing delay for UX
    await Future.delayed(const Duration(milliseconds: 600));

    final response = SearchService.askBrainBox(question);
    setState(() {
      _result = _AskResult(
        answer: response['answer'] as String?,
        results: response['results'] as List<SearchResult>,
        count: response['count'] as int,
      );
      _isThinking = false;
    });
  }

  Future<void> _openResult(SearchResult result) async {
    switch (result.type) {
      case SearchResultType.note:
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NoteDetailScreen(noteId: result.id),
          ),
        );
        break;
      case SearchResultType.image:
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                ImageDetailScreen(existingImage: result.data as ImageModel),
          ),
        );
        break;
      case SearchResultType.voice:
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const VoiceNotesScreen()),
        );
        break;
      case SearchResultType.pdf:
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PdfViewerScreen(pdf: result.data as PdfModel),
          ),
        );
        break;
    }
  }

  Color _typeColor(SearchResultType type) {
    switch (type) {
      case SearchResultType.note:
        return AppColors.notesColor;
      case SearchResultType.image:
        return AppColors.imagesColor;
      case SearchResultType.voice:
        return AppColors.voiceColor;
      case SearchResultType.pdf:
        return AppColors.pdfColor;
    }
  }

  IconData _typeIcon(SearchResultType type) {
    switch (type) {
      case SearchResultType.note:
        return Icons.sticky_note_2_rounded;
      case SearchResultType.image:
        return Icons.photo_rounded;
      case SearchResultType.voice:
        return Icons.mic_rounded;
      case SearchResultType.pdf:
        return Icons.picture_as_pdf_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations(context.watch<LanguageProvider>().locale);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.backgroundFor(context),
      appBar: AppBar(
        title: Text(l.translate('askTitle')),
        backgroundColor: AppColors.backgroundFor(context),
      ),
      body: Column(
        children: [
          // Main content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Brain icon + welcome (show when no query)
                  if (_result == null && !_isThinking) ...[
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.askColor, AppColors.primary],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.askColor.withOpacity(0.3),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.psychology_rounded,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            l.translate('askWelcome'),
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimaryFor(context),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l.translate('askWelcomeSub'),
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: AppColors.textSecondaryFor(context),
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 28),
                          // Example queries
                          Text(
                            l.translate('exampleQueries'),
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondaryFor(context),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: _exampleQueries.map((q) {
                              return GestureDetector(
                                onTap: () {
                                  _questionController.text = q;
                                  _ask();
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.cardFor(context),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: AppColors.borderFor(context),
                                    ),
                                  ),
                                  child: Text(
                                    q,
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: AppColors.textSecondaryFor(
                                        context,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Thinking indicator
                  if (_isThinking) ...[
                    const SizedBox(height: 40),
                    Center(
                      child: Column(
                        children: [
                          const CircularProgressIndicator(
                            color: AppColors.askColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l.translate('thinking'),
                            style: GoogleFonts.inter(
                              color: AppColors.textSecondaryFor(context),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Results
                  if (_result != null && !_isThinking) ...[
                    // Question bubble
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                            bottomLeft: Radius.circular(16),
                          ),
                        ),
                        child: Text(
                          _currentQuestion,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Answer bubble
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.askColor.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.psychology_rounded,
                            size: 16,
                            color: AppColors.askColor,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.cardFor(context),
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(16),
                                bottomLeft: Radius.circular(16),
                                bottomRight: Radius.circular(16),
                              ),
                              border: Border.all(
                                color: AppColors.borderFor(context),
                              ),
                            ),
                            child: Text(
                              _result!.answer ?? l.translate('noAnswer'),
                              style: GoogleFonts.inter(
                                color: _result!.answer != null
                                    ? AppColors.textPrimaryFor(context)
                                    : AppColors.textSecondaryFor(context),
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Result list
                    if (_result!.results.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Text(
                        '${l.translate('searchResults')} (${_result!.count})',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondaryFor(context),
                        ),
                      ),
                      const SizedBox(height: 10),
                      AnimationLimiter(
                        child: Column(
                          children: AnimationConfiguration.toStaggeredList(
                            duration: const Duration(milliseconds: 300),
                            childAnimationBuilder: (child) => SlideAnimation(
                              verticalOffset: 20,
                              child: FadeInAnimation(child: child),
                            ),
                            children: _result!.results
                                .map((r) => _buildResultCard(r))
                                .toList(),
                          ),
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 12),
                      Text(
                        l.translate('noAnswerSub'),
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.textSecondaryFor(context),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),

          // Input area
          Container(
            padding: EdgeInsets.fromLTRB(
              16,
              12,
              16,
              MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceFor(context),
              border: Border(
                top: BorderSide(color: AppColors.borderFor(context)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _questionController,
                    style: GoogleFonts.inter(
                      color: AppColors.textPrimaryFor(context),
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: l.translate('askHint'),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _ask(),
                    textInputAction: TextInputAction.send,
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _isThinking ? null : _ask,
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: _isThinking
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(SearchResult result) {
    final color = _typeColor(result.type);
    final icon = _typeIcon(result.type);
    return GestureDetector(
      onTap: () => _openResult(result),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardFor(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderFor(context)),
          boxShadow: [
            BoxShadow(
              color: AppColors.askColor.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.title,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimaryFor(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    result.subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.textSecondaryFor(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
