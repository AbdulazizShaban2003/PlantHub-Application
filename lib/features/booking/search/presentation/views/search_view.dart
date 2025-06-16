import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plant_hub_app/features/booking/search/presentation/views/search_result_list_view.dart';
import '../../../home/data/repos/home_repo_impl.dart';
import '../../../home/presentation/manger/searching_cubit/search_books_cubit.dart'
    show
    SearchBooksCubit,
    SearchBooksFailure,
    SearchBooksInitial,
    SearchBooksLoading,
    SearchBooksState,
    SearchBooksSuccess;
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
          'البحث في كتب النباتات',
          style: TextStyle(
            fontSize: SizeConfig().responsiveFont(20),
          ),
        ),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocProvider.value(
        value: _searchCubit,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(SizeConfig().width(0.04)),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(SizeConfig().width(0.05)),
                  bottomRight: Radius.circular(SizeConfig().width(0.05)),
                ),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'ابحث في كتب النباتات والزراعة...',
                      hintStyle: TextStyle(fontSize: SizeConfig().responsiveFont(14)),
                      prefixIcon: Icon(Icons.search, color: Colors.green[600], size: SizeConfig().responsiveFont(24)),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                        icon: Icon(Icons.clear, size: SizeConfig().responsiveFont(24)),
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
                      filled: true,
                      fillColor: Colors.white,
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
                      'اقتراحات البحث:',
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
                              style: TextStyle(fontSize: SizeConfig().responsiveFont(12)),
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

            // نتائج البحث
            Expanded(
              child: BlocBuilder<SearchBooksCubit, SearchBooksState>(
                builder: (context, state) {
                  if (state is SearchBooksInitial) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.local_florist,
                            size: SizeConfig().responsiveFont(64),
                            color: Colors.green[400],
                          ),
                          SizedBox(height: SizeConfig().height(0.02)),
                          Text(
                            'ابحث عن كتب النباتات والزراعة',
                            style: TextStyle(
                              fontSize: SizeConfig().responsiveFont(18),
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: SizeConfig().height(0.01)),
                          Text(
                            'اكتشف كتب أمراض النباتات، الزراعة، والعناية بالحدائق',
                            style: TextStyle(
                              fontSize: SizeConfig().responsiveFont(14),
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  } else if (state is SearchBooksLoading) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: Colors.green[600],
                          ),
                          SizedBox(height: SizeConfig().height(0.02)),
                          Text('جاري البحث في كتب النباتات...', style: TextStyle(fontSize: SizeConfig().responsiveFont(16))),
                        ],
                      ),
                    );
                  } else if (state is SearchBooksSuccess) {
                    if (state.books.isEmpty) {
                      return Center(
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
                              'لم يتم العثور على كتب نباتات',
                              style: TextStyle(
                                fontSize: SizeConfig().responsiveFont(18),
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: SizeConfig().height(0.01)),
                            Text(
                              'جرب البحث بكلمات أخرى مثل "أمراض النباتات" أو "الزراعة"',
                              style: TextStyle(
                                fontSize: SizeConfig().responsiveFont(14),
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }
                    return Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: SizeConfig().width(0.04),
                            vertical: SizeConfig().height(0.01),
                          ),
                          color: Colors.green[50],
                          child: Text(
                            'تم العثور على ${state.books.length} كتاب متعلق بالنباتات',
                            style: TextStyle(
                              color: Colors.green[700],
                              fontWeight: FontWeight.bold,
                              fontSize: SizeConfig().responsiveFont(14),
                            ),
                          ),
                        ),
                        Expanded(
                          child: SearchResultListView(books: state.books),
                        ),
                      ],
                    );
                  } else if (state is SearchBooksFailure) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: SizeConfig().responsiveFont(64),
                            color: Colors.red,
                          ),
                          SizedBox(height: SizeConfig().height(0.02)),
                          Text(
                            'حدث خطأ في البحث: ${state.errMessage}',
                            style: TextStyle(
                              fontSize: SizeConfig().responsiveFont(16),
                              color: Colors.red,
                            ),
                            textAlign: TextAlign.center,
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
                            child: Text('إعادة المحاولة', style: TextStyle(fontSize: SizeConfig().responsiveFont(16))),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink(); // Keep const
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
