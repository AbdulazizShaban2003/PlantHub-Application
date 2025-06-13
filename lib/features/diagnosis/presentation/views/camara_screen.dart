import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../providers/diagnosis_provider.dart';
import '../widgets/build_icon_diagnose.dart';
import 'diagnosis_error_screen.dart';
import 'diagnosis_healthy_screen.dart' show DiagnosisHealthyScreen;
import 'diagnosis_result_screen.dart' show DiagnosisResultScreen;

class CamaraDiagnoseView extends StatefulWidget {
  const CamaraDiagnoseView({super.key});

  @override
  State<CamaraDiagnoseView> createState() => _CamaraDiagnoseViewState();
}

class _CamaraDiagnoseViewState extends State<CamaraDiagnoseView> {
  @override
  Widget build(BuildContext context) {
    return BuildIconDiagnose(onPressed: _showImageSourceDialog);
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        final diagnosisProvider = Provider.of<DiagnosisProvider>(
          context,
          listen: false,
        );
        await diagnosisProvider.processImage(image.path);
        _navigateBasedOnDiagnosisResult();
      }
    } catch (e) {
      _showErrorSnackBar('Error picking image: $e');
    }
  }

  void _navigateBasedOnDiagnosisResult() {
    final diagnosisProvider = Provider.of<DiagnosisProvider>(
      context,
      listen: false,
    );

    switch (diagnosisProvider.status) {
      case DiagnosisStatus.noPlant:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DiagnosisErrorScreen()),
        );
        break;

      case DiagnosisStatus.healthy:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => DiagnosisHealthyScreen(
                  imagePath: diagnosisProvider.imagePath,
                  apiResponse: null,
                ),
          ),
        );
        break;

      case DiagnosisStatus.diseased:
        if (diagnosisProvider.detectedDisease != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => DiagnosisResultScreen(
                    imagePath: diagnosisProvider.imagePath,
                    diseaseData: diagnosisProvider.detectedDisease!,
                  ),
            ),
          );
        }
        break;

      case DiagnosisStatus.error:
        _showErrorSnackBar(diagnosisProvider.errorMessage);
        break;

      default:
        break;
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Select Image Source',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildImageSourceOption(
                      icon: Icons.camera_alt,
                      label: 'Camera',
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.camera);
                      },
                    ),
                    _buildImageSourceOption(
                      icon: Icons.photo_library,
                      label: 'Gallery',
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.gallery);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF00A67E).withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: const Color(0xFF00A67E), size: 30),
          ),
          const SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }
}
