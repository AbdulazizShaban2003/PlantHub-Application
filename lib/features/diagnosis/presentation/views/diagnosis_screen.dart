import 'package:flutter/material.dart';
import 'dart:io';
import '../../../chatAi/persentation/views/chat_view.dart';

class DiagnosisScreen extends StatefulWidget {
  final String imagePath;

  const DiagnosisScreen({Key? key, required this.imagePath}) : super(key: key);

  @override
  _DiagnosisScreenState createState() => _DiagnosisScreenState();
}

class _DiagnosisScreenState extends State<DiagnosisScreen> {
  String? selectedDisease;

  void _navigateToChat(String diseaseName) {

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
          'التشخيص',
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
              // Plant image with red circles
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
                  children: [
                    // Red circles highlighting problem areas
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
                  ],
                ),
              ),

              SizedBox(height: 24),

              // Possible Disease Problems title
              Text(
                'مشاكل الأمراض المحتملة',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 16),

              // Disease cards with tap functionality
              _buildDiseaseCard(
                title: 'الأمراض اللاأحيائية (Abiotic)',
                description: 'الأمراض اللاأحيائية تحدث بسبب عوامل غير حية مثل الظروف البيئية السيئة أو نقص العناصر الغذائية أو الأضرار الكيميائية.',
                imagePath: 'assets/abiotic.png',
                isHighlighted: true,
                onTap: () => _navigateToChat('الأمراض اللاأحيائية'),
              ),

              SizedBox(height: 16),

              _buildDiseaseCard(
                title: 'أمراض الحيوانات (Animalia)',
                description: 'بينما معظم أمراض النباتات تحدث بسبب الفطريات أو البكتيريا أو الفيروسات، هناك حالات تسبب فيها الحيوانات مثل الحشرات أضراراً للنباتات.',
                imagePath: 'assets/animalia.png',
                isHighlighted: false,
                onTap: () => _navigateToChat('أمراض الحيوانات'),
              ),

              SizedBox(height: 16),

              _buildDiseaseCard(
                title: 'الأمراض الفطرية (Fungi)',
                description: 'الأمراض الفطرية من أكثر أمراض النباتات شيوعاً، تسبب البقع والتعفن والذبول.',
                imagePath: 'assets/fungi.png',
                isHighlighted: false,
                onTap: () => _navigateToChat('الأمراض الفطرية'),
              ),

              SizedBox(height: 24),

              // Ask Experts button - opens chat with general question
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _navigateToChat('استشارة عامة حول صحة النبات'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF00A67E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    'استشر الخبراء',
                    style: TextStyle(
                      fontSize: 16,
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

  Widget _buildDiseaseCard({
    required String title,
    required String description,
    required String imagePath,
    required bool isHighlighted,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
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
            // Disease image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
                image: DecorationImage(
                  image: AssetImage(imagePath),
                  fit: BoxFit.cover,
                ),
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
                            title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (isHighlighted)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'الأكثر احتمالاً',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      description,
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
}
