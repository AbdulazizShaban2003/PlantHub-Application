import 'package:flutter/material.dart';
import '../models/model.dart';
import '../models/plant_article_model.dart';

class PlantProvider with ChangeNotifier {

  List<PlantArticle> _filteredArticles = [];

  String searchQuery = '';
  bool _isSearching = false;


  PlantProvider() {
    _filteredArticles = articles;
  }

  List<PlantArticle> get filteredArticles => _filteredArticles;
  bool get isSearching => _isSearching;

  void searchArticles(String query) async {
    searchQuery = query;
    _isSearching = true;
    if (query.isEmpty) {
      _filteredArticles = articles;
    } else {
      _filteredArticles = articles.where((article) {
        return article.title.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    _isSearching = false;
    notifyListeners();
  }
  List<PlantArticle> get bookmarkedArticles {
    return articles.where((article) => article.isBookmarked).toList();
  }
  void toggleBookmark(String articleId) {
    final articleIndex = articles.indexWhere((a) => a.id == articleId);
    if (articleIndex >= 0) {
      articles[articleIndex].isBookmarked = !articles[articleIndex].isBookmarked;
      notifyListeners();
    }
  }
}