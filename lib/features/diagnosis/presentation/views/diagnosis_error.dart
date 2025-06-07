import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:plant_hub_app/core/utils/size_config.dart';
import 'package:plant_hub_app/core/widgets/outlined_button_widget.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: GestureDetector(
                  onTap: () {},
                  child: const Icon(Icons.close, size: 24),
                ),
              ),
            ),
            SizedBox(
                width: SizeConfig().width(0.8),
                height: SizeConfig().height(0.4),

                child: Image(image: AssetImage("assets/images/image_error.png"))),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "We're sorry!",
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "We cannot identify your plant. Try the photo again from a different angle.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),

            // Try Again button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButtonWidget(
                  nameButton: "Try Again",
                  onPressed: () {},
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
