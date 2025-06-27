import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/disease_info.dart';
import '../providers/diagnosis_provider.dart';
import '../providers/disease_provider.dart';
import 'diagnosis_error_screen.dart';
import 'diagnosis_healthy_screen.dart';
import 'diagnosis_result_screen.dart';
import 'disease_category_screen.dart';
import 'history_screen.dart';
import 'disease_detail_screen.dart';
import 'package:camera/camera.dart';
import 'camera_screen.dart';
import 'package:plant_hub_app/core/utils/size_config.dart';
class DiagnosisScreen extends StatefulWidget {
  const DiagnosisScreen({super.key});

  @override
  State<DiagnosisScreen> createState() => _DiagnosisScreenState();
}

class _DiagnosisScreenState extends State<DiagnosisScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DiseaseProvider>(context, listen: false).loadCommonDiseases();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: Text(
          'Diagnosis',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontSize: SizeConfig().responsiveFont(22),
          ),

        ),
        actions: [
          IconButton(
            icon: Icon(Icons.history, size: SizeConfig().responsiveFont(24)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<DiagnosisProvider>(
        builder: (context, diagnosisProvider, child) {
          if (diagnosisProvider.status == DiagnosisStatus.loading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: const Color(0xFF00A67E)),
                  SizedBox(height: SizeConfig().height(0.02)),
                  Text(
                    'Analyzing your plant...',
                    style: TextStyle(fontSize: SizeConfig().responsiveFont(16)),
                  ),
                ],
              ),
            );
          }

          WidgetsBinding.instance.addPostFrameCallback((_) {
            _navigateBasedOnResult(diagnosisProvider);
          });

          return RefreshIndicator(
            onRefresh: () async {
              await Provider.of<DiseaseProvider>(context, listen: false).loadCommonDiseases();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(SizeConfig().width(0.05)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: (query) {
                      DiseaseProvider().searchDiseases(query);
                    },
                    decoration: InputDecoration(
                      hintText: 'Search diseases...',
                      hintStyle: Theme.of(context).textTheme.bodySmall,
                      prefixIcon: Icon(Icons.search, color: Colors.grey, size: SizeConfig().responsiveFont(24)),
                      filled: true,
                      fillColor: Colors.grey.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(SizeConfig().width(0.075)),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: SizeConfig().height(0.00625),
                        horizontal: SizeConfig().width(0.025),
                      ),
                    ),
                    style: TextStyle(fontSize: SizeConfig().responsiveFont(14)),
                  ),
                  SizedBox(height: SizeConfig().height(0.025)),

                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(SizeConfig().width(0.05)),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(SizeConfig().width(0.04)),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: SizeConfig().width(0.25),
                          height: SizeConfig().width(0.2),
                          child: Image.asset(
                            'assets/images/icon_diagnosis.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: SizeConfig().width(0.25),
                              height: SizeConfig().width(0.25),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00A67E).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(SizeConfig().width(0.03)),
                              ),
                              child: Icon(
                                Icons.eco,
                                size: SizeConfig().responsiveFont(50),
                                color: const Color(0xFF00A67E),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(width: SizeConfig().width(0.05)),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Check Your Plant',
                                style: Theme.of(context).textTheme.bodyMedium
                              ),

                              SizedBox(height: SizeConfig().height(0.01)),
                              Text(
                                'Take photos, start diagnose diseases, & get plant care tips',
                                style: Theme.of(context).textTheme.titleSmall
                              ),

                              SizedBox(height: SizeConfig().height(0.02)),

                              ElevatedButton(
                                onPressed: () => _showCameraScreen(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00A67E),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(SizeConfig().width(0.0625)),
                                  ),
                                ),
                                child: Text(
                                  'Diagnose',
                                  style: TextStyle(
                                    fontSize: SizeConfig().responsiveFont(16),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: SizeConfig().height(0.04)),

                  Text(
                    'Common Diseases',
                    style: TextStyle(
                      fontSize: SizeConfig().responsiveFont(18),
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: SizeConfig().height(0.02)),

                  Consumer<DiseaseProvider>(
                    builder: (context, diseaseProvider, child) {
                      if (diseaseProvider.isLoading) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.all(SizeConfig().width(0.1)),
                            child: CircularProgressIndicator(color: const Color(0xFF00A67E)),
                          ),
                        );
                      }

                      if (diseaseProvider.errorMessage.isNotEmpty) {
                        return Center(
                          child: Column(
                            children: [
                              Icon(Icons.error_outline, size: SizeConfig().responsiveFont(48), color: Colors.red),
                              SizedBox(height: SizeConfig().height(0.01)),
                              Text(
                                'Failed to load diseases',
                                style: TextStyle(color: Colors.red, fontSize: SizeConfig().responsiveFont(16)),
                              ),
                              SizedBox(height: SizeConfig().height(0.01)),
                              ElevatedButton(
                                onPressed: () => diseaseProvider.loadCommonDiseases(),
                                child: Text('Retry', style: TextStyle(fontSize: SizeConfig().responsiveFont(16))),
                              ),
                            ],
                          ),
                        );
                      }

                      if (diseaseProvider.commonDiseases.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.all(SizeConfig().width(0.1)),
                            child: Text(
                              'No diseases found',
                              style: TextStyle(color: Colors.grey, fontSize: SizeConfig().responsiveFont(16)),
                            ),
                          ),
                        );
                      }

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: SizeConfig().width(0.03),
                          mainAxisSpacing: SizeConfig().height(0.015),
                          childAspectRatio: 0.75, //
                        ),
                        itemCount: diseaseProvider.commonDiseases.length,
                        itemBuilder: (context, index) {
                          final disease = diseaseProvider.commonDiseases[index];
                          return _buildDiseaseCard(disease);
                        },
                      );
                    },
                  ),
                  if (diagnosisProvider.status == DiagnosisStatus.error) ...[
                    SizedBox(height: SizeConfig().height(0.02)),
                    Container(
                      padding: EdgeInsets.all(SizeConfig().width(0.03)),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(SizeConfig().width(0.02)),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red, size: SizeConfig().responsiveFont(24)),
                          SizedBox(width: SizeConfig().width(0.02)),
                          Expanded(
                            child: Text(
                              diagnosisProvider.errorMessage,
                              style: TextStyle(color: Colors.red.shade700, fontSize: SizeConfig().responsiveFont(14)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDiseaseCard(DiseaseModel disease) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DiseaseDetailScreen(
              diseaseId: disease.id,
              diseaseName: disease.name,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SizeConfig().width(0.03)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: SizeConfig().width(0.0025),
              blurRadius: SizeConfig().width(0.01),
              offset: Offset(0, SizeConfig().height(0.0025)),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Disease image
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(SizeConfig().width(0.03)),bottom: Radius.circular(SizeConfig().width(0.03)),),
                child: Image.network(
                  disease.image,
                  width: double.infinity,
                  height: SizeConfig().height(0.25),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: double.infinity,
                    color: Colors.grey.shade200,
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.grey,
                      size: SizeConfig().responsiveFont(30),
                    ),
                  ),
                ),
              ),
            ),

            Container(
              height: SizeConfig().height(0.075),
              padding: EdgeInsets.all(SizeConfig().width(0.02)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      disease.name,
                      style: TextStyle(
                        fontSize: SizeConfig().responsiveFont(12),
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(height: SizeConfig().height(0.0025)),
                  Flexible(
                    child: Text(
                      disease.description,
                      style: TextStyle(
                        fontSize: SizeConfig().responsiveFont(10),
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CameraScreen(cameras: cameras),
        ),
      );

      if (result == true) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const DiagnosisSuccessScreen(),
          ),
        );
      }
    } catch (e) {
      _showErrorSnackBar('Error accessing camera: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(fontSize: SizeConfig().responsiveFont(14))),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _navigateBasedOnResult(DiagnosisProvider provider) {
    switch (provider.status) {
      case DiagnosisStatus.noPlant:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DiagnosisErrorScreen()),
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
