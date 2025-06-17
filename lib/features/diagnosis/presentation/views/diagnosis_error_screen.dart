import 'package:flutter/material.dart';
import 'package:plant_hub_app/core/utils/size_config.dart';

class DiagnosisErrorScreen extends StatelessWidget {
  const DiagnosisErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(SizeConfig().width(0.04)),
              child: Align(
                alignment: Alignment.topLeft,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Icon(Icons.close, size: SizeConfig().responsiveFont(24)),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Center(
                child: Image(image: AssetImage("assets/images/image_error.png")),
              ),
            ),

            Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: SizeConfig().width(0.06)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                        "We're sorry!",
                        style: Theme.of(context).textTheme.headlineMedium
                    ),
                    SizedBox(height: SizeConfig().height(0.01)),
                    Text(
                        "We cannot identify your plant. Please make sure the image contains a clear view of a plant and try again from a different angle.",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleSmall
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              // Responsive padding
              padding: EdgeInsets.all(SizeConfig().width(0.06)),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF00A67E),
                        // Responsive padding
                        padding: EdgeInsets.symmetric(vertical: SizeConfig().height(0.01625)),
                        shape: RoundedRectangleBorder(
                          // Responsive border radius
                          borderRadius: BorderRadius.circular(SizeConfig().width(0.0625)),
                        ),
                      ),
                      child: Text(
                        "Try Again",
                        style: TextStyle(
                          fontSize: SizeConfig().responsiveFont(16),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: SizeConfig().height(0.015)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
