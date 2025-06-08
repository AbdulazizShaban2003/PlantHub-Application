import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:plant_hub_app/features/articles/data/models/plant_model.dart';
import 'package:provider/provider.dart';
import '../bookMark/data/models/datasource/bookmark_service.dart';
import 'domain/repositories/plant_repo.dart';

class PlantViewModel with ChangeNotifier {
  Plant? _selectedPlant;
  List<Plant> _allPlants = [];
  List<Plant> _filteredPlants = [];
  List<Plant> _categoryPlants = [];

  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  Plant? get selectedPlant => _selectedPlant;
  List<Plant> get allPlants => _allPlants;
  List<Plant> get displayedPlants => _searchQuery.isEmpty ? _allPlants : _filteredPlants;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String? _selectedCategory;

  String? get selectedCategory => _selectedCategory;

  final PlantRepository  _plantRepository= PlantRepository();
  PlantViewModel(){
    _filteredPlants = _allPlants;
  }
  Future<void> fetchPlantById(String id) async {
    if (id.isEmpty) {
      _setError('Plant ID must be specified');
      return;
    }

    try {
      _startLoading();
      final plant = await _plantRepository.getPlantById(id);

      if (plant == null) {
        _setError('The requested plant was not found');
      } else {
        _selectedPlant = plant;
        _clearError();
      }
    } on FirebaseException catch (e) {
      _setError(_translateFirebaseError(e));
    } catch (e) {
      _setError('An unexpected error occurred while fetching plant data');
      debugPrint('Error fetching plant: $e');
    } finally {
      _stopLoading();
    }
  }
  Future<void> fetchAllPlants() async {
    try {
      _startLoading();
      final plants = await _plantRepository.getAllPlants();
      if (plants.isEmpty) {
        _setError('No plants are currently available');
        if (_allPlants.isEmpty) {
          await fetchAllPlants();
        }
      } else {
        _allPlants = plants;
        _filteredPlants = plants;
        _clearError();
      }
    } on FirebaseException catch (e) {
      _setError(_translateFirebaseError(e));
    } catch (e) {
      _setError('Failed to load plants list');
      debugPrint('Error fetching plants: $e');
    } finally {
      _stopLoading();
    }
  }
  Future<void> fetchPlantsByCategory(String category) async {
    try {
      _startLoading();
      _selectedCategory = category;

      // استخدام الدالة المرنة للبحث
      final plants = await _plantRepository.getPlantsByCategoryFlexible(category);

      if (plants.isEmpty) {
        _setError('No plants found in this category');
        _categoryPlants = [];
      } else {
        _categoryPlants = plants;
        _clearError();
      }
    } on FirebaseException catch (e) {
      _setError(_translateFirebaseError(e));
    } catch (e) {
      _setError('Failed to load plants for this category');
      debugPrint('Error fetching plants by category: $e');
    } finally {
      _stopLoading();
    }
  }
  void searchPlants(String query) {
    _searchQuery = query.trim().toLowerCase();

    if (_searchQuery.isEmpty) {
      _filteredPlants = _allPlants;
    } else {
      _filteredPlants = _allPlants.where((plant) {
        return plant.name.toLowerCase().contains(_searchQuery) ||
            (plant.description?.toLowerCase().contains(_searchQuery) ?? false);
      }).toList();
    }

    notifyListeners();
  }  void clearSearch() {
    _searchQuery = '';
    _filteredPlants = _allPlants;
    _clearError();
    notifyListeners();
  }

  void clearSelectedPlant() {
    _selectedPlant = null;
    notifyListeners();
  }
  void clearSelectedCategory() {
    _selectedCategory = null;
    _filteredPlants = _allPlants;
    notifyListeners();
  }

  void _startLoading() {
    _isLoading = true;
    _error = null;
    notifyListeners();
  }
  void _stopLoading() {
    _isLoading = false;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
  String _translateFirebaseError(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'You don\'t have permission to access the data';
      case 'not-found':
        return 'The requested data is not available';
      case 'unavailable':
        return 'Service unavailable. Please check your internet connection';
      default:
        return 'A system error occurred: ${e.message}';
    }
  }
  List<Plant> getPlantsByCategory(String category) {
    if (_allPlants.isEmpty) {
      return [];
    }

    return _allPlants.where((plant) {
      final plantCategory = plant.category.toLowerCase();
      final searchCategory = category.toLowerCase();

      return plantCategory == searchCategory ||
          plantCategory.contains(searchCategory) ||
          _matchCategoryKeywords(plantCategory, searchCategory);
    }).toList();
  }
  bool _matchCategoryKeywords(String plantCategory, String searchCategory) {
    final categoryMappings = {
      'succulents': ['succulent', 'cacti', 'cactus'],
      'flowering': ['flower', 'bloom', 'blossom'],
      'foliage': ['leaf', 'leaves', 'foliage'],
      'trees': ['tree', 'woody'],
      'shrubs': ['shrub', 'bush', 'weed'],
      'fruits': ['fruit', 'berry'],
      'vegetables': ['vegetable', 'veggie'],
      'herbs': ['herb', 'aromatic'],
      'mushrooms': ['mushroom', 'fungi'],
      'toxic': ['toxic', 'poisonous', 'dangerous'],
    };

    final keywords = categoryMappings[searchCategory] ?? [];
    return keywords.any((keyword) => plantCategory.contains(keyword));
  }
  Future<List<Plant>> getBookmarkedPlants(BuildContext context) async {
    final bookmarkService = Provider.of<BookmarkService>(context, listen: false);
    final bookmarks = await bookmarkService.getUserBookmarks().first;

    return allPlants.where((plant) {
      return bookmarks.any((bookmark) => bookmark.itemId == plant.id);
    }).toList();
  }

  Stream<List<Plant>> getBookmarkedPlantsStream(BuildContext context) {
    final bookmarkService = Provider.of<BookmarkService>(context, listen: true);

    return bookmarkService.getUserBookmarks().asyncMap((bookmarks) {
      return allPlants.where((plant) {
        return bookmarks.any((bookmark) => bookmark.itemId == plant.id);
      }).toList();
    });
  }
}