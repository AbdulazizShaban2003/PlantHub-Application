import 'package:flutter/material.dart';

import '../../data/models/disease_model.dart';
import '../sections/custom_image_gallery.dart';
import '../sections/info_row_section.dart';

class DiseaseCard extends StatelessWidget {
  final Disease disease;

  const DiseaseCard({super.key, required this.disease});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(disease.name, style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold
            )),
            const SizedBox(height: 8),

            if (disease.image.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  disease.image,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

            InfoRow(label: 'Caused by', value: disease.causedBy),
            InfoRow(label: 'Symptoms', value: disease.symptoms),
            InfoRow(label: 'Transmission', value: disease.transmission),
            ImageGallery(images: disease.listImage),
            const SizedBox(height: 8),
            Text(
              'Treatment:',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold
              ),
            ),
            ...disease.treatment.map(
                  (treatment) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check, size: 16, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(child: Text(treatment,style: TextStyle(fontSize: 15,color: Colors.black),)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
