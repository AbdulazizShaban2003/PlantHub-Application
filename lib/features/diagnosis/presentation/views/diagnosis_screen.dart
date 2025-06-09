import 'package:flutter/material.dart';
import 'dart:io';

class DiagnosisScreen extends StatefulWidget {
  final String imagePath;
  final dynamic apiResponse;

  const DiagnosisScreen({
    Key? key,
    required this.imagePath,
    required this.apiResponse,
  }) : super(key: key);

  @override
  _DiagnosisScreenState createState() => _DiagnosisScreenState();
}

class _DiagnosisScreenState extends State<DiagnosisScreen> {
  late Map<String, dynamic> diagnosisData;
  List<DiseaseInfo> diseases = [];

  @override
  void initState() {
    super.initState();
    _processDiagnosisData();
  }

  void _processDiagnosisData() {
    // Process API response to extract disease information
    if (widget.apiResponse is Map<String, dynamic>) {
      diagnosisData = widget.apiResponse as Map<String, dynamic>;
    } else {
      diagnosisData = {'result': widget.apiResponse.toString()};
    }

    // Extract diseases from response
    _extractDiseases();
  }

  void _extractDiseases() {
    diseases.clear();

    // Check if response contains specific disease information
    if (diagnosisData.containsKey('diseases')) {
      List<dynamic> diseaseList = diagnosisData['diseases'];
      for (var disease in diseaseList) {
        diseases.add(DiseaseInfo.fromJson(disease));
      }
    } else if (diagnosisData.containsKey('predictions')) {
      List<dynamic> predictions = diagnosisData['predictions'];
      for (var prediction in predictions) {
        diseases.add(DiseaseInfo.fromPrediction(prediction));
      }
    } else {
      // Create default disease info from result
      String result = diagnosisData['result']?.toString() ?? 'Unknown disease detected';
      diseases.add(DiseaseInfo(
        name: _extractDiseaseName(result),
        description: _getDescriptionForDisease(result),
        confidence: _extractConfidence(result),
        category: _categorizeDisease(result),
        isHighlighted: true,
      ));
    }

    // Sort by confidence if available
    diseases.sort((a, b) => (b.confidence ?? 0.0).compareTo(a.confidence ?? 0.0));
  }

  String _extractDiseaseName(String result) {
    // Extract disease name from result string
    if (result.toLowerCase().contains('blight')) return 'Blight Disease';
    if (result.toLowerCase().contains('rust')) return 'Rust Disease';
    if (result.toLowerCase().contains('spot')) return 'Leaf Spot Disease';
    if (result.toLowerCase().contains('mildew')) return 'Mildew Disease';
    if (result.toLowerCase().contains('fungal')) return 'Fungal Disease';
    if (result.toLowerCase().contains('bacterial')) return 'Bacterial Disease';
    if (result.toLowerCase().contains('viral')) return 'Viral Disease';
    return 'Plant Disease Detected';
  }

  String _getDescriptionForDisease(String result) {
    String diseaseName = _extractDiseaseName(result).toLowerCase();

    if (diseaseName.contains('blight')) {
      return 'Blight diseases cause rapid browning and death of plant tissues. Common in humid conditions.';
    } else if (diseaseName.contains('rust')) {
      return 'Rust diseases appear as orange or reddish spots on leaves, caused by fungal infections.';
    } else if (diseaseName.contains('spot')) {
      return 'Leaf spot diseases cause circular or irregular spots on leaves, often with distinct borders.';
    } else if (diseaseName.contains('mildew')) {
      return 'Mildew appears as white powdery growth on plant surfaces, thriving in humid conditions.';
    } else if (diseaseName.contains('fungal')) {
      return 'Fungal diseases are among the most common plant diseases, causing various symptoms.';
    } else if (diseaseName.contains('bacterial')) {
      return 'Bacterial diseases often cause water-soaked lesions and can spread rapidly in warm, moist conditions.';
    } else if (diseaseName.contains('viral')) {
      return 'Viral diseases cause mosaic patterns, stunting, and distorted growth in plants.';
    }

    return 'A plant disease has been detected. Consult with experts for proper treatment.';
  }

  double? _extractConfidence(String result) {
    // Try to extract confidence percentage from result
    RegExp regex = RegExp(r'(\d+(?:\.\d+)?)%');
    Match? match = regex.firstMatch(result);
    if (match != null) {
      return double.tryParse(match.group(1)!);
    }
    return null;
  }

  String _categorizeDisease(String result) {
    if (result.toLowerCase().contains('fungal') || result.toLowerCase().contains('fungi')) {
      return 'Fungi';
    } else if (result.toLowerCase().contains('bacterial') || result.toLowerCase().contains('bacteria')) {
      return 'Bacteria';
    } else if (result.toLowerCase().contains('viral') || result.toLowerCase().contains('virus')) {
      return 'Virus';
    } else if (result.toLowerCase().contains('abiotic') || result.toLowerCase().contains('environmental')) {
      return 'Abiotic';
    }
    return 'Unknown';
  }

  void _navigateToChat(String diseaseName) {
    // Navigate to chat with disease-specific information
    // Implementation depends on your chat system
    print('Navigate to chat for: $diseaseName');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Diagnosis Results',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Plant image with problem indicators
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: FileImage(File(widget.imagePath)),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: _buildProblemIndicators(),
                ),
              ),

              SizedBox(height: 24),

              if (diagnosisData.isNotEmpty) ...[
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Analysis Result:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        diagnosisData.toString(),
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
              ],


              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildProblemIndicators() {
    // Build red circles to highlight problem areas
    return [
      Positioned(
        top: 40,
        right: 80,
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.red, width: 2),
          ),
        ),
      ),
      Positioned(
        top: 100,
        right: 50,
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.red, width: 2),
          ),
        ),
      ),
      Positioned(
        top: 150,
        right: 120,
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.red, width: 2),
          ),
        ),
      ),
    ];
  }

  Widget _buildDiseaseCard(DiseaseInfo disease) {
    return GestureDetector(
      onTap: () => _navigateToChat(disease.name),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            // Disease category icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
                color: _getCategoryColor(disease.category),
              ),
              child: Icon(
                _getCategoryIcon(disease.category),
                color: Colors.white,
                size: 32,
              ),
            ),

            // Disease info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            disease.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (disease.isHighlighted) ...[
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Most Likely',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ] else if (disease.confidence != null) ...[
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${disease.confidence!.toStringAsFixed(1)}%',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      disease.description,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade700,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),

            // Arrow icon
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.chevron_right,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'fungi':
        return Colors.orange;
      case 'bacteria':
        return Colors.red;
      case 'virus':
        return Colors.purple;
      case 'abiotic':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'fungi':
        return Icons.eco;
      case 'bacteria':
        return Icons.bug_report;
      case 'virus':
        return Icons.warning;
      case 'abiotic':
        return Icons.wb_sunny;
      default:
        return Icons.local_florist;
    }
  }
}

class DiseaseInfo {
  final String name;
  final String description;
  final String category;
  final double? confidence;
  final bool isHighlighted;

  DiseaseInfo({
    required this.name,
    required this.description,
    required this.category,
    this.confidence,
    this.isHighlighted = false,
  });

  factory DiseaseInfo.fromJson(Map<String, dynamic> json) {
    return DiseaseInfo(
      name: json['name'] ?? 'Unknown Disease',
      description: json['description'] ?? 'No description available',
      category: json['category'] ?? 'Unknown',
      confidence: json['confidence']?.toDouble(),
      isHighlighted: json['isHighlighted'] ?? false,
    );
  }

  factory DiseaseInfo.fromPrediction(Map<String, dynamic> prediction) {
    return DiseaseInfo(
      name: prediction['class'] ?? prediction['label'] ?? 'Disease Detected',
      description: prediction['description'] ?? 'Disease detected in plant',
      category: prediction['category'] ?? 'General',
      confidence: prediction['confidence']?.toDouble() ?? prediction['score']?.toDouble(),
      isHighlighted: prediction['confidence'] != null && prediction['confidence'] > 0.8,
    );
  }
}