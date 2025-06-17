import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/disease_provider.dart';
import 'package:plant_hub_app/core/utils/size_config.dart';

class DiseaseDetailScreen extends StatefulWidget {
  final String diseaseId;
  final String diseaseName;

  const DiseaseDetailScreen({
    super.key,
    required this.diseaseId,
    required this.diseaseName,
  });

  @override
  _DiseaseDetailScreenState createState() => _DiseaseDetailScreenState();
}

class _DiseaseDetailScreenState extends State<DiseaseDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DiseaseProvider>(
        context,
        listen: false,
      ).loadDiseaseById(widget.diseaseId);
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
            size: SizeConfig().responsiveFont(24),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.diseaseName,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: SizeConfig().responsiveFont(20),
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<DiseaseProvider>(
        builder: (context, diseaseProvider, child) {
          final isLoading = diseaseProvider.isLoading;
          final disease = diseaseProvider.selectedDisease;
          final errorMessage = diseaseProvider.errorMessage;

          if (isLoading) {
            return Center(
              child: CircularProgressIndicator(color: const Color(0xFF00A67E)),
            );
          }

          if (disease == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Disease information not found',
                    style: TextStyle(fontSize: SizeConfig().responsiveFont(16)),
                  ),
                  if (errorMessage.isNotEmpty) ...[
                    SizedBox(height: SizeConfig().height(0.01)),
                    Text(
                      errorMessage,
                      style: TextStyle(
                        fontSize: SizeConfig().responsiveFont(14),
                        color: Colors.red,
                      ),
                    ),
                  ],
                  SizedBox(height: SizeConfig().height(0.02)),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00A67E),
                    ),
                    child: Text(
                      'Go Back',
                      style: TextStyle(
                        fontSize: SizeConfig().responsiveFont(16),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: SizeConfig().height(0.25),
                  child: Image.network(
                    disease.image,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) => Container(
                          color: Colors.grey.shade200,
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                            size: SizeConfig().responsiveFont(50),
                          ),
                        ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(SizeConfig().width(0.04)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        disease.name,
                        style: TextStyle(
                          fontSize: SizeConfig().responsiveFont(24),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: SizeConfig().height(0.02)),
                      _buildSection(
                        context,
                        title: 'Description',
                        content: disease.description,
                        icon: Icons.description,
                      ),
                      SizedBox(height: SizeConfig().height(0.03)),
                      _buildListSection(
                        context,
                        title: 'Symptoms',
                        items: disease.symptoms,
                        icon: Icons.sick,
                      ),
                      SizedBox(height: SizeConfig().height(0.03)),
                      _buildListSection(
                        context,
                        title: 'Causes',
                        items: disease.causes,
                        icon: Icons.bug_report,
                      ),
                      SizedBox(height: SizeConfig().height(0.03)),
                      _buildListSection(
                        context,
                        title: 'Treatment',
                        items: disease.treatment,
                        icon: Icons.healing,
                      ),
                      SizedBox(height: SizeConfig().height(0.04)),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00A67E),
                            padding: EdgeInsets.symmetric(
                              vertical: SizeConfig().height(0.02),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                SizeConfig().width(0.0625),
                              ),
                            ),
                          ),
                          child: Text(
                            'Ask Expert',
                            style: TextStyle(
                              fontSize: SizeConfig().responsiveFont(16),
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: SizeConfig().height(0.025)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String content,
    required IconData icon,
  }) {
    SizeConfig().init(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: const Color(0xFF00A67E),
              size: SizeConfig().responsiveFont(24),
            ),
            SizedBox(width: SizeConfig().width(0.02)),
            Text(
              title,
              style: TextStyle(
                fontSize: SizeConfig().responsiveFont(20),
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        SizedBox(height: SizeConfig().height(0.015)),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(SizeConfig().width(0.04)),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(SizeConfig().width(0.03)),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Text(
            content,
            style: TextStyle(
              fontSize: SizeConfig().responsiveFont(16),
              color: Colors.black87,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListSection(
    BuildContext context, {
    required String title,
    required List<String> items,
    required IconData icon,
  }) {
    SizeConfig().init(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: const Color(0xFF00A67E),
              size: SizeConfig().responsiveFont(24),
            ),
            SizedBox(width: SizeConfig().width(0.02)),
            Text(
              title,
              style: TextStyle(
                fontSize: SizeConfig().responsiveFont(20),
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        SizedBox(height: SizeConfig().height(0.015)),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(SizeConfig().width(0.04)),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(SizeConfig().width(0.03)),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
                items
                    .map(
                      (item) => Padding(
                        padding: EdgeInsets.only(
                          bottom: SizeConfig().height(0.01),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '• ',
                              style: TextStyle(
                                fontSize: SizeConfig().responsiveFont(16),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                item,
                                style: TextStyle(
                                  fontSize: SizeConfig().responsiveFont(16),
                                  color: Colors.black87,
                                  height: 1.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
