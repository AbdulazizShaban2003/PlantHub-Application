import 'package:flutter/material.dart';
import 'package:plant_hub_app/config/theme/app_colors.dart';
import 'package:plant_hub_app/core/utils/app_strings.dart';
import 'package:plant_hub_app/core/utils/size_config.dart';

import '../../data/models/disease_model.dart';
import '../sections/custom_image_gallery.dart';
import '../sections/info_row_section.dart';

class DiseaseCard extends StatelessWidget {
  final Disease disease;

  const DiseaseCard({super.key, required this.disease});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: ColorsManager.whiteColor,
      margin:  EdgeInsets.only(bottom: SizeConfig().height(0.02)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppKeyStringTr.name,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: ColorsManager.blackColor,
              ),
            ),
            SizedBox(height: SizeConfig().height(0.015)),
            Text(disease.name, style:Theme.of(context).textTheme.bodySmall?.copyWith(
              color: ColorsManager.blackColor,
              fontSize: SizeConfig().responsiveFont(14),
            )),
             SizedBox(height: SizeConfig().height(0.01)),
            if (disease.image.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  disease.image,
                  height: SizeConfig().height(0.25),
                  width: double.infinity,
                  fit: BoxFit.fill,
                ),
              ),

            InfoRow(label: AppKeyStringTr.causedBy, value: disease.causedBy),
            InfoRow(label: AppKeyStringTr.symptoms, value: disease.symptoms),
            InfoRow(label: AppKeyStringTr.transmission, value: disease.transmission),
            ImageGallery(images: disease.listImage),
             SizedBox(height: SizeConfig().height(0.02)),
            Text(
              '${AppKeyStringTr.treatment} :',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: ColorsManager.blackColor,
              fontSize: SizeConfig().responsiveFont(17),
            ),
            ),
            SizedBox(height: SizeConfig().height(0.01)),
            ...disease.treatment.map(
                  (treatment) => Padding(
                padding:  EdgeInsets.symmetric(vertical: SizeConfig().height(0.005)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Icon(Icons.check, size: 16, color: ColorsManager.greenPrimaryColor),
                     SizedBox(width: SizeConfig().width(0.02)),
                    Expanded(child: Text(treatment,style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: ColorsManager.blackColor,
                      fontSize: SizeConfig().responsiveFont(10)
                    ))),
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
