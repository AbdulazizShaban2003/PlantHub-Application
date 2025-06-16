import 'package:flutter/material.dart';
import 'package:plant_hub_app/core/utils/size_config.dart';
import '../../../home/data/models/book_model/book_model.dart' show BookModel;
import '../widgets/search_result_item.dart';
class SearchResultListView extends StatelessWidget {
  const SearchResultListView({
    super.key,
    required this.books,
  });

  final List<BookModel> books;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding:  EdgeInsets.symmetric(horizontal: SizeConfig().width(0.02)),
      itemCount: books.length,
      itemBuilder: (context, index) {
        return Padding(
          padding:  EdgeInsets.only(bottom:  SizeConfig().height(0.1)),
          child: SearchResultItem(book: books[index]),
        );
      },
    );
  }
}