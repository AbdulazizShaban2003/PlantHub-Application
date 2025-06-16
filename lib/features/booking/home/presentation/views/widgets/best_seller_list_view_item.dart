import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plant_hub_app/config/theme/app_colors.dart';
import 'package:plant_hub_app/core/cache/cache_network_image.dart';
import 'package:plant_hub_app/core/utils/size_config.dart';
import '../../../../../../config/routes/route_helper.dart';
import '../../../../../../core/utils/styles.dart';
import '../../../data/models/book_model/book_model.dart'; // Ensure BookModel is correct
import '../book_details_view.dart';
// import 'custom_book_item.dart'; // This import seems unused here

class BookListViewItem extends StatelessWidget {
  const BookListViewItem({super.key, required this.bookModel});

  final BookModel bookModel;

  @override
  Widget build(BuildContext context) {
    // Safely get title and author, providing fallbacks
    final String bookTitle = bookModel.volumeInfo.title ?? 'Unknown Title';
    final String bookAuthor = bookModel.volumeInfo.authors?.isNotEmpty == true
        ? bookModel.volumeInfo.authors![0]
        : 'Unknown Author';

    // Get thumbnail URL, provide fallback for empty string if CacheNetworkImage needs it
    final String imageUrl = bookModel.volumeInfo.imageLinks?.thumbnail ??
        'https://via.placeholder.com/128x192?text=No+Image'; // Placeholder image

    return GestureDetector(
      onTap: () {
        Navigator.push(context, RouteHelper.navigateTo(BookDetailsView(bookModel: bookModel)));
      },
      child: SizedBox(
        height: SizeConfig().height(0.21), // Total height of the row item
        child: Row(
          children: [
            // Book Cover Image
            AspectRatio( // Use AspectRatio to maintain aspect ratio of the image
              aspectRatio: 2.5 / 4, // Example aspect ratio for book covers (width / height)
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CacheNetworkImage(
                  imageUrl: imageUrl,
                  // width and height can be removed if using AspectRatio and fit: BoxFit.cover
                 width: null, height: null, // Ensure the image covers the box
                ),
              ),
            ),
            const SizedBox(
              width: 30, // Space between image and text
            ),
            // Book Details (Title, Author)
            Expanded( // Takes remaining horizontal space
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center, // Center content vertically in the column
                children: [
                  Text(
                    bookTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium, // Ensure this style is defined in your theme
                  ),
                  SizedBox(
                    height: SizeConfig().height(0.01), // Space between title and author
                  ),
                  Text(
                    bookAuthor,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: ColorsManager.greyColor,
                      fontStyle: FontStyle.italic,

                    ),
                  ),
                  // Add other book details here if needed (e.g., rating, price)
                  // For example, if you had a rating widget:
                  // const BookRating(), // You'd need to pass relevant data
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}