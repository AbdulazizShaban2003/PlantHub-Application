import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:plant_hub_app/core/errors/failures_api.dart';
import '../../../../../core/service/api_service.dart';
import '../models/book_model/book_model.dart';
import 'home_repo.dart';

const Map<String, String> bookCategories = {
  'plants': 'plant detection disease',
  'programming': 'programming',
  'fiction': 'fiction',
  'science': 'science',
};

class HomeRepoImpl implements HomeRepo {
  final ApiService apiService;

  HomeRepoImpl(this.apiService);

  // ========== الوظائف المشتركة ==========
  Future<Either<FailureApi, List<BookModel>>> _fetchBooks({
    required String endPoint,
    String? errorContext,
  }) async {
    try {
      final data = await apiService.get(endPoint: endPoint);
      final books = (data['items'] as List)
          .map((item) => BookModel.fromJson(item))
          .toList();
      return right(books);
    } on DioError catch (e) {
      return left(ServerFailureApi.fromDioError(e));
    } catch (e) {
      return left(ServerFailureApi(
        errorContext != null ? '$errorContext: ${e.toString()}' : e.toString(),
      ));
    }
  }

  // ========== التطبيقات الرئيسية ==========
  @override
  Future<Either<FailureApi, List<BookModel>>> fetchNewsetBooks() async {
    try {
      final futures = bookCategories.values
          .map((category) => _fetchBooksByCategory(category))
          .toList();

      final results = await Future.wait(futures);

      final allBooks = results.fold<List<BookModel>>(
        [],
            (acc, result) => result.fold(
              (failure) => acc,
              (books) => [...acc, ...books],
        ),
      );

      return right(allBooks);
    } catch (e) {
      return left(ServerFailureApi('Failed to fetch newest books: ${e.toString()}'));
    }
  }

  @override
  Future<Either<FailureApi, List<BookModel>>> fetchFeaturedBooks() async {
    return _fetchBooks(
      endPoint: 'volumes?Filtering=free-ebooks&q=subject:Plant disease',
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
      'programming',
      'fiction',
      'science'
    ],
  }) async {
    try {
      final futures = categories
          .map((category) => _fetchBooks(
        endPoint: 'volumes?Filtering=free-ebooks&Sorting=newest&q=$category',
        errorContext: 'Category: $category',
      ))
          .toList();

      final results = await Future.wait(futures);

      final allBooks = results.fold<List<BookModel>>(
        [],
            (acc, result) => result.fold(
              (failure) => acc,
              (books) => [...acc, ...books],
        ),
      );

      return right(allBooks);
    } catch (e) {
      return left(ServerFailureApi('Failed to fetch all categories books: ${e.toString()}'));
    }
  }

  // ========== الدوال المساعدة ==========
  Future<Either<FailureApi, List<BookModel>>> _fetchBooksByCategory(String category) {
    return _fetchBooks(
      endPoint: 'volumes?Filtering=free-ebooks&Sorting=newest&q=$category',
      errorContext: 'Category: $category',
    );
  }
}