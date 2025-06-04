import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:plant_hub_app/features/articles/data/models/plant_model.dart';
import 'package:provider/provider.dart';
import '../bookMark/bookmark_service.dart';
import 'domain/repositories/plant_repo.dart';

class PlantViewModel with ChangeNotifier {
  Plant? _selectedPlant;
  List<Plant> _allPlants = [];
  List<Plant> _filteredPlants = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';

  // Getter methods
  Plant? get selectedPlant => _selectedPlant;
  List<Plant> get allPlants => _allPlants;
  List<Plant> get displayedPlants => _searchQuery.isEmpty ? _allPlants : _filteredPlants;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;

  final PlantRepository  _plantRepository= PlantRepository();
  PlantViewModel(){
    _filteredPlants = _allPlants;
  }
  Future<void> fetchPlantById(String id) async {
    if (id.isEmpty) {
      _setError('يجب تحديد معرف النبات');
      return;
    }

    try {
      _startLoading();
      final plant = await _plantRepository.getPlantById(id);

      if (plant == null) {
        _setError('لم يتم العثور على النبات المطلوب');
      } else {
        _selectedPlant = plant;
        _clearError();
      }
    } on FirebaseException catch (e) {
      _setError(_translateFirebaseError(e));
    } catch (e) {
      _setError('حدث خطأ غير متوقع أثناء جلب بيانات النبات');
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
        _setError('لا توجد نباتات متاحة حالياً');
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
      _setError('تعذر تحميل قائمة النباتات');
      debugPrint('Error fetching plants: $e');
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
        // البحث فقط في الاسم والوصف
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
        return 'ليس لديك صلاحية الوصول للبيانات';
      case 'not-found':
        return 'البيانات المطلوبة غير متوفرة';
      case 'unavailable':
        return 'الخدمة غير متوفرة. يرجى التأكد من اتصالك بالإنترنت';
      default:
        return 'حدث خطأ في النظام: ${e.message}';
    }
  }

// داخل PlantViewModel
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