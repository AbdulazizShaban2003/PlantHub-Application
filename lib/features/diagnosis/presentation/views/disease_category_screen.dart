import 'package:flutter/material.dart';
import 'package:plant_hub_app/core/utils/size_config.dart';

class DiagnosisSuccessScreen extends StatelessWidget {
  const DiagnosisSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(SizeConfig().width(0.05)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: SizeConfig().width(0.3),
                height: SizeConfig().width(0.3),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  size: SizeConfig().responsiveFont(80),
                  color: Colors.green,
                ),
              ),

              SizedBox(height: SizeConfig().height(0.04)),

              Text(
                'Image Sent Successfully!',
                style: TextStyle(
                  fontSize: SizeConfig().responsiveFont(24),
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: SizeConfig().height(0.02)),

              Text(
                'Your plant image has been successfully submitted for diagnosis. We are analyzing it now.',
                style: TextStyle(
                  fontSize: SizeConfig().responsiveFont(16),
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: SizeConfig().height(0.06)),

              Container(
                padding: EdgeInsets.all(SizeConfig().width(0.05)),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(SizeConfig().width(0.03)),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    _buildProcessStep(
                      icon: Icons.upload_file,
                      title: 'Image Uploaded',
                      subtitle: 'Your image has been received',
                      isCompleted: true, context: context,
                    ),
                    SizedBox(height: SizeConfig().height(0.02)),
                    _buildProcessStep(
                      icon: Icons.analytics,
                      title: 'AI Analysis',
                      subtitle: 'Our AI is analyzing your plant',
                      isCompleted: false,
                      isActive: true, context: context,
                    ),
                    SizedBox(height: SizeConfig().height(0.02)),
                    _buildProcessStep(
                      icon: Icons.assignment,
                      title: 'Results Ready',
                      subtitle: 'Diagnosis results will be available soon',
                      isCompleted: false, context: context,
                    ),
                  ],
                ),
              ),

              SizedBox(height: SizeConfig().height(0.06)),

              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00A67E),
                        padding: EdgeInsets.symmetric(vertical: SizeConfig().height(0.02)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(SizeConfig().width(0.0625)),
                        ),
                      ),
                      child: Text(
                        'Back to Home',
                        style: TextStyle(
                          fontSize: SizeConfig().responsiveFont(16),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: SizeConfig().height(0.015)),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: const Color(0xFF00A67E)),
                        padding: EdgeInsets.symmetric(vertical: SizeConfig().height(0.02)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(SizeConfig().width(0.0625)),
                        ),
                      ),
                      child: Text(
                        'Diagnose Another Plant',
                        style: TextStyle(
                          fontSize: SizeConfig().responsiveFont(16),
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF00A67E),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProcessStep({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isCompleted,
    bool isActive = false,
  }) {
    SizeConfig().init(context);

    Color iconColor;
    Color backgroundColor;

    if (isCompleted) {
      iconColor = Colors.green;
      backgroundColor = Colors.green.withOpacity(0.1);
    } else if (isActive) {
      iconColor = const Color(0xFF00A67E); // Keep const
      backgroundColor = const Color(0xFF00A67E).withOpacity(0.1);
    } else {
      iconColor = Colors.grey;
      backgroundColor = Colors.grey.withOpacity(0.1);
    }

    return Row(
      children: [
        Container(
          width: SizeConfig().width(0.12),
          height: SizeConfig().width(0.12),
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isCompleted ? Icons.check : icon,
            color: iconColor,
            size: SizeConfig().responsiveFont(24),
          ),
        ),
        SizedBox(width: SizeConfig().width(0.04)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: SizeConfig().responsiveFont(16),
                  fontWeight: FontWeight.bold,
                  color: isCompleted || isActive ? Colors.black : Colors.grey,
                ),
              ),
              SizedBox(height: SizeConfig().height(0.005)),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: SizeConfig().responsiveFont(14),
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),

        if (isActive)
          SizedBox(
            width: SizeConfig().width(0.05),
            height: SizeConfig().width(0.05),
            child: CircularProgressIndicator(
              strokeWidth: SizeConfig().width(0.005),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00A67E)),
            ),
          ),
      ],
    );
  }
}
