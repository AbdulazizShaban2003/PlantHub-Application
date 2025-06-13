// common_diseases_section.dart

import 'package:flutter/material.dart';
import 'package:plant_hub_app/core/cache/cache_network_image.dart';
import 'package:provider/provider.dart';
import '../../data/disease_info.dart';
import '../providers/disease_provider.dart';
import '../views/disease_detail_screen.dart';

class CommonDiseasesSection extends StatefulWidget {
  const CommonDiseasesSection({super.key});

  @override
  State<CommonDiseasesSection> createState() => _CommonDiseasesSectionState();
}

class _CommonDiseasesSectionState extends State<CommonDiseasesSection> {
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
        final errorMessage = diseaseProvider.errorMessage;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Common Diseases",style: Theme.of(context).textTheme.bodyMedium,),
            if (isLoading)
              const Center(
                child: CircularProgressIndicator(color: Color(0xFF00A67E)),
              )
            else if (errorMessage.isNotEmpty)
              Text(
                'Error: $errorMessage',
                style: const TextStyle(color: Colors.red),
              )
            else if (commonDiseases.isEmpty)
              const Center(child: Text('No diseases found'))
            else
              SizedBox(
                height: 1000,
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: commonDiseases.length,
                  itemBuilder: (context, index) {
                    final disease = commonDiseases[index];
                    return DiseaseCard(disease: disease);
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}

class DiseaseCard extends StatelessWidget {
  final DiseaseModel disease;

  const DiseaseCard({super.key, required this.disease});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => DiseaseDetailScreen(
                  diseaseId: disease.id,
                  diseaseName: disease.name,
                ),
          ),
        );
      },
      child: SizedBox(
        height: 300,
        child: Card(
          elevation: 0,
          color: Theme.of(context).scaffoldBackgroundColor,
          margin: const EdgeInsets.symmetric(vertical: 5),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CacheNetworkImage(
                  imageUrl: disease.image,
                  width: double.infinity,
                  height: 200,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  disease.description,
                  style: const TextStyle(color: Colors.black, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
