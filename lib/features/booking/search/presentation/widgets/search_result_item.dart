import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plant_hub_app/config/routes/route_helper.dart';
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
import 'package:cached_network_image/cached_network_image.dart';
import '../../../home/data/models/book_model/book_model.dart';
import '../../../home/presentation/views/widgets/book_details_view_body.dart';

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
    SizeConfig().init(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Search Plant Books',
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
            // Search bar
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
                      hintText: 'Search for plant and agriculture books...',
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
                            'Search for plant and agriculture books',
                            style: TextStyle(
                              fontSize: SizeConfig().responsiveFont(18),
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: SizeConfig().height(0.01)),
                          Text(
                            'Discover books about plant diseases, agriculture, and garden care',
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
                          Text('Searching plant books...', style: TextStyle(fontSize: SizeConfig().responsiveFont(16))),
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
                              'No plant books found',
                              style: TextStyle(
                                fontSize: SizeConfig().responsiveFont(18),
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: SizeConfig().height(0.01)),
                            Text(
                              'Try searching with different keywords like "plant diseases" or "agriculture"',
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
                            'Found ${state.books.length} plant-related books',
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
                            'Search error: ${state.errMessage}',
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
                            child: Text('Try Again', style: TextStyle(fontSize: SizeConfig().responsiveFont(16))),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchResultListView extends StatelessWidget {
  const SearchResultListView({
    super.key,
    required this.books,
  });

  final List<BookModel> books;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: SizeConfig().width(0.04)),
      itemCount: books.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: SizeConfig().height(0.015)),
          child: SearchResultItem(book: books[index]),
        );
      },
    );
  }
}

class SearchResultItem extends StatelessWidget {
  const SearchResultItem({
    super.key,
    required this.book,
  });

  final BookModel book;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Card(
      elevation: 0,
      color: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SizeConfig().width(0.03)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(SizeConfig().width(0.03)),
        onTap: () {
          Navigator.push(context, RouteHelper.navigateTo(BookDetailsViewBody(bookModel: book,)) );
        },
        child: Padding(
          padding: EdgeInsets.all(SizeConfig().width(0.03)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(SizeConfig().width(0.02)),
                child: CachedNetworkImage(
                  imageUrl: book.volumeInfo.imageLinks?.thumbnail ?? '',
                  width: SizeConfig().width(0.15),
                  height: SizeConfig().height(0.1125),
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: SizeConfig().width(0.15),
                    height: SizeConfig().height(0.1125),
                    color: Colors.grey[300],
                    child: Icon(Icons.book, color: Colors.grey, size: SizeConfig().responsiveFont(40)),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: SizeConfig().width(0.15),
                    height: SizeConfig().height(0.1125),
                    color: Colors.grey[300],
                    child: Icon(Icons.book, color: Colors.grey, size: SizeConfig().responsiveFont(40)),
                  ),
                ),
              ),

              SizedBox(width: SizeConfig().width(0.03)),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.volumeInfo.title ?? 'No title available',
                      style: TextStyle(
                        fontSize: SizeConfig().responsiveFont(16),
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: SizeConfig().height(0.005)),
                    if (book.volumeInfo.authors != null &&
                        book.volumeInfo.authors!.isNotEmpty)
                      Text(
                        book.volumeInfo.authors!.join(', '),
                        style: TextStyle(
                          fontSize: SizeConfig().responsiveFont(14),
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                    SizedBox(height: SizeConfig().height(0.01)),

                    if (book.volumeInfo.description != null)
                      Text(
                        book.volumeInfo.description!,
                        style: TextStyle(
                          fontSize: SizeConfig().responsiveFont(12),
                          color: Colors.grey[700],
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),

                    SizedBox(height: SizeConfig().height(0.01)),

                    Row(
                      children: [
                        if (book.volumeInfo.averageRating != null) ...[
                          Icon(
                            Icons.star,
                            size: SizeConfig().responsiveFont(16),
                            color: Colors.amber[600],
                          ),
                          SizedBox(width: SizeConfig().width(0.01)),
                          Text(
                            book.volumeInfo.averageRating.toString(),
                            style: TextStyle(fontSize: SizeConfig().responsiveFont(12)),
                          ),
                          SizedBox(width: SizeConfig().width(0.03)),
                        ],

                        if (book.volumeInfo.publishedDate != null)
                          Text(
                            book.volumeInfo.publishedDate!,
                            style: TextStyle(
                              fontSize: SizeConfig().responsiveFont(12),
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}