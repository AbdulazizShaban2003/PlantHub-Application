import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/diagnosis_provider.dart';
import '../providers/history_provider.dart';
import 'diagnosis_error_screen.dart';
import 'diagnosis_healthy_screen.dart';
import 'diagnosis_result_screen.dart';
import 'history_screen.dart';
import 'package:camera/camera.dart';
import 'camera_screen.dart';

class DiagnosisScreen extends StatefulWidget {
  const DiagnosisScreen({super.key});

  @override
  State<DiagnosisScreen> createState() => _DiagnosisScreenState();
}

class _DiagnosisScreenState extends State<DiagnosisScreen> {
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.eco, color: Color(0xFF00A67E)),
            SizedBox(width: 8),
            Text('Plant Diagnosis'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => HistoryScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<DiagnosisProvider>(
        builder: (context, diagnosisProvider, child) {
          // Show loading if processing
          if (diagnosisProvider.status == DiagnosisStatus.loading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF00A67E)),
                  SizedBox(height: 16),
                  Text('Analyzing your plant...'),
                ],
              ),
            );
          }

          // Navigate based on diagnosis result
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _navigateBasedOnResult(diagnosisProvider);
          });

          return Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Plant icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Color(0xFF00A67E).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.eco,
                    size: 60,
                    color: Color(0xFF00A67E),
                  ),
                ),

                SizedBox(height: 32),

                Text(
                  'Diagnose Your Plant',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 16),

                Text(
                  'Take a photo or select from gallery to diagnose plant diseases',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),

                SizedBox(height: 48),

                // Diagnose button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _showCameraScreen(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF00A67E),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      'Diagnose',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                // Show error message if any
                if (diagnosisProvider.status == DiagnosisStatus.error) ...[
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            diagnosisProvider.errorMessage,
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _showCameraScreen() async {
    try {
      // Get available cameras
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        _showErrorSnackBar('No cameras available on this device');
        return;
      }

      // Navigate to camera screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CameraScreen(cameras: cameras),
        ),
      );
    } catch (e) {
      _showErrorSnackBar('Error accessing camera: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _navigateBasedOnResult(DiagnosisProvider provider) {
    switch (provider.status) {
      case DiagnosisStatus.noPlant:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => DiagnosisErrorScreen()),
        );
        break;
      case DiagnosisStatus.healthy:
        if (provider.diagnosisResponse != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => DiagnosisHealthyScreen(
                imagePath: provider.imagePath,
                response: provider.diagnosisResponse!,
              ),
            ),
          );
        }
        break;
      case DiagnosisStatus.diseased:
        if (provider.diagnosisResponse != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => DiagnosisResultScreen(
                imagePath: provider.imagePath,
                response: provider.diagnosisResponse!,
              ),
            ),
          );
        }
        break;
      default:
        break;
    }
  }
}
