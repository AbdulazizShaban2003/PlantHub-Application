import 'package:flutter/material.dart';

import '../views/category_plant_view.dart';

Widget buildCategoryCard({
  required BuildContext context,
  required String title,
  required String imagePath,
  required String category,
}) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CategoryPlantsView(category: category),
        ),
      );
    },
    child: Container(
      decoration: BoxDecoration(

        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 10,),
          Image.asset(
            imagePath,
            height: 60,
            width: 65,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style:  TextStyle(
              fontSize: 13,
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ),
  );
}