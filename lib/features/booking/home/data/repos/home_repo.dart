import 'package:dartz/dartz.dart';
import 'package:plant_hub_app/core/errors/failures_api.dart';

import '../../../../../core/errors/failure_auth.dart';
import '../models/book_model/book_model.dart';

abstract class HomeRepo {
  Future<Either<FailureApi, List<BookModel>>> fetchNewsetBooks();
  Future<Either<FailureApi, List<BookModel>>> fetchFeaturedBooks();
  Future<Either<FailureApi, List<BookModel>>> fetchSimilarBooks(
      {required String category});
}
