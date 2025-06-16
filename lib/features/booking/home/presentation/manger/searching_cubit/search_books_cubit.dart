import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/book_model/book_model.dart';
import '../../../data/repos/home_repo_impl.dart'; // تغيير إلى HomeRepoImpl

part 'search_books_state.dart';

class SearchBooksCubit extends Cubit<SearchBooksState> {
  SearchBooksCubit(this.homeRepo) : super(SearchBooksInitial());

  final HomeRepoImpl homeRepo;

  Future<void> searchBooks(String query) async {
    if (query.trim().isEmpty) {
      emit(SearchBooksInitial());
      return;
    }

    emit(SearchBooksLoading());
    var result = await homeRepo.searchBooks(query: query);
    result.fold(
          (failure) => emit(SearchBooksFailure(failure.errMessage)),
          (books) => emit(SearchBooksSuccess(books)),
    );
  }

  void clearSearch() {
    emit(SearchBooksInitial());
  }
}