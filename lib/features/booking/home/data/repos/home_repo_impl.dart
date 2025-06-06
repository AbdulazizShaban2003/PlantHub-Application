import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:plant_hub_app/core/errors/failures_api.dart';
import '../../../../../core/service/api_service.dart';
import '../models/book_model/book_model.dart';
import 'home_repo.dart';

class HomeRepoImpl implements HomeRepo {
  final ApiService apiService;

  HomeRepoImpl(this.apiService);

  @override
  Future<Either<FailureApi,List<BookModel>>> fetchNewsetBooks() async {
    try {
      final data = await apiService.get(
        endPoint: 'volumes?Filtering=free-ebooks&Sorting=newest&q=plant detection disease',
      );

      final books = _parseBookModels(data);
      return right(books);
    } on DioError catch (e) {
      return left(ServerFailureApi.fromDioError(e));
    } catch (e) {
      return left(ServerFailureApi(e.toString()));
    }
  }

  @override
  Future<Either<FailureApi, List<BookModel>>> fetchFeaturedBooks() async {
    try {
      final data = await apiService.get(
        endPoint: 'volumes?Filtering=free-ebooks&q=subject:Plant disease',
      );

      final books = _parseBookModels(data);
      return right(books);
    } on DioError catch (e) {
      return left(ServerFailureApi.fromDioError(e));
    } catch (e) {
      return left(ServerFailureApi(e.toString()));
    }
  }

  @override
  Future<Either<FailureApi, List<BookModel>>> fetchSimilarBooks({
    required String category,
  }) async {
    try {
      final data = await apiService.get(
        endPoint: 'volumes?Filtering=free-ebooks&Sorting=relevance&q=subject:$category',
      );

      final books = _parseBookModels(data);
      return right(books);
    } on DioError catch (e) {
      return left(ServerFailureApi.fromDioError(e));
    } catch (e) {
      return left(ServerFailureApi(e.toString()));
    }
  }

  // Helper method to parse book models
  List<BookModel> _parseBookModels(Map<String, dynamic> data) {
    final List<BookModel> books = [];

    if (data['items'] != null) {
      for (final item in data['items']) {
        try {
          books.add(BookModel.fromJson(item));
        } catch (e) {
          continue;
        }
      }
    }

    return books;
  }
}