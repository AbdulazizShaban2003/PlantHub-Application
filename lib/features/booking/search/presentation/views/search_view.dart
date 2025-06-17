import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plant_hub_app/config/theme/app_colors.dart';
import 'package:plant_hub_app/features/booking/search/presentation/views/search_result_list_view.dart';
import '../../../home/data/repos/home_repo_impl.dart';
import '../../../home/presentation/manger/searching_cubit/search_books_cubit.dart' show SearchBooksCubit, SearchBooksFailure, SearchBooksInitial, SearchBooksLoading, SearchBooksState, SearchBooksSuccess;
import 'package:plant_hub_app/core/utils/size_config.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({
    Key? key,
    required this.homeRepo,
  }) : super(key: key);

  final HomeRepoImpl homeRepo;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late TextEditingController _searchController;
  late SearchBooksCubit _searchCubit;

  final List<String> searchSuggestions = [
    'plant diseases',
    'tomato cultivation',
    'plant care',
    'garden management',
    'crop monitoring',
    'plant pathology',
    'agricultural techniques',
    'plant nutrition',
    'pest control',
    'plant growth',
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchCubit = SearchBooksCubit(widget.homeRepo);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Search Plant Books',
          style: TextStyle(
            fontSize: SizeConfig().responsiveFont(20),
          ),
        ),
      ),
      body: BlocProvider.value(
        value: _searchCubit,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.all(SizeConfig().width(0.04)),
              sliver: SliverToBoxAdapter(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Search books...',
                        hintStyle: TextStyle(fontSize: SizeConfig().responsiveFont(14)),
                        prefixIcon: Icon(Icons.search, color: Theme.of(context).primaryColor, size: SizeConfig().responsiveFont(24)),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                          icon: Icon(Icons.clear, size: SizeConfig().responsiveFont(24)),
                          color: Theme.of(context).primaryColor,
                          onPressed: () {
                            _searchController.clear();
                            _searchCubit.clearSearch();
                          },
                        )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(SizeConfig().width(0.03)),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: TextStyle(fontSize: SizeConfig().responsiveFont(14)),
                      onChanged: (value) {
                        setState(() {});
                        if (value.trim().isNotEmpty) {
                          Future.delayed(const Duration(milliseconds: 500), () {
                            if (_searchController.text == value) {
                              _searchCubit.searchBooks(value);
                            }
                          });
                        } else {
                          _searchCubit.clearSearch();
                        }
                      },
                      onSubmitted: (value) {
                        if (value.trim().isNotEmpty) {
                          _searchCubit.searchBooks(value);
                        }
                      },
                    ),

                    if (_searchController.text.isEmpty) ...[
                      SizedBox(height: SizeConfig().height(0.015)),
                      Text(
                        'Search Suggestions:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                          fontSize: SizeConfig().responsiveFont(16),
                        ),
                      ),
                      SizedBox(height: SizeConfig().height(0.01)),
                      Wrap(
                        spacing: SizeConfig().width(0.02),
                        runSpacing: SizeConfig().height(0.005),
                        children: searchSuggestions.take(6).map((suggestion) {
                          return GestureDetector(
                            onTap: () {
                              _searchController.text = suggestion;
                              _searchCubit.searchBooks(suggestion);
                            },
                            child: Chip(
                              label: Text(
                                suggestion,
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                              backgroundColor: Colors.green[100],
                              side: BorderSide(color: Colors.green[300]!),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Results section
            BlocBuilder<SearchBooksCubit, SearchBooksState>(
              builder: (context, state) {
                if (state is SearchBooksInitial) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.local_florist,
                            size: SizeConfig().responsiveFont(64),
                            color: Theme.of(context).primaryColor,
                          ),
                          SizedBox(height: SizeConfig().height(0.02)),
                          Text(
                            'Search for plant and agriculture books',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          SizedBox(height: SizeConfig().height(0.01)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: SizeConfig().width(0.1)),
                            child: Text(
                              'Discover books about plant diseases, agriculture, and garden care',
                              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                color: ColorsManager.greyColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (state is SearchBooksLoading) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: Colors.green[600],
                          ),
                          SizedBox(height: SizeConfig().height(0.02)),
                          Text(
                            'Searching plant books...',
                            style: TextStyle(fontSize: SizeConfig().responsiveFont(16)),
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (state is SearchBooksSuccess) {
                  if (state.books.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: SizeConfig().responsiveFont(64),
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: SizeConfig().height(0.02)),
                            Text(
                              'No plant books found',
                              style: TextStyle(
                                fontSize: SizeConfig().responsiveFont(18),
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: SizeConfig().height(0.01)),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: SizeConfig().width(0.1)),
                              child: Text(
                                'Try searching with different keywords like "plant diseases" or "agriculture"',
                                style: TextStyle(
                                  fontSize: SizeConfig().responsiveFont(14),
                                  color: Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        if (index == 0) {
                          return Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: SizeConfig().width(0.04),
                              vertical: SizeConfig().height(0.01),
                            ),
                            color: Colors.green[50],
                            child: Text(
                              'Found ${state.books.length} plant-related books',
                              style: TextStyle(
                                color: Colors.green[700],
                                fontWeight: FontWeight.bold,
                                fontSize: SizeConfig().responsiveFont(14),
                              ),
                            ),
                          );
                        }
                        return SizedBox(
                          height: MediaQuery.of(context).size.height * 0.8,
                          child: SearchResultListView(books: state.books),
                        );
                      },
                      childCount: 2,
                    ),
                  );
                } else if (state is SearchBooksFailure) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: SizeConfig().responsiveFont(64),
                            color: Colors.red,
                          ),
                          SizedBox(height: SizeConfig().height(0.02)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: SizeConfig().width(0.1)),
                            child: Text(
                              'Search error: ${state.errMessage}',
                              style: TextStyle(
                                fontSize: SizeConfig().responsiveFont(16),
                                color: Colors.red,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(height: SizeConfig().height(0.02)),
                          ElevatedButton(
                            onPressed: () {
                              if (_searchController.text.trim().isNotEmpty) {
                                _searchCubit.searchBooks(_searchController.text);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[600],
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: SizeConfig().width(0.06),
                                vertical: SizeConfig().height(0.015),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(SizeConfig().width(0.03)),
                              ),
                            ),
                            child: Text(
                              'Try Again',
                              style: TextStyle(fontSize: SizeConfig().responsiveFont(16)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              },
            ),
          ],
        ),
      ),
    );
  }
}