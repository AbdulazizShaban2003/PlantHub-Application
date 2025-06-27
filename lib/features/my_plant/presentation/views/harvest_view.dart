import 'package:flutter/material.dart';
import 'package:plant_hub_app/config/theme/app_colors.dart';
import 'package:plant_hub_app/core/utils/size_config.dart';
import 'package:url_launcher/url_launcher.dart';

class HarvestView extends StatelessWidget {
  const HarvestView({super.key});

  @override
  Widget build(BuildContext context) {
    return  SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,

          borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE5CC),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Icon(
                      Icons.agriculture,
                      size: 40,
                      color: Color(0xFFFF8C42),
                    ),
                  ),
                  const SizedBox(height: 16),
                   Text(
                    'Harvest Checker',
                    style: Theme.of(context).textTheme.bodyLarge
                  ),
                  const SizedBox(height: 8),
                   Text(
                    'Determine the perfect harvest timing',
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: ColorsManager.greyColor
                      )

                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Main Description
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child:  Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What is Harvest Checker?',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontSize: SizeConfig().responsiveFont(20)
                    )
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Harvest Checker is an advanced intelligent system that helps farmers determine the optimal time to harvest their crops. The system uses artificial intelligence and image analysis to examine fruit and vegetable ripeness, ensuring the best quality and highest nutritional value.',
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: ColorsManager.greyColor
                      )
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

             Text(
              'Key Features',
              style:Theme.of(context).textTheme.headlineSmall
            ),
            const SizedBox(height: 16),

            // Feature Cards
            _buildFeatureCard(
              icon: Icons.schedule,
              title: 'Precise Timing',
              description: 'Determine optimal harvest time with high accuracy using advanced algorithms',
              color: const Color(0xFF4CAF50), context: context,
            ),

            const SizedBox(height: 12),

            _buildFeatureCard(
              icon: Icons.camera_alt,
              title: 'Visual Analysis',
              description: 'Examine crops visually to assess ripeness, color, and size',
              color: const Color(0xFF2196F3),
              context: context,
            ),

            const SizedBox(height: 12),

            _buildFeatureCard(
              icon: Icons.trending_up,
              title: 'Boost Productivity',
              description: 'Improve crop quality and increase yield through timely harvesting',
              color: const Color(0xFFFF9800),
              context: context,
            ),

            const SizedBox(height: 24),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF2D5A3D).withOpacity(0.1),
                    const Color(0xFF4CAF50).withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    'How It Works',
                    style: Theme.of(context).textTheme.bodyLarge
                  ),
                  const SizedBox(height: 16),
                  _buildStep('1', 'Capture Image', 'Use camera to take a clear photo of fruits or vegetables',context),
                  _buildStep('2', 'Smart Analysis', 'System analyzes image and examines ripeness indicators',context),
                  _buildStep('3', 'Results & Recommendations', 'Get detailed report and harvest recommendations',context),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Action Button - Fixed overflow issue
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => _launchURL('https://www-e.github.io/nav/'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorsManager.greenPrimaryColor,
                  padding: EdgeInsets.symmetric(vertical: SizeConfig().height(0.01)),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child:  Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, size: 24),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Check Readiness',
                        style: TextStyle(
                          fontSize: SizeConfig().responsiveFont(18),
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            const Center(
              child: Text(
                '© 2025 PlantHub. Empowering smart agriculture',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                ),
              ),
            ),
            const SizedBox(height: 100),

          ],
        ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
   required  BuildContext context,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(String number, String title, String description,BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                number,
                style:  TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }
}