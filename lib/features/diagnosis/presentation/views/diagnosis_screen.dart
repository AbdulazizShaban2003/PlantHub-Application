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
        centerTitle: true,
        title: Text('Diagnosis',style: Theme.of(context).textTheme.headlineMedium,),
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

          return RefreshIndicator(
            onRefresh: () async {
              await Provider.of<DiseaseProvider>(context, listen: false).loadCommonDiseases();
            },
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(20),
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
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 5,
                        horizontal: 10,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  Container(
                    width: double.infinity,

                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,

                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 100,
                          height: 100,
                          child: Image.asset(
                            'assets/images/icon_diagnosis.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Color(0xFF00A67E).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.eco,
                                size: 50,
                                color: Color(0xFF00A67E),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(width: 20),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Check Your Plant',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),

                              SizedBox(height: 8),

                              Text(
                                'Take photos, start diagnose diseases, & get plant care tips',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  height: 1.4,
                                ),
                              ),

                              SizedBox(height: 16),

                              ElevatedButton(
                                onPressed: () => _showCameraScreen(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF00A67E),
                                  padding: EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                child: Text(
                                  'Diagnose',
                                  style: TextStyle(
                                    fontSize: 16,
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

                  SizedBox(height: 32),


                  Text(
                    'Common Diseases',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 16),

                  // Disease cards
                  Consumer<DiseaseProvider>(
                    builder: (context, diseaseProvider, child) {
                      if (diseaseProvider.isLoading) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.all(40),
                            child: CircularProgressIndicator(color: Color(0xFF00A67E)),
                          ),
                        );
                      }

                      if (diseaseProvider.errorMessage.isNotEmpty) {
                        return Center(
                          child: Column(
                            children: [
                              Icon(Icons.error_outline, size: 48, color: Colors.red),
                              SizedBox(height: 8),
                              Text(
                                'Failed to load diseases',
                                style: TextStyle(color: Colors.red),
                              ),
                              SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () => diseaseProvider.loadCommonDiseases(),
                                child: Text('Retry'),
                              ),
                            ],
                          ),
                        );
                      }

                      if (diseaseProvider.commonDiseases.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.all(40),
                            child: Text(
                              'No diseases found',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        );
                      }

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: diseaseProvider.commonDiseases.length,
                        itemBuilder: (context, index) {
                          final disease = diseaseProvider.commonDiseases[index];
                          return _buildDiseaseCard(disease);
                        },
                      );
                    },
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: Offset(0, 2),
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
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  disease.image,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: double.infinity,
                    color: Colors.grey.shade200,
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.grey,
                      size: 30,
                    ),
                  ),
                ),
              ),
            ),

            // Disease info - Fixed height to prevent overflow
            Container(
              height: 60,
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      disease.name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(height: 2),
                  Flexible(
                    child: Text(
                      disease.description,
                      style: TextStyle(
                        fontSize: 10,
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
            builder: (context) => DiagnosisSuccessScreen(),
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
