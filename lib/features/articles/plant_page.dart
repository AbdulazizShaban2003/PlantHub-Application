// ملف: lib/pages/plants_page.dart
import 'package:flutter/material.dart';
import 'package:plant_hub_app/features/articles/provider.dart';
import 'package:provider/provider.dart';

class PlantsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final plantProvider = Provider.of<PlantProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Popular Articles'), centerTitle: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search articles..',
                ),
                onChanged: (value) {
                  plantProvider.searchArticles(value);
                },
              ),
              SizedBox(height: 20),
              ...plantProvider.filteredArticles.map((article) {
                return Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                      child: Image.network(
                        article.imageUrl,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      article.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 30),
                  ],
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}