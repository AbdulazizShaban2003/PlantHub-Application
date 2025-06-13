import 'package:flutter/material.dart';
import '../../data/disease_info.dart';
import 'disease_detail_screen.dart';
import 'package:provider/provider.dart';
import '../providers/disease_provider.dart';
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
            const SizedBox(height: 16),

            SizedBox(
              height: 200,
              child: isLoading
                  ? Center(child: CircularProgressIndicator(color: Color(0xFF00A67E)))
                  : commonDiseases.isEmpty
                  ? Center(child: Text('No diseases found'))
                  : ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: commonDiseases.length,
                separatorBuilder: (context, index) => SizedBox(width: 10),
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
      child: Container(
        width: 100,
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                disease.image,
                width: 100,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 100,
                  height: 80,
                  color: Colors.grey.shade200,
                  child: Icon(Icons.image_not_supported, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Disease Name
            Text(
              disease.name,
              style: TextStyle(
                fontSize: 12,
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
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
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
      return Center(child: Text('Enter a search term'));
    }

    return FutureBuilder<List<DiseaseModel>>(
      future: Provider.of<DiseaseProvider>(context, listen: false).searchDiseases(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final results = snapshot.data ?? [];
        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final disease = results[index];
            return ListTile(
              leading: Image.network(disease.image, width: 50, height: 50),
              title: Text(disease.name),
              subtitle: Text(disease.description),
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