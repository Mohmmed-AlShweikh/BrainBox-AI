import 'package:flutter/material.dart';
import '../services/search_service.dart';

class SearchProvider extends ChangeNotifier {
  String _query = '';
  List<SearchResult> _results = [];
  SearchResultType? _filter;
  bool _isSearching = false;

  String get query => _query;
  List<SearchResult> get results => _results;
  SearchResultType? get filter => _filter;
  bool get isSearching => _isSearching;
  bool get hasResults => _results.isNotEmpty;
  bool get hasQuery => _query.trim().isNotEmpty;

  void setFilter(SearchResultType? filter) {
    _filter = filter;
    _runSearch();
    notifyListeners();
  }

  void search(String query) {
    _query = query;
    _runSearch();
    notifyListeners();
  }

  void _runSearch() {
    if (_query.trim().isEmpty) {
      _results = [];
      return;
    }
    _isSearching = true;
    _results = SearchService.search(_query, filter: _filter);
    _isSearching = false;
  }

  void clear() {
    _query = '';
    _results = [];
    _filter = null;
    notifyListeners();
  }
}
