import 'package:flutter/material.dart';
import 'package:plant_hub_app/core/utils/size_config.dart';
import '../../../../../../core/service/service_locator.dart';
import '../../../../../../core/utils/app_strings.dart';
import '../../../../search/presentation/views/search_view.dart';
import 'best_seller_list_view.dart';
import 'featured_list_view.dart';
import '../../../data/repos/home_repo_impl.dart';
import 'package:easy_localization/easy_localization.dart';

class BookViewBody extends StatelessWidget {
  const BookViewBody({
    super.key,
    this.homeRepo,
  });

  final HomeRepoImpl? homeRepo;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig().width(0.04),
                    vertical: SizeConfig().height(0.03)),
                child: GestureDetector(
                  onTap: () {
                    final repo = homeRepo ?? sl<HomeRepoImpl>();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SearchPage(homeRepo: repo),
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: SizeConfig().width(0.04),
                        vertical: SizeConfig().height(0.01)),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(SizeConfig().width(0.03)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                            Icons.search,
                            color: Colors.grey[600],
                            size: SizeConfig().responsiveFont(20)),
                        SizedBox(width: SizeConfig().width(0.03)),
                        Text(
                          AppStrings.searchBookHint.tr(),
                          style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: SizeConfig().responsiveFont(16)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const FeaturedBooksListView(),
              SizedBox(height: SizeConfig().height(0.03)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: SizeConfig().width(0.075)),
                child: Text(
                  AppStrings.newestBooks,
                  style: Theme.of(context).textTheme.bodyMedium,
              ),
              ),
              SizedBox(height: SizeConfig().height(0.01)),
            ],
          ),
        ),
        SliverFillRemaining(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: SizeConfig().width(0.075)),
            child: const BestSellerListView(),
          ),
        ),
      ],
    );
  }
}