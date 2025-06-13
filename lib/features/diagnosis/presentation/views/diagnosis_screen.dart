import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plant_hub_app/features/diagnosis/presentation/providers/disease_provider.dart';
import 'package:provider/provider.dart';
import '../widgets/build_icon_diagnose.dart';
import '../widgets/common_diseases_section.dart';
import 'diagnosis_error_screen.dart';
import 'diagnosis_result_screen.dart';
import 'diagnosis_healthy_screen.dart';
import '../providers/diagnosis_provider.dart';
import '../providers/history_provider.dart';
import 'history_screen.dart';

class DiagnoseScreen extends StatefulWidget {
  const DiagnoseScreen({super.key});

  @override
  State<DiagnoseScreen> createState() => _DiagnoseScreenState();
}

class _DiagnoseScreenState extends State<DiagnoseScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  Future<void> _onRefresh() async {
    Provider.of<DiagnosisProvider>(context, listen: false).resetDiagnosis();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<DiagnosisProvider>(
        builder: (context, diagnosisProvider, child) {
          final isLoading = diagnosisProvider.status == DiagnosisStatus.loading;

          return isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF00A67E)),
              )
              : RefreshIndicator(
                onRefresh: _onRefresh,
                child: NestedScrollView(
                  headerSliverBuilder:
                      (context, innerBoxIsScrolled) => [
                        SliverAppBar(
                          title: TitleAppBarDiagnose(),
                          actions: [
                            IconHistoryComponent(),

                          ],
                        ),
                      ],
                  body: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            style: Theme.of(context).textTheme.bodySmall,
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search diseases...',
                              prefixIcon: const Icon(
                                Icons.search,
                                color: Colors.grey,
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            onChanged: (query) {
                              Provider.of<DiseaseProvider>(
                                context,
                                listen: false,
                              ).searchDiseases(query);
                            },
                          ),
                          const SizedBox(height: 24),
                          BuildIconDiagnose(onPressed: _showImageSourceDialog),
                          SizedBox(height: 30),
                          CommonDiseasesSection(),
                        ],
                      ),
                    ),
                  ),
                ),
              );
        },
      ),
    );
  }
}

class IconHistoryComponent extends StatelessWidget {
  const IconHistoryComponent({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon:  Icon(
        Icons.history,
        color: Theme.of(context).primaryColor
      ),
      onPressed: () {
        Provider.of<HistoryProvider>(
          context,
          listen: false,
        ).loadHistory();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => HistoryView(),
          ),
        );
      },
    );
  }
}

class TitleAppBarDiagnose extends StatelessWidget {
  const TitleAppBarDiagnose({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          'assets/images/plant_icon.png',
          width: 24,
          height: 24,
          errorBuilder:
              (_, __, ___) => const Icon(
                Icons.eco,
                color: Color(0xFF00A67E),
              ),
        ),
        const SizedBox(width: 8),
        const Text(
          'Diagnose',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

