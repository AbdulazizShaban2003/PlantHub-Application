import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plant_hub_app/config/routes/route_helper.dart';
import 'package:plant_hub_app/features/booking/home/presentation/views/book_details_view.dart';
import 'package:plant_hub_app/features/booking/home/presentation/views/book_view.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/size_config.dart';
import '../../../../core/widgets/custom_error_widget.dart';
import '../../../booking/home/data/models/book_model/book_model.dart';
import '../../../booking/home/presentation/manger/newest_books_cubit/newset_books_cubit.dart';
import '../components/build_header.dart';

class CustomExplorBook extends StatelessWidget {
  const CustomExplorBook({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BuildHeader(
          header: AppKeyStringTr.exploreBooks,
          onTab: () {
            Navigator.push(context, RouteHelper.navigateTo(BookView()));
          },
        ),
        const SizedBox(height: 30),
        SizedBox(
          height: SizeConfig().height(0.25),
          child: BlocBuilder<NewsetBooksCubit, NewsetBooksState>(
            builder: (context, state) {
              if (state is NewsetBooksSuccess) {
                final plantBooks = state.books.where((book) {
                  return book.volumeInfo.categories?.any((category) =>
                      category.toLowerCase().contains('plant')) ?? false;
                }).toList();

                if (plantBooks.isEmpty) {
                  return Center(
                    child: Text(
                      'لا توجد كتب نباتات متاحة',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  );
                }

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: plantBooks.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(
                        right: SizeConfig().width(0.05),
                        left: index == 0 ? SizeConfig().width(0.05) : 0,
                      ),
                      child: ExploreBookImageItem(bookModel: plantBooks[index]),
                    );
                  },
                );
              } else if (state is NewsetBooksFailure) {
                return CustomErrorWidget(errMessage: state.errMessage);
              } else {
                return _buildShimmerEffect();
              }
            },
          ),
        ),
        SizedBox(height: SizeConfig().height(0.03)),
      ],
    );
  }

  Widget _buildShimmerEffect() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(
            right: SizeConfig().width(0.05),
            left: index == 0 ? SizeConfig().width(0.05) : 0,
          ),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: SizeConfig().width(0.35),
              height: SizeConfig().height(0.15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      },
    );
  }
}

class ExploreBookImageItem extends StatelessWidget {
  final BookModel bookModel;

  const ExploreBookImageItem({super.key, required this.bookModel});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, RouteHelper.navigateTo(BookDetailsView(bookModel: bookModel)));
      },
       child:  ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
            imageUrl: bookModel.volumeInfo.imageLinks?.thumbnail ?? '',
            width: MediaQuery.of(context).size.width * 0.35,
            height: MediaQuery.of(context).size.height * 0.15,
            fit: BoxFit.cover,
            placeholder: (context, url) => Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                color: Colors.white,
                width: MediaQuery.of(context).size.width * 0.35,
                height: MediaQuery.of(context).size.height * 0.15,
              ),
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.grey[200],
              child: const Icon(Icons.broken_image, color: Colors.grey),
            ),
          ),
        )
    );
  }
}