import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DiseaseDetailScreen extends StatefulWidget {
  final String diseaseId;
  final String diseaseName;

  const DiseaseDetailScreen({
    Key? key,
    required this.diseaseId,
    required this.diseaseName,
  }) : super(key: key);

  @override
  _DiseaseDetailScreenState createState() => _DiseaseDetailScreenState();
}

class _DiseaseDetailScreenState extends State<DiseaseDetailScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? diseaseData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDiseaseDetails();
  }

  Future<void> _fetchDiseaseDetails() async {
    try {
      final diseaseDoc = await _firestore.collection('diseases').doc(widget.diseaseId).get();

      if (diseaseDoc.exists) {
        setState(() {
          diseaseData = diseaseDoc.data();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching disease details: $e');
      setState(() {
        isLoading = false;
      });
    }
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
          widget.diseaseName,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFF00A67E)))
          : diseaseData == null
          ? Center(child: Text('Disease information not found'))
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Disease Image
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    diseaseData!['imageUrl'] ?? 'https://via.placeholder.com/400x200',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Disease Details
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Disease Name and Category
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          diseaseData!['name'] ?? 'Unknown Disease',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Color(0xFF00A67E).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          diseaseData!['category'] ?? 'Unknown',
                          style: TextStyle(
                            color: Color(0xFF00A67E),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16),

                  // Scientific Name
                  if (diseaseData!['scientificName'] != null) ...[
                    Text(
                      'Scientific Name:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      diseaseData!['scientificName'],
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    SizedBox(height: 16),
                  ],

                  // Description
                  Text(
                    'Description:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    diseaseData!['description'] ?? 'No description available',
                    style: TextStyle(fontSize: 16),
                  ),

                  SizedBox(height: 16),

                  // Symptoms
                  Text(
                    'Symptoms:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  if (diseaseData!['symptoms'] is List) ...[
                    ...List.generate(
                      (diseaseData!['symptoms'] as List).length,
                          (index) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('• ', style: TextStyle(fontSize: 16)),
                            Expanded(
                              child: Text(
                                diseaseData!['symptoms'][index],
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else if (diseaseData!['symptoms'] is String) ...[
                    Text(
                      diseaseData!['symptoms'],
                      style: TextStyle(fontSize: 16),
                    ),
                  ] else ...[
                    Text(
                      'No symptoms information available',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],

                  SizedBox(height: 16),

                  // Treatment
                  Text(
                    'Treatment:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  if (diseaseData!['treatment'] is List) ...[
                    ...List.generate(
                      (diseaseData!['treatment'] as List).length,
                          (index) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('• ', style: TextStyle(fontSize: 16)),
                            Expanded(
                              child: Text(
                                diseaseData!['treatment'][index],
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else if (diseaseData!['treatment'] is String) ...[
                    Text(
                      diseaseData!['treatment'],
                      style: TextStyle(fontSize: 16),
                    ),
                  ] else ...[
                    Text(
                      'No treatment information available',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],

                  SizedBox(height: 24),

                  // Ask Expert Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to chat or experts consultation
                        print('Navigate to experts consultation');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF00A67E),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Text(
                        'Ask Expert',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
