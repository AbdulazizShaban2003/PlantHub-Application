import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plant_hub_app/core/cache/cache_network_image.dart';
import 'package:plant_hub_app/core/utils/size_config.dart';
import '../../../../../../config/routes/route_helper.dart';
import '../../../../../../core/widgets/custom_error_widget.dart';
import '../../../../../../core/widgets/custom_loading_indicator.dart';
import '../../manger/featured_books_cubit/featured_books_cubit.dart';
import '../book_details_view.dart';
import 'custom_book_item.dart';

class FeaturedBooksListView extends StatelessWidget {
  const FeaturedBooksListView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeaturedBooksCubit, FeaturedBooksState>(
      builder: (context, state) {
        if (state is FeaturedBooksSuccess) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: SizeConfig().height(0.27),
              child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: state.books.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding:  EdgeInsets.symmetric(horizontal: SizeConfig().width(0.02)),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(context, RouteHelper.navigateTo(BookDetailsView(bookModel: state.books[index])));
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: CacheNetworkImage(
                            width: SizeConfig().width(0.4),
                            height: SizeConfig().height(0.3),
                            imageUrl: state.books[index].volumeInfo.imageLinks
                                    ?.thumbnail ??
                                '',
                          ),
                        ),
                      ),
                    );
                  }),
            ),
          );
        } else if (state is FeaturedBooksFailure) {
          return CustomErrorWidget(errMessage: state.errMessage);
        } else {
          return const CustomLoadingIndicator();
        }
      },
    );
  }
}
