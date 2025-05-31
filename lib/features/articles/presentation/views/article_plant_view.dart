import 'package:flutter/material.dart';
import 'package:plant_hub_app/config/routes/route_helper.dart';
import 'package:plant_hub_app/features/articles/presentation/views/article_plant_details_view.dart';
import 'package:plant_hub_app/features/articles/view_model.dart';
import 'package:provider/provider.dart';
import '../widgets/custom_no_plant_widget.dart';
class PlantsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final plantProvider = Provider.of<PlantViewModel>(context, listen: true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (plantProvider.allPlants.isEmpty && !plantProvider.isLoading) {
        plantProvider.fetchAllPlants();
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text('Popular Articles'), centerTitle: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search articles..',
                  suffixIcon:
                      plantProvider.searchQuery.isNotEmpty
                          ? IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () => plantProvider.clearSearch(),
                          )
                          : null,
                ),
                onChanged: (value) {
                  plantProvider.searchPlants(value);
                },
              ),
              if (plantProvider.isLoading)
                Center(child: CircularProgressIndicator()),
              if (plantProvider.error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    plantProvider.error!,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              if (!plantProvider.isLoading &&
                  plantProvider.displayedPlants.isEmpty &&
                  plantProvider.searchQuery.isNotEmpty)
                CustomNoPlantWidget(),
              SizedBox(height: 20),
              if (!plantProvider.isLoading && plantProvider.error == null) ...[
                for (var article in plantProvider.displayedPlants)
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        RouteHelper.navigateTo(
                          ArticlePlantDetailsView(plantId: article.id),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                          ),
                          child: Image.network(
                            article.image,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          maxLines: 2,
                          article.description,
                          style: TextStyle(
                            fontSize: 18,
                            overflow: TextOverflow.ellipsis,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 30),
                      ],
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

