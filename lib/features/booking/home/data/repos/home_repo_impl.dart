import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:plant_hub_app/core/errors/failures_api.dart';
import '../../../../../core/service/api_service.dart';
import '../models/book_model/book_model.dart';
import 'home_repo.dart';

const Map<String, String> bookCategories = {
  'plant': 'plant',
  'plant disease': 'plant disease',
  'tomato disease': 'tomato disease',
  'pea disease': 'pea disease',
  'orange disease': 'orange disease',
  'corn disease': 'corn disease',
  'eggplant disease': 'eggplant disease',
  'wheat disease': 'wheat disease',
  'monitoring plants': 'monitoring plants',
};

List<String> categories = const [
  'plant detection disease',
  'tomato disease',
  'pea disease',
  'orange disease',
  'corn disease',
  'eggplant disease',
  'wheat disease',
  'monitoring plants',
  'plants disease',
  'plants',
];

// الكلمات المفتاحية المتعلقة بالنباتات
const List<String> plantKeywords = [
  'plant',
  'plants',
  'garden',
  'gardening',
  'botany',
  'botanical',
  'agriculture',
  'farming',
  'crop',
  'crops',
  'disease',
  'pest',
  'soil',
  'seed',
  'seeds',
  'flower',
  'flowers',
  'tree',
  'trees',
  'leaf',
  'leaves',
  'root',
  'roots',
  'tomato',
  'pea',
  'orange',
  'corn',
  'eggplant',
  'wheat',
  'monitoring',
  'detection',
  'cultivation',
  'horticulture',
  'vegetable',
  'vegetables',
  'fruit',
  'fruits',
];

class HomeRepoImpl implements HomeRepo {
  final ApiService apiService;

  HomeRepoImpl(this.apiService);

  Future<Either<FailureApi, List<BookModel>>> _fetchBooks({
    required String endPoint,
    String? errorContext,
  }) async {
    try {
      final data = await apiService.get(endPoint: endPoint);
      final books =
      (data['items'] as List)
          .map((item) => BookModel.fromJson(item))
          .toList();
      return right(books);
    } on DioError catch (e) {
      return left(ServerFailureApi.fromDioError(e));
    } catch (e) {
      return left(
        ServerFailureApi(
          errorContext != null
              ? '$errorContext: ${e.toString()}'
              : e.toString(),
        ),
      );
    }
  }

  // باقي الوظائف الموجودة...
  @override
  Future<Either<FailureApi, List<BookModel>>> fetchNewsetBooks() async {
    try {
      final futures =
      bookCategories.values
          .map((category) => _fetchBooksByCategory(category))
          .toList();

      final results = await Future.wait(futures);

      final allBooks = results.fold<List<BookModel>>(
        [],
            (acc, result) =>
            result.fold((failure) => acc, (books) => [...acc, ...books]),
      );

      return right(allBooks);
    } catch (e) {
      return left(
        ServerFailureApi('Failed to fetch newest books: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<FailureApi, List<BookModel>>> fetchFeaturedBooks() async {
    return _fetchBooks(
      endPoint: 'volumes?Filtering=free-ebooks&q=subject:$bookCategories',
      errorContext: 'Featured Books',
    );
  }

  @override
  Future<Either<FailureApi, List<BookModel>>> fetchSimilarBooks({
    required String category,
  }) async {
    return _fetchBooks(
      endPoint: 'volumes?Filtering=free-ebooks&Sorting=relevance&q=$category',
      errorContext: 'Similar Books',
    );
  }

  @override
  Future<Either<FailureApi, List<BookModel>>> fetchBooksFromAllCategories({
    List<String> categories = const [
      'plant detection disease',
      'tomato disease',
      'pea disease',
      'orange disease',
      'corn disease',
      'eggplant disease',
      'wheat disease',
      'monitoring plants',
      'plants disease',
      'plants',
    ],
  }) async {
    try {
      final futures =
      categories
          .map(
            (category) => _fetchBooks(
          endPoint:
          'volumes?Filtering=free-ebooks&Sorting=newest&q=$category',
          errorContext: 'Category: $category',
        ),
      )
          .toList();

      final results = await Future.wait(futures);

      final allBooks = results.fold<List<BookModel>>(
        [],
            (acc, result) =>
            result.fold((failure) => acc, (books) => [...acc, ...books]),
      );

      return right(allBooks);
    } catch (e) {
      return left(
        ServerFailureApi(
          'Failed to fetch all categories books: ${e.toString()}',
        ),
      );
    }
  }

  Future<Either<FailureApi, List<BookModel>>> _fetchBooksByCategory(
      String category,
      ) {
    return _fetchBooks(
      endPoint: 'volumes?Filtering=free-ebooks&Sorting=newest&q=$category',
      errorContext: 'Category: $category',
    );
  }

  // وظيفة البحث المخصصة للنباتات
  @override
  Future<Either<FailureApi, List<BookModel>>> searchBooks({
    required String query,
  }) async {
    try {
      // تنظيف النص المدخل
      final cleanQuery = query.trim().toLowerCase();

      // إنشاء استعلام البحث المحسن للنباتات
      final plantSearchQuery = _buildPlantSearchQuery(cleanQuery);

      final data = await apiService.get(
        endPoint: 'volumes?q=$plantSearchQuery&maxResults=30&orderBy=relevance',
      );

      if (data['items'] == null) {
        return right([]);
      }

      final allBooks = (data['items'] as List)
          .map((item) => BookModel.fromJson(item))
          .toList();

      // تصفية الكتب للتأكد من أنها متعلقة بالنباتات
      final filteredBooks = _filterPlantRelatedBooks(allBooks, cleanQuery);

      return right(filteredBooks);
    } on DioError catch (e) {
      return left(ServerFailureApi.fromDioError(e));
    } catch (e) {
      return left(
        ServerFailureApi('Failed to search books: ${e.toString()}'),
      );
    }
  }

  // بناء استعلام البحث المحسن للنباتات
  String _buildPlantSearchQuery(String userQuery) {
    // إضافة كلمات مفتاحية متعلقة بالنباتات لاستعلام المستخدم
    final plantTerms = ['plant', 'plants', 'agriculture', 'botany', 'garden'];

    // دمج استعلام المستخدم مع المصطلحات النباتية
    final combinedQuery = '$userQuery+plant OR $userQuery+plants OR $userQuery+agriculture OR $userQuery+botany';

    return combinedQuery.replaceAll(' ', '+');
  }

  // تصفية الكتب للتأكد من أنها متعلقة بالنباتات
  List<BookModel> _filterPlantRelatedBooks(List<BookModel> books, String userQuery) {
    return books.where((book) {
      // فحص العنوان
      final title = book.volumeInfo.title?.toLowerCase() ?? '';

      // فحص الوصف
      final description = book.volumeInfo.description?.toLowerCase() ?? '';

      // فحص الفئات
      final categories = book.volumeInfo.categories?.map((c) => c.toLowerCase()).toList() ?? [];

      // فحص المؤلفين
      final authors = book.volumeInfo.authors?.map((a) => a.toLowerCase()).toList() ?? [];

      // فحص الموضوع
      final subject = book.volumeInfo.description?.toLowerCase() ?? '';

      // دمج كل النصوص للبحث
      final allText = '$title $description ${categories.join(' ')} ${authors.join(' ')} $subject';

      // التحقق من وجود كلمات مفتاحية نباتية
      final hasPlantKeywords = plantKeywords.any((keyword) =>
          allText.contains(keyword.toLowerCase())
      );

      // التحقق من وجود استعلام المستخدم
      final hasUserQuery = userQuery.isEmpty ||
          allText.contains(userQuery) ||
          _isQueryRelatedToPlants(userQuery, allText);

      return hasPlantKeywords && hasUserQuery;
    }).toList();
  }

  // فحص ما إذا كان استعلام المستخدم متعلق بالنباتات
  bool _isQueryRelatedToPlants(String query, String bookText) {
    // قائمة بالمرادفات والكلمات ذات الصلة
    final queryWords = query.split(' ');

    for (final word in queryWords) {
      if (plantKeywords.any((keyword) =>
      keyword.toLowerCase().contains(word.toLowerCase()) ||
          word.toLowerCase().contains(keyword.toLowerCase())
      )) {
        return true;
      }
    }

    // فحص إضافي للكلمات المتشابهة
    final similarWords = {
      'disease': ['diseases', 'infection', 'pathology'],
      'grow': ['growing', 'growth', 'cultivation'],
      'care': ['caring', 'maintenance', 'management'],
      'water': ['watering', 'irrigation', 'hydration'],
    };

    for (final word in queryWords) {
      for (final entry in similarWords.entries) {
        if (word.toLowerCase() == entry.key ||
            entry.value.contains(word.toLowerCase())) {
          return bookText.contains(entry.key) ||
              entry.value.any((synonym) => bookText.contains(synonym));
        }
      }
    }

    return false;
  }
}