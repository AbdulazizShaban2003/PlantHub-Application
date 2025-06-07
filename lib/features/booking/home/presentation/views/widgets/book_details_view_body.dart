
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plant_hub_app/core/utils/size_config.dart';
import 'package:plant_hub_app/features/booking/home/presentation/views/widgets/similar_books_section.dart';

import '../../../data/models/book_model/book_model.dart';
import 'books_action.dart';
import 'books_details_sectioni.dart';
import 'custom_book_details_app_bar.dart';
import 'custom_book_item.dart';

class BookDetailsViewBody extends StatelessWidget {
  const BookDetailsViewBody({super.key, required this.bookModel});

  final BookModel bookModel;
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding:  EdgeInsets.symmetric(horizontal: SizeConfig().width(0.06)),
            child: Column(
              children: [
                const CustomBookDetailsAppBar(),
                BookDetailsSection(book: bookModel,),
             SizedBox(
                    height: SizeConfig().height(0.09),
                  ),
              
                const SimilarBooksSection(),
                 SizedBox(
                  height: SizeConfig().height(0.05),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
