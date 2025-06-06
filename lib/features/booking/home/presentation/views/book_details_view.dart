import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plant_hub_app/features/booking/home/presentation/views/widgets/book_details_view_body.dart';
import '../../../../../core/service/service_locator.dart';
import '../../data/models/book_model/book_model.dart';
import '../../data/repos/home_repo_impl.dart';
import '../manger/smila_books_cubit/similar_books_cubit.dart';

class BookDetailsView extends StatelessWidget {
  const BookDetailsView({super.key, required this.bookModel});

  final BookModel bookModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocProvider(
        create: (context) {
          final cubit = SimilarBooksCubit( sl.get<HomeRepoImpl>());
          // Fetch similar books when the cubit is created
          if (bookModel.volumeInfo.categories != null &&
              bookModel.volumeInfo.categories!.isNotEmpty) {
            cubit.fetchSimilarBooks(
              category: bookModel.volumeInfo.categories![0],
            );
          }
          return cubit;
        },
          child: BookDetailsViewBody(
            bookModel: bookModel,
          ),
        ),
      ),
    );
  }
}