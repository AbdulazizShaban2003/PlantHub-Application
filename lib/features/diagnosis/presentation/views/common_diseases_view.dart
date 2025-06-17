import 'package:flutter/material.dart';
import '../../data/disease_info.dart';
import 'disease_detail_screen.dart';
import 'package:provider/provider.dart';
import '../providers/disease_provider.dart';
import 'package:plant_hub_app/core/utils/size_config.dart'; // Import SizeConfig

class CommonDiseasesView extends StatefulWidget {
  const CommonDiseasesView({super.key});

  @override
  State<CommonDiseasesView> createState() => _CommonDiseasesViewState();
}

class _CommonDiseasesViewState extends State<CommonDiseasesView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DiseaseProvider>(context, listen: false).loadCommonDiseases();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DiseaseProvider>(
      builder: (context, diseaseProvider, child) {
        final commonDiseases = diseaseProvider.commonDiseases;
        final isLoading = diseaseProvider.isLoading;
        return Column(
          children: [
            SizedBox(height: SizeConfig().height(0.02)),
            SizedBox(
              height: SizeConfig().height(0.25),
              child: isLoading
                  ? Center(child: CircularProgressIndicator(color: const Color(0xFF00A67E)))
                  : commonDiseases.isEmpty
                  ? Center(child: Text('No diseases found', style: TextStyle(fontSize: SizeConfig().responsiveFont(16))))
                  : ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: commonDiseases.length,
                separatorBuilder: (context, index) => SizedBox(width: SizeConfig().width(0.025)),
                itemBuilder: (context, index) {
                  final disease = commonDiseases[index];
                  return _buildDiseaseItem(disease);
                },
              ),
            ),
          ],
        );
      },
    );
  }
  Widget _buildDiseaseItem(DiseaseModel disease) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DiseaseDetailScreen(
              diseaseId: disease.id,
              diseaseName: disease.name,
            ),
          ),
        );
      },
      child: SizedBox(
        width: SizeConfig().width(0.25),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(SizeConfig().width(0.02)),
              child: Image.network(
                disease.image,
                width: SizeConfig().width(0.25),
                height: SizeConfig().height(0.1),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: SizeConfig().width(0.25),
                  height: SizeConfig().height(0.1),
                  color: Colors.grey.shade200,
                  child: Icon(Icons.image_not_supported, color: Colors.grey, size: SizeConfig().responsiveFont(30)),
                ),
              ),
            ),
            SizedBox(height: SizeConfig().height(0.01)),
            // Disease Name
            Text(
              disease.name,
              style: TextStyle(
                fontSize: SizeConfig().responsiveFont(12),
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class DiseaseSearchDelegate extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    SizeConfig().init(context);

    return [
      IconButton(
        icon: Icon(Icons.clear, size: SizeConfig().responsiveFont(24)),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    SizeConfig().init(context);

    return IconButton(
      icon: Icon(Icons.arrow_back, size: SizeConfig().responsiveFont(24)),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {

    if (query.isEmpty) {
      return Center(child: Text('Enter a search term', style: TextStyle(fontSize: SizeConfig().responsiveFont(16))));
    }

    return FutureBuilder<List<DiseaseModel>>(
      future: Provider.of<DiseaseProvider>(context, listen: false).searchDiseases(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(fontSize: SizeConfig().responsiveFont(16))));
        }

        final results = snapshot.data ?? [];
        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final disease = results[index];
            return ListTile(
              leading: Image.network(disease.image, width: SizeConfig().width(0.125), height: SizeConfig().height(0.0625)),
              title: Text(disease.name, style: TextStyle(fontSize: SizeConfig().responsiveFont(16))),
              subtitle: Text(disease.description, style: TextStyle(fontSize: SizeConfig().responsiveFont(14))),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DiseaseDetailScreen(
                      diseaseId: disease.id,
                      diseaseName: disease.name,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
