import 'package:flutter/material.dart';
import '../../data/disease_info.dart';
import '../../doamin/service.dart';

class DiseaseScreen extends StatefulWidget {
  const DiseaseScreen({super.key});

  @override
  _DiseaseScreenState createState() => _DiseaseScreenState();
}

class _DiseaseScreenState extends State<DiseaseScreen> {
  List<DiseaseModel> diseases = [];
  List<DiseaseModel> filteredDiseases = [];
  bool isLoading = true;
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDiseases();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDiseases() async {
    try {
      setState(() {
        isLoading = true;
      });

      final loadedDiseases = await DiseaseService.getAllDiseases();

      setState(() {
        diseases = loadedDiseases;
        filteredDiseases = loadedDiseases;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorSnackBar('Error loading diseases: $e');
    }
  }

  void _searchDiseases(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredDiseases = diseases;
      } else {
        filteredDiseases = diseases
            .where((disease) =>
        disease.name.toLowerCase().contains(query.toLowerCase()) ||
            disease.description.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  Future<void> _refreshDiseases() async {
    await _loadDiseases();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _navigateToDiseaseDetail(DiseaseModel disease) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DiseaseDetailScreen(disease: disease),
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
        title: Text(
          'Plant Diseases',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.black),
            onPressed: _refreshDiseases,
          ),
        ],
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
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    _searchDiseases('');
                  },
                )
                    : null,
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Disease Count
          if (!isLoading) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Text(
                    '${filteredDiseases.length} diseases found',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
          ],

          // Disease List
          Expanded(
            child: isLoading
                ? Center(
              child: CircularProgressIndicator(
                color: Color(0xFF00A67E),
              ),
            )
                : filteredDiseases.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
              onRefresh: _refreshDiseases,
              color: Color(0xFF00A67E),
              child: ListView.separated(
                padding: EdgeInsets.all(16),
                itemCount: filteredDiseases.length,
                separatorBuilder: (context, index) => SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final disease = filteredDiseases[index];
                  return _buildDiseaseCard(disease);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 16),
          Text(
            searchQuery.isEmpty ? 'No diseases found' : 'No results for "$searchQuery"',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            searchQuery.isEmpty
                ? 'Try refreshing the page'
                : 'Try a different search term',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          if (searchQuery.isEmpty) ...[
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshDiseases,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF00A67E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                'Refresh',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDiseaseCard(DiseaseModel disease) {
    return InkWell(
      onTap: () => _navigateToDiseaseDetail(disease),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Disease Image
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: Container(
                width: 100,
                height: 100,
                child: disease.image.isNotEmpty
                    ? Image.network(
                  disease.image,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildImagePlaceholder(),
                )
                    : _buildImagePlaceholder(),
              ),
            ),

            // Disease Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      disease.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      disease.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.photo_library,
                          size: 16,
                          color: Colors.grey.shade500,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '${disease.images.length} images',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Arrow Icon
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Icon(
                Icons.chevron_right,
                color: Colors.grey.shade400,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: Icon(
        Icons.local_florist,
        color: Colors.grey.shade400,
        size: 40,
      ),
    );
  }
}

// Disease Detail Screen
class DiseaseDetailScreen extends StatelessWidget {
  final DiseaseModel disease;

  const DiseaseDetailScreen({
    Key? key,
    required this.disease,
  }) : super(key: key);

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
          disease.name,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main Disease Image
            Container(
              width: double.infinity,
              height: 250,
              child: disease.image.isNotEmpty
                  ? Image.network(
                disease.image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildImagePlaceholder(),
              )
                  : _buildImagePlaceholder(),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Disease Name
                  Text(
                    disease.name,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  SizedBox(height: 20),

                  // Description Section
                  _buildSection(
                    title: 'Description',
                    content: disease.description,
                    icon: Icons.description,
                  ),

                  SizedBox(height: 24),

                  // Treatment Section
                  _buildSection(
                    title: 'Treatment',
                    content: disease.treatment,
                    icon: Icons.healing,
                  ),

                  SizedBox(height: 24),

                  // Additional Images Section
                  if (disease.images.isNotEmpty) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.photo_library,
                          color: Color(0xFF00A67E),
                          size: 24,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Additional Images',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    SizedBox(
                      height: 120,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: disease.images.length,
                        separatorBuilder: (context, index) => SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 120,
                              height: 120,
                              child: Image.network(
                                disease.images[index],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    _buildImagePlaceholder(),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 24),
                  ],

                  // Ask Expert Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to expert consultation
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Expert consultation feature coming soon!'),
                            backgroundColor: Color(0xFF00A67E),
                          ),
                        );
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

  Widget _buildSection({
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: Color(0xFF00A67E),
              size: 24,
            ),
            SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Text(
            content,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: Icon(
        Icons.local_florist,
        color: Colors.grey.shade400,
        size: 40,
      ),
    );
  }
}
