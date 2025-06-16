import 'package:flutter/material.dart';
import 'package:plant_hub_app/core/utils/size_config.dart';
import '../../../../../../core/service/service_locator.dart';
import '../../../../search/presentation/views/search_view.dart';
import 'best_seller_list_view.dart';

import 'featured_list_view.dart';

import '../../../data/repos/home_repo_impl.dart';

class BookViewBody extends StatelessWidget {
  const BookViewBody({
    super.key,
    this.homeRepo,
  });

  final HomeRepoImpl? homeRepo;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // شريط البحث القابل للضغط
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
                      vertical: SizeConfig().height(0.02),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search,
                          color: Colors.grey[600],
                          size: 20,
                        ),
                        SizedBox(width: SizeConfig().width(0.03)),
                        Text(
                          "search book...",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const FeaturedBooksListView(),
              SizedBox(
                height: SizeConfig().height(0.03),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Text(
                  'Newest Books',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
        const SliverFillRemaining(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: BestSellerListView(),
          ),
        ),
      ],
    );
  }
}