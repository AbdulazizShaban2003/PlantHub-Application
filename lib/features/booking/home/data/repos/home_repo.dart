import 'package:dartz/dartz.dart';
import 'package:plant_hub_app/core/errors/failures_api.dart';
import '../models/book_model/book_model.dart';

abstract class HomeRepo {
  Future<Either<FailureApi, List<BookModel>>> fetchNewsetBooks();
  Future<Either<FailureApi, List<BookModel>>> fetchFeaturedBooks();
  Future<Either<FailureApi, List<BookModel>>> fetchSimilarBooks(
      {required String category});

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
      'plants'
    ],
  });

  // إضافة وظيفة البحث الجديدة
  Future<Either<FailureApi, List<BookModel>>> searchBooks({
    required String query,
  });
}