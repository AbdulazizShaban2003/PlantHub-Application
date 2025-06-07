import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plant_hub_app/core/cache/cache_network_image.dart';
import 'package:plant_hub_app/core/utils/size_config.dart';
import 'package:plant_hub_app/features/booking/home/presentation/views/widgets/book_details_view_body.dart';
import '../../../../../../app/my_app.dart';
import '../../../../../../config/routes/route_helper.dart';
import '../../../../../../core/widgets/custom_error_widget.dart';
import '../../../../../../core/widgets/custom_loading_indicator.dart';
import '../../manger/smila_books_cubit/similar_books_cubit.dart';


class SimilarBooksListview extends StatelessWidget {
  const SimilarBooksListview({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SimilarBooksCubit, SimilarBooksState>(
      builder: (context, state) {
        if (state is SimilarBooksSuccess) {
          return SizedBox(
            height: SizeConfig().height(0.25),
            child: ListView.builder(
                itemCount: state.books.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return Padding(
                    padding:  EdgeInsets.symmetric(horizontal: SizeConfig().width(0.03)),
                    child: GestureDetector(
                      onTap: (){
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CacheNetworkImage(
                          imageUrl:
                              state.books[index].volumeInfo.imageLinks?.thumbnail ??
                                  '',
                          width: SizeConfig().width(0.35),
                          height: SizeConfig().height(0.2),
                        ),
                      ),
                    ),
                  );
                }),
          );
        } else if (state is SimilarBooksFailure) {
          return CustomErrorWidget(errMessage: state.errMessage);
        } else {
          return const CustomLoadingIndicator();
        }
      },
    );
  }
}
