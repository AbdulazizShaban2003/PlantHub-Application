import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../data/models/book_model/book_model.dart';
import '../../../data/repos/home_repo.dart';

part 'newset_books_state.dart';

class NewsetBooksCubit extends Cubit<NewsetBooksState> {
  NewsetBooksCubit(this.homeRepo) : super(NewsetBooksInitial());

  final HomeRepo homeRepo;

  Future<void> fetchNewestBooks() async {
    emit(NewsetBooksLoading());
    var result = await homeRepo.fetchNewsetBooks();
    result.fold(
          (failure) => emit(NewsetBooksFailure(failure.errMessage)),
          (books) => emit(NewsetBooksSuccess(books)),
    );
  }

  List<BookModel> filterPlantBooks(List<BookModel> allBooks) {
    return allBooks.where((book) {
      return book.volumeInfo.categories?.any((category) =>
      category.toLowerCase().contains('plant') ||
          category.toLowerCase().contains('garden') ||
          category.toLowerCase().contains('botany')) ?? false;
    }).toList();

  }  Future<void> fetchBooksFromAllCategories() async {
    emit(NewsetBooksLoading());
    var result = await homeRepo.fetchBooksFromAllCategories();
    result.fold(
          (failure) => emit(NewsetBooksFailure(failure.errMessage)),
          (books) => emit(NewsetBooksSuccess(books)),
    );
  }
}