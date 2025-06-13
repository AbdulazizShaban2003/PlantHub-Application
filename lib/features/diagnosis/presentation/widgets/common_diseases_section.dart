import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/disease_info.dart';
import '../providers/disease_provider.dart';
import '../views/disease_detail_screen.dart';

class CommonDiseasesSection extends StatelessWidget {
  const CommonDiseasesSection({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DiseaseProvider>(context, listen: false).loadCommonDiseases();
    });

    return Consumer<DiseaseProvider>(
      builder: (context, diseaseProvider, child) {
        final commonDiseases = diseaseProvider.commonDiseases;
        final isLoading = diseaseProvider.isLoading;
        final errorMessage = diseaseProvider.errorMessage;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Common Diseases',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'View All',
                    style: TextStyle(
                      color: Color(0xFF00A67E),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (isLoading)
              const Center(child: CircularProgressIndicator(color: Color(0xFF00A67E)))
            else if (errorMessage.isNotEmpty)
              Text('Error: $errorMessage', style: const TextStyle(color: Colors.red))
            else if (commonDiseases.isEmpty)
                const Center(child: Text('No diseases found'))
              else
                SizedBox(
                  height: 200, // حدد ارتفاعًا مناسبًا حسب التصميم
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
            builder: (context) => DiseaseDetailScreen(
              diseaseId: disease.id,
              diseaseName: disease.name,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2E),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            disease.image.isNotEmpty
                ? ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                disease.image,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.sick, color: Colors.white),
              ),
            )
                : const Icon(Icons.sick, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                disease.name,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
