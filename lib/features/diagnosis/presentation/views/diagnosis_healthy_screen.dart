import 'package:flutter/material.dart';
import 'dart:io';
import '../../data/plant_diagnosis_response_model.dart';
import 'package:plant_hub_app/core/utils/size_config.dart';

class DiagnosisHealthyScreen extends StatelessWidget {
  final String imagePath;
  final PlantDiagnosisResponse response;

  const DiagnosisHealthyScreen({
    super.key,
    required this.imagePath,
    required this.response,
  });

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Diagnosis Results',
          style: TextStyle(fontSize: SizeConfig().responsiveFont(20)),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(SizeConfig().width(0.05)),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(SizeConfig().width(0.04)),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(SizeConfig().width(0.03)),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: SizeConfig().responsiveFont(24),
                    ),
                    SizedBox(width: SizeConfig().width(0.03)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Plant is Healthy',
                            style: TextStyle(
                              fontSize: SizeConfig().responsiveFont(16),
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                          SizedBox(height: SizeConfig().height(0.005)),
                          Text(
                            'Your plant looks healthy and well-maintained',
                            style: TextStyle(
                              fontSize: SizeConfig().responsiveFont(14),
                              color: Colors.green.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: SizeConfig().height(0.03)),
              Container(
                width: SizeConfig().width(0.3),
                height: SizeConfig().width(0.3),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: SizeConfig().responsiveFont(80),
                ),
              ),

              SizedBox(height: SizeConfig().height(0.025)),

              Text(
                'Your plant looks healthy!',
                style: TextStyle(
                  fontSize: SizeConfig().responsiveFont(24),
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: SizeConfig().height(0.01875)),

              ClipRRect(
                borderRadius: BorderRadius.circular(SizeConfig().width(0.04)),
                child: Container(
                  height: SizeConfig().height(0.3125),
                  width: double.infinity,
                  child: Image.file(File(imagePath), fit: BoxFit.cover),
                ),
              ),

              SizedBox(height: SizeConfig().height(0.03)),

              if (response.data.care.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(SizeConfig().width(0.04)),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(
                      SizeConfig().width(0.03),
                    ),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.tips_and_updates,
                            color: Color(0xFF00A67E),
                            size: SizeConfig().responsiveFont(24),
                          ),
                          SizedBox(width: SizeConfig().width(0.02)),
                          Text(
                            'Care Tips',
                            style: TextStyle(
                              fontSize: SizeConfig().responsiveFont(18),
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: SizeConfig().height(0.015)),
                      Text(
                        response.data.care,
                        style: TextStyle(
                          fontSize: SizeConfig().responsiveFont(16),
                          color: Colors.grey.shade700,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: SizeConfig().height(0.03)),
              ] else ...[
                Text(
                  'Keep taking good care of your plant! Continue with regular watering, proper lighting, and monitoring for any changes.',
                  style: TextStyle(
                    fontSize: SizeConfig().responsiveFont(16),
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: SizeConfig().height(0.03)),
              ],

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF00A67E),
                    padding: EdgeInsets.symmetric(
                      vertical: SizeConfig().height(0.02),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        SizeConfig().width(0.0625),
                      ),
                    ),
                  ),
                  child: Text(
                    'Diagnose Another Plant',
                    style: TextStyle(
                      fontSize: SizeConfig().responsiveFont(16),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
