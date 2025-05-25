// ملف: lib/pages/bookmarked_articles_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../articles/view_model/plant_provider.dart';

class BookmarkedArticlesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final plantProvider = Provider.of<PlantProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Bookmarked Articles'),
        centerTitle: true,
      ),
      body: plantProvider.bookmarkedArticles.isEmpty
          ? Center(
        child: Text(
          'No bookmarked articles yet',
          style: TextStyle(fontSize: 18),
        ),
      )
          : ListView.builder(
        itemCount: plantProvider.bookmarkedArticles.length,
        itemBuilder: (ctx, index) {
          final article = plantProvider.bookmarkedArticles[index];
          return ListTile(
            leading: Image.network(
              article.imageUrl,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
            title: Text(article.title),
            trailing: IconButton(
              icon: Icon(Icons.bookmark, color: Colors.amber),
              onPressed: () {
                plantProvider.toggleBookmark(article.id);
              },
            ),
          );
        },
      ),
    );
  }
}