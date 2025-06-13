import 'package:flutter/material.dart';
import 'package:plant_hub_app/core/widgets/outlined_button_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class HarvestGuideWidget extends StatelessWidget {
  final String websiteUrl =
      "https://yourfarm.com/harvest"; // Replace with your URL

  const HarvestGuideWidget({super.key});

  Future<void> _openHarvestPage() async {
    if (await canLaunchUrl(Uri.parse(websiteUrl))) {
      await launchUrl(Uri.parse(websiteUrl));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Plant Harvest Status',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),

            // Explanation Card
            Card(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(
                      Icons.help_outline,
                      size: 40,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'About This Link:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'You\'ll be redirected to our official harvest tracking page '
                      'to see real-time updates about your plants.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Website: $websiteUrl',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            OutlinedButtonWidget(
              nameButton: 'Open Harvest TRACKING PAGE',
              onPressed: _openHarvestPage,
            ),
          ],
        ),
      ),
    );
  }
}
