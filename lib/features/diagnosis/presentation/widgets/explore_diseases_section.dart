import 'package:flutter/material.dart';
import '../views/disease_category_screen.dart';
class ExploreDiseasesSection extends StatelessWidget {
  const ExploreDiseasesSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categories = [
      {
        'title': 'Diseases of the Whole Plant',
        'image': 'assets/images/whole_plant.jpg',
      },
      {
        'title': 'Diseases in Leaves',
        'image': 'assets/images/leaves.jpg',
      },
      {
        'title': 'Diseases in Flowers',
        'image': 'assets/images/flowers.jpg',
      },
      {
        'title': 'Diseases in Fruits',
        'image': 'assets/images/fruits.jpg',
      },
      {
        'title': 'Diseases in Stems',
        'image': 'assets/images/stems.jpg',
      },
      {
        'title': 'Diseases in Roots',
        'image': 'assets/images/roots.jpg',
      },
      {
        'title': 'Diseases Caused by Pests',
        'image': 'assets/images/pests.jpg',
      },
      {
        'title': 'Diseases Caused by Soil',
        'image': 'assets/images/soil.jpg',
      },
    ];

    return SingleChildScrollView(
      child: Column(
        children: [
          // Header - تم تعديل هذا الجزء
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Explore Diseases',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(  // تم إضافة SizedBox هنا
                  height: 36, // ارتفاع مناسب
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero, // إزالة الحشو الداخلي
                    ),
                    onPressed: () {
                      // Navigate to all categories
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min, // مهم لمنع التمدد الأفقي
                      children: [
                        Text(
                          'View All',
                          style: TextStyle(
                            color: Color(0xFF00A67E),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 4), // مسافة صغيرة بين النص والأيقونة
                        Icon(
                          Icons.arrow_forward,
                          size: 16,
                          color: Color(0xFF00A67E),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            height: 300,
            child: GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.5,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return _buildCategoryItem(context, category);
              },
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildCategoryItem(BuildContext context, Map<String, String> category) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DiseaseCategoryScreen(
              categoryName: category['title']!,
            ),
          ),
        );
      },
      child: Stack(
        children: [
          // Background Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              category['image']!,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          
          // Overlay
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),
          
          // Category Title
          Positioned(
            bottom: 12,
            left: 12,
            right: 12,
            child: Text(
              category['title']!,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
