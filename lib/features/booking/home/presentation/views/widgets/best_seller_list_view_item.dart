import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plant_hub_app/config/theme/app_colors.dart';
import 'package:plant_hub_app/core/cache/cache_network_image.dart';
import 'package:plant_hub_app/core/utils/size_config.dart';
import '../../../../../../config/routes/route_helper.dart';
import '../../../../../../core/utils/styles.dart';
import '../../../data/models/book_model/book_model.dart';
import '../book_details_view.dart';
import 'custom_book_item.dart';


class BookListViewItem extends StatelessWidget {
  const BookListViewItem({super.key, required this.bookModel});

  final BookModel bookModel;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, RouteHelper.navigateTo(BookDetailsView(bookModel: bookModel)));

        },
      child: SizedBox(
        height: SizeConfig().height(0.21),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
                
                child: CacheNetworkImage(imageUrl: bookModel.volumeInfo.imageLinks?.thumbnail ?? '', width: SizeConfig().width(0.3), height: SizeConfig().height(0.45)))
            ,const SizedBox(
              width: 30,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width:SizeConfig().width(0.5),
                    child: Text(
                      bookModel.volumeInfo.title!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium
                    ),
                  ),
                   SizedBox(
                    height: SizeConfig().height(0.01),
                  ),
                  Text(
                    bookModel.volumeInfo.authors![0],
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: ColorsManager.greyColor,
                      fontStyle: FontStyle.italic
                    )
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
