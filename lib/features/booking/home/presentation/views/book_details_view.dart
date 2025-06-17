import 'package:flutter/material.dart';
import 'package:plant_hub_app/features/booking/home/presentation/views/widgets/book_details_view_body.dart';
import '../../data/models/book_model/book_model.dart';

class BookDetailsView extends StatelessWidget {
  const BookDetailsView({super.key, required this.bookModel});

  final BookModel bookModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BookDetailsViewBody(
          bookModel: bookModel,
        ),
      ),
    );
  }
}