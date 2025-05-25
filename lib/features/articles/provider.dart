// ملف: lib/providers/plant_provider.dart
import 'package:flutter/material.dart';
import 'model.dart';

class PlantProvider with ChangeNotifier {
  List<PlantArticle> articles = [
    PlantArticle(
      id: '1',
      title: 'Unlock the Secrets of Succulents: Care Tips for Thriving Beauties',
      imageUrl: 'https://images.unsplash.com/photo-1520412099551-62b6bafeb5bb',
      description: 'Detailed guide about succulent care...',
    ),
    PlantArticle(
      id: '2',
      title: 'The Ultimate Guide to Indoor Plants: From A to Z',
      imageUrl: 'https://images.unsplash.com/photo-1512428813834-c702c7702b78',
      description: 'Comprehensive indoor plants guide...',
    ),
  ];

  List<PlantArticle> _filteredArticles = [];

  String _searchQuery = '';

  PlantProvider() {
    _filteredArticles = articles;
  }

  List<PlantArticle> get filteredArticles => _filteredArticles;

  void searchArticles(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredArticles = articles;
    } else {
      _filteredArticles = articles.where((article) {
        return article.title.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }
}