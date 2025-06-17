import 'package:flutter/material.dart';
import 'package:plant_hub_app/features/booking/home/presentation/views/widgets/home_view_body.dart';
import '../../../../../core/utils/app_strings.dart';

class BookView extends StatelessWidget {
  const BookView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: Text(
          AppStrings.popularBooks,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      body: const BookViewBody(),
    );
  }
}
