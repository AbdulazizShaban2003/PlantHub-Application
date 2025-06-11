import 'package:flutter/material.dart';

import '../../../../core/utils/size_config.dart';

class BuildBasicInfoWidget extends StatelessWidget {
  const BuildBasicInfoWidget({super.key, required this.nameController, required this.categoryController, required this.descriptionController});
  final TextEditingController nameController ;
  final TextEditingController categoryController ;
  final  TextEditingController descriptionController ;
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.all(SizeConfig().width(0.04)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Basic Information',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontSize: SizeConfig().responsiveFont(15)
                )
            ),
            SizedBox(height: SizeConfig().height(0.04)),
            TextFormField(
              controller: nameController,
              minLines: 1,
              maxLines: null,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondary,
                fontSize: SizeConfig().responsiveFont(14),
              ),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                hintText: 'Plant Name',

              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter plant name';
                }
                return null;
              },
            ),
            SizedBox(height: SizeConfig().height(0.02)),
            TextFormField(
              controller: categoryController,
              minLines: 1,
              maxLines: null,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondary,
                fontSize: SizeConfig().responsiveFont(14),
              ),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                hintText: 'Category',

              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter category';
                }
                return null;
              },
            ),
            SizedBox(height: SizeConfig().height(0.02)),
            TextFormField(
              controller: descriptionController,
              minLines: 1,
              maxLines: null,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondary,
                fontSize: SizeConfig().responsiveFont(14),
              ),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                hintText: 'Description',

              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter description';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}
