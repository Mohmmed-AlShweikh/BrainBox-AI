import '../services/hive_service.dart';

enum SearchResultType { note, image, voice, pdf }

class SearchResult {
  final String id;
  final String title;
  final String subtitle;
  final SearchResultType type;
  final DateTime createdAt;
  final Object data;
  final double score;

  SearchResult({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.createdAt,
    required this.data,
    required this.score,
  });
}

class SearchService {
  /// Keyword-based local search across all modules
  static List<SearchResult> search(String query, {SearchResultType? filter}) {
    if (query.trim().isEmpty) return [];

    final results = <SearchResult>[];
    final keywords = query.toLowerCase().trim().split(RegExp(r'\s+'));

    if (filter == null || filter == SearchResultType.note) {
      results.addAll(_searchNotes(keywords));
    }
    if (filter == null || filter == SearchResultType.image) {
      results.addAll(_searchImages(keywords));
    }
    if (filter == null || filter == SearchResultType.voice) {
      results.addAll(_searchVoiceNotes(keywords));
    }
    if (filter == null || filter == SearchResultType.pdf) {
      results.addAll(_searchPdfs(keywords));
    }

    // Sort by relevance score then date
    results.sort((a, b) {
      final scoreDiff = b.score.compareTo(a.score);
      if (scoreDiff != 0) return scoreDiff;
      return b.createdAt.compareTo(a.createdAt);
    });

    return results;
  }

  static double _computeScore(List<String> keywords, List<String> fields) {
    double score = 0;
    for (final keyword in keywords) {
      for (int i = 0; i < fields.length; i++) {
        final field = fields[i].toLowerCase();
        if (field == keyword) {
          score += (10.0 / (i + 1)); // exact match in earlier field = higher score
        } else if (field.contains(keyword)) {
          score += (5.0 / (i + 1));
        }
      }
    }
    return score;
  }

  static List<SearchResult> _searchNotes(List<String> keywords) {
    final results = <SearchResult>[];
    final notes = HiveService.notesBox.values.toList();

    for (final note in notes) {
      final fields = [note.title, note.content, ...note.tags];
      final score = _computeScore(keywords, fields);
      if (score > 0) {
        results.add(SearchResult(
          id: note.id,
          title: note.title,
          subtitle: note.content.length > 80
              ? '${note.content.substring(0, 80)}...'
              : note.content,
          type: SearchResultType.note,
          createdAt: note.createdAt,
          data: note,
          score: score,
        ));
      }
    }
    return results;
  }

  static List<SearchResult> _searchImages(List<String> keywords) {
    final results = <SearchResult>[];
    final images = HiveService.imagesBox.values.toList();

    for (final image in images) {
      final fields = [
        image.title,
        image.description,
        image.extractedText ?? '',
        ...image.tags
      ];
      final score = _computeScore(keywords, fields);
      if (score > 0) {
        results.add(SearchResult(
          id: image.id,
          title: image.title,
          subtitle: image.description.isNotEmpty
              ? image.description
              : 'Image memory',
          type: SearchResultType.image,
          createdAt: image.createdAt,
          data: image,
          score: score,
        ));
      }
    }
    return results;
  }

  static List<SearchResult> _searchVoiceNotes(List<String> keywords) {
    final results = <SearchResult>[];
    final notes = HiveService.voiceNotesBox.values.toList();

    for (final note in notes) {
      final fields = [note.title, note.transcript ?? '', ...note.tags];
      final score = _computeScore(keywords, fields);
      if (score > 0) {
        results.add(SearchResult(
          id: note.id,
          title: note.title,
          subtitle: note.transcript != null
              ? note.transcript!.length > 80
                  ? '${note.transcript!.substring(0, 80)}...'
                  : note.transcript!
              : 'Voice note · ${note.formattedDuration}',
          type: SearchResultType.voice,
          createdAt: note.createdAt,
          data: note,
          score: score,
        ));
      }
    }
    return results;
  }

  static List<SearchResult> _searchPdfs(List<String> keywords) {
    final results = <SearchResult>[];
    final pdfs = HiveService.pdfsBox.values.toList();

    for (final pdf in pdfs) {
      final fields = [pdf.title, pdf.description, ...pdf.tags];
      final score = _computeScore(keywords, fields);
      if (score > 0) {
        results.add(SearchResult(
          id: pdf.id,
          title: pdf.title,
          subtitle: pdf.description.isNotEmpty
              ? pdf.description
              : '${pdf.pages} pages · ${pdf.formattedFileSize}',
          type: SearchResultType.pdf,
          createdAt: pdf.createdAt,
          data: pdf,
          score: score,
        ));
      }
    }
    return results;
  }

  /// Smart "Ask BrainBox" response
  static Map<String, dynamic> askBrainBox(String question) {
    final results = search(question);
    if (results.isEmpty) {
      return {
        'answer': null,
        'results': <SearchResult>[],
        'count': 0,
      };
    }

    return {
      'answer': _buildSmartResponse(question, results),
      'results': results.take(10).toList(),
      'count': results.length,
    };
  }

  static String _buildSmartResponse(String question, List<SearchResult> results) {
    final topResult = results.first;
    final count = results.length;

    if (count == 1) {
      return 'I found 1 match: "${topResult.title}" — ${topResult.subtitle}';
    }

    final typeBreakdown = <String, int>{};
    for (final r in results) {
      final typeName = r.type.name;
      typeBreakdown[typeName] = (typeBreakdown[typeName] ?? 0) + 1;
    }

    final parts = typeBreakdown.entries
        .map((e) => '${e.value} ${e.key}${e.value > 1 ? 's' : ''}')
        .join(', ');

    return 'Found $count matching memories ($parts). Top match: "${topResult.title}"';
  }
}
