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

    final normalizedQuery = _normalize(query);
    final results = <SearchResult>[];
    final keywords = normalizedQuery
        .split(' ')
        .where((w) => w.isNotEmpty)
        .toList();
    final intent = _detectIntent(query);
    final semanticTerms = _expandQueryTerms(query, intent);
    final searchTerms = <String>{...keywords, ...semanticTerms}.toList();

    if (filter == null || filter == SearchResultType.note) {
      results.addAll(_searchNotes(searchTerms));
    }
    if (filter == null || filter == SearchResultType.image) {
      results.addAll(_searchImages(searchTerms));
    }
    if (filter == null || filter == SearchResultType.voice) {
      results.addAll(_searchVoiceNotes(searchTerms));
    }
    if (filter == null || filter == SearchResultType.pdf) {
      results.addAll(_searchPdfs(searchTerms));
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
      final normalizedKeyword = _normalize(keyword);
      if (normalizedKeyword.isEmpty) continue;

      for (int i = 0; i < fields.length; i++) {
        final field = fields[i];
        final normalizedField = _normalize(field);
        if (normalizedField.isEmpty) continue;

        if (normalizedField == normalizedKeyword) {
          score += 12.0 / (i + 1);
        } else if (normalizedField.contains(normalizedKeyword) ||
            normalizedKeyword.contains(normalizedField)) {
          score += 7.0 / (i + 1);
        } else if (_containsToken(normalizedField, normalizedKeyword)) {
          score += 4.0 / (i + 1);
        } else if (_isSimilar(normalizedKeyword, normalizedField)) {
          score += 3.0 / (i + 1);
        }
      }
    }
    return score;
  }

  static String _normalize(String value) {
    final normalized = value.toLowerCase().trim();
    final withoutDiacritics = normalized.replaceAll(
      RegExp(r'[\u064B-\u065F\u0670]'),
      '',
    );
    final withoutPunct = withoutDiacritics.replaceAll(
      RegExp(r'[^a-z0-9\u0600-\u06ff\s]'),
      ' ',
    );
    return withoutPunct
        .split(RegExp(r'\s+'))
        .where((s) => s.isNotEmpty)
        .join(' ');
  }

  static bool _containsToken(String field, String keyword) {
    final fieldTokens = field.split(' ');
    final keywordTokens = keyword.split(' ');

    for (final token in keywordTokens) {
      if (token.isEmpty) continue;
      if (fieldTokens.any(
        (fieldToken) =>
            fieldToken == token ||
            fieldToken.contains(token) ||
            token.contains(fieldToken),
      )) {
        return true;
      }
    }
    return false;
  }

  static bool _isSimilar(String a, String b) {
    if (a.isEmpty || b.isEmpty) return false;
    if (a == b) return true;

    final maxLength = a.length > b.length ? a.length : b.length;
    if (maxLength <= 3) return false;

    final distance = _levenshtein(a, b);
    final similarity = 1 - (distance / maxLength);
    return similarity >= 0.72;
  }

  static int _levenshtein(String a, String b) {
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    final list = List.generate(
      a.length + 1,
      (index) => List.generate(b.length + 1, (i) => i),
    );

    for (int i = 1; i <= a.length; i++) {
      list[i][0] = i;
      for (int j = 1; j <= b.length; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        list[i][j] = [
          list[i - 1][j] + 1,
          list[i][j - 1] + 1,
          list[i - 1][j - 1] + cost,
        ].reduce((value, element) => value < element ? value : element);
      }
    }

    return list[a.length][b.length];
  }

  static List<SearchResult> _searchNotes(List<String> keywords) {
    final results = <SearchResult>[];
    final notes = HiveService.notesBox.values.toList();

    for (final note in notes) {
      final fields = [note.title, note.content, ...note.tags];
      final score = _computeScore(keywords, fields);
      if (score > 0) {
        results.add(
          SearchResult(
            id: note.id,
            title: note.title,
            subtitle: note.content.length > 80
                ? '${note.content.substring(0, 80)}...'
                : note.content,
            type: SearchResultType.note,
            createdAt: note.createdAt,
            data: note,
            score: score,
          ),
        );
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
        ...image.tags,
      ];
      final score = _computeScore(keywords, fields);
      if (score > 0) {
        results.add(
          SearchResult(
            id: image.id,
            title: image.title,
            subtitle: image.description.isNotEmpty
                ? image.description
                : 'Image memory',
            type: SearchResultType.image,
            createdAt: image.createdAt,
            data: image,
            score: score,
          ),
        );
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
        results.add(
          SearchResult(
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
          ),
        );
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
        results.add(
          SearchResult(
            id: pdf.id,
            title: pdf.title,
            subtitle: pdf.description.isNotEmpty
                ? pdf.description
                : '${pdf.pages} pages · ${pdf.formattedFileSize}',
            type: SearchResultType.pdf,
            createdAt: pdf.createdAt,
            data: pdf,
            score: score,
          ),
        );
      }
    }
    return results;
  }

  /// Smart "Ask BrainBox" response
  static Map<String, dynamic> askBrainBox(String question) {
    final results = search(question);
    if (results.isEmpty) {
      return {'answer': null, 'results': <SearchResult>[], 'count': 0};
    }

    return {
      'answer': _buildSmartResponse(question, results),
      'results': results.take(10).toList(),
      'count': results.length,
    };
  }

  static String _buildSmartResponse(
    String question,
    List<SearchResult> results,
  ) {
    final topResult = results.first;
    final count = results.length;
    final topic = _extractTopic(question);
    final intent = _detectIntent(question);
    final typeLabel = _typeLabel(topResult.type);

    if (count == 1) {
      final topicText = topic.isEmpty ? '' : ' related to "$topic"';
      if (intent == 'locate') {
        return 'I found a $typeLabel$topicText that looks relevant to what you asked for. "${topResult.title}" seems like the best match.';
      }
      return 'I found a $typeLabel$topicText. The best match is "${topResult.title}".';
    }

    final typeBreakdown = <String, int>{};
    for (final r in results) {
      final typeName = _typeLabel(r.type);
      typeBreakdown[typeName] = (typeBreakdown[typeName] ?? 0) + 1;
    }

    final parts = typeBreakdown.entries
        .map((e) => '${e.value} ${e.key}${e.value > 1 ? 's' : ''}')
        .join(', ');

    final topicText = topic.isEmpty ? '' : ' about "$topic"';
    return 'I found $count related memories$topicText. The strongest match is "${topResult.title}" ($parts).';
  }

  static List<String> _expandQueryTerms(String question, String intent) {
    final terms = <String>{};
    final normalized = _normalize(question);
    final words = normalized.split(' ').where((w) => w.isNotEmpty).toList();

    if (intent == 'locate') {
      terms.addAll({'saved', 'store', 'where', 'location', 'place'});
    }

    if (intent == 'list') {
      terms.addAll({'notes', 'list', 'all', 'show', 'items'});
    }

    if (normalized.contains('مال') ||
        normalized.contains('money') ||
        normalized.contains('finance')) {
      terms.addAll({
        'money',
        'finance',
        'salary',
        'payment',
        'expense',
        'income',
        'commission',
        'عمولة',
      });
    }

    if (normalized.contains('عمل') ||
        normalized.contains('work') ||
        normalized.contains('job')) {
      terms.addAll({'work', 'job', 'meeting', 'office', 'project'});
    }

    for (final word in words) {
      if (word.length > 3) {
        terms.add(word);
      }
    }

    return terms.where((t) => t.isNotEmpty).toList();
  }

  static String _extractTopic(String question) {
    final words = question
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\u0600-\u06ff\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();

    final stopWords = {
      'where',
      'what',
      'who',
      'why',
      'when',
      'how',
      'did',
      'do',
      'you',
      'i',
      'my',
      'me',
      'the',
      'a',
      'an',
      'is',
      'are',
      'was',
      'were',
      'find',
      'show',
      'look',
      'search',
      'save',
      'saved',
      'remember',
      'for',
      'to',
      'from',
      'and',
      'or',
      'of',
      'in',
      'on',
      'about',
      'can',
      'could',
      'please',
      'this',
      'that',
    };

    final relevant = words.where((word) => !stopWords.contains(word)).toList();
    if (relevant.isEmpty) return '';

    return relevant.take(4).join(' ');
  }

  static String _detectIntent(String question) {
    final normalized = question.toLowerCase();
    if (normalized.contains('where') ||
        normalized.contains('saved') ||
        normalized.contains('save') ||
        normalized.contains('remember') ||
        normalized.contains('أين') ||
        normalized.contains('حفظت')) {
      return 'locate';
    }
    if (normalized.contains('show') ||
        normalized.contains('all') ||
        normalized.contains('اعرض') ||
        normalized.contains('كل') ||
        normalized.contains('list')) {
      return 'list';
    }
    return 'search';
  }

  static String _typeLabel(SearchResultType type) {
    switch (type) {
      case SearchResultType.note:
        return 'note';
      case SearchResultType.image:
        return 'image';
      case SearchResultType.voice:
        return 'voice note';
      case SearchResultType.pdf:
        return 'PDF';
    }
  }
}
