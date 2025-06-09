import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'disease_detail_screen.dart';

class DiseaseCategoryScreen extends StatefulWidget {
  final String categoryName;

  const DiseaseCategoryScreen({
    Key? key,
    required this.categoryName,
  }) : super(key: key);

  @override
  _DiseaseCategoryScreenState createState() => _DiseaseCategoryScreenState();
}

class _DiseaseCategoryScreenState extends State<DiseaseCategoryScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> diseases = [];
  bool isLoading = true;
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchDiseases();
  }

  Future<void> _fetchDiseases() async {
    try {
      final diseasesSnapshot = await _firestore.collection('diseases')
          .where('category', isEqualTo: widget.categoryName)
          .get();

      setState(() {
        diseases = diseasesSnapshot.docs
            .map((doc) => {
          'id': doc.id,
          ...doc.data(),
        })
            .toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching diseases: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _searchDiseases(String query) {
    setState(() {
      searchQuery = query;
    });
  }

  List<Map<String, dynamic>> _getFilteredDiseases() {
    if (searchQuery.isEmpty) {
      return diseases;
    }

    return diseases.where((disease) =>
        disease['name'].toString().toLowerCase().contains(searchQuery.toLowerCase())
    ).toList();
  }

  void _navigateToDiseaseDetail(String diseaseId, String diseaseName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DiseaseDetailScreen(diseaseId: diseaseId, diseaseName: diseaseName),
      ),
    );
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
          widget.categoryName,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _searchDiseases,
              decoration: InputDecoration(
                hintText: 'Search diseases...',
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Disease List
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator(color: Color(0xFF00A67E)))
                : _getFilteredDiseases().isEmpty
                ? Center(child: Text('No diseases found'))
                : ListView.separated(
              padding: EdgeInsets.all(16),
              itemCount: _getFilteredDiseases().length,
              separatorBuilder: (context, index) => SizedBox(height: 12),
              itemBuilder: (context, index) {
                final disease = _getFilteredDiseases()[index];
                return _buildDiseaseItem(disease);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiseaseItem(Map<String, dynamic> disease) {
    return InkWell(
      onTap: () => _navigateToDiseaseDetail(disease['id'], disease['name']),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
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
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
              child: Image.network(
                disease['imageUrl'] ?? 'https://via.placeholder.com/80',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey.shade300,
                  child: Icon(Icons.image_not_supported, color: Colors.grey),
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
                    Text(
                      disease['name'] ?? 'Unknown Disease',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      disease['shortDescription'] ?? 'No description available',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                      maxLines: 2,
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
