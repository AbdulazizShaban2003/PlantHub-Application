import 'package:flutter/material.dart';
import 'package:plant_hub_app/config/theme/app_colors.dart';
import 'package:plant_hub_app/core/utils/asstes_manager.dart';
import 'package:plant_hub_app/core/utils/size_config.dart';
import 'package:plant_hub_app/core/widgets/outlined_button_widget.dart';

class DiagnosisResultsScreen extends StatelessWidget {
  const DiagnosisResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Diagnosis Results'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            children: [
              SizedBox(
                width: SizeConfig().width(0.4),
                height: SizeConfig().height(0.15),
                child: Image(image: AssetImage(AssetsManager.getStartedLogo)),
              ),
              SizedBox(height: 20),
              Text(
                'Your plant looks healthy!',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 15),
              Text(
                'No disease problems detected.',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              SizedBox(height: SizeConfig().height(0.06)),
              ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Image(
                  image: AssetImage("assets/images/testPhoto.jpg"),
                  height: SizeConfig().height(0.3),
                ),
              ),
              SizedBox(height: SizeConfig().height(0.06)),
              Spacer(),
              OutlinedButtonWidget(nameButton: 'Ask Experts', onPressed: () {}),
              SizedBox(height: SizeConfig().height(0.02)),
            ],
          ),
        ),
      ),
    );
  }
}
