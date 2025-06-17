import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/plant_diagnosis_response_model.dart';
import '../providers/history_provider.dart';
import 'diagnosis_result_screen.dart';
import 'diagnosis_healthy_screen.dart';
import 'package:plant_hub_app/core/utils/size_config.dart'; // Import SizeConfig

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HistoryProvider>(context, listen: false).loadHistory();
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
        title: Text(
          'Diagnosis History',
          style: TextStyle(fontSize: SizeConfig().responsiveFont(20)),
        ),
        actions: [
          Consumer<HistoryProvider>(
            builder: (context, historyProvider, child) {
              return PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'clear':
                      if (historyProvider.historyItems.isNotEmpty) {
                        _showClearHistoryDialog(historyProvider);
                      }
                      break;
                    case 'reset':
                      _showResetDatabaseDialog(historyProvider);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  if (historyProvider.historyItems.isNotEmpty)
                    PopupMenuItem( // Removed const
                      value: 'clear',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, color: Colors.red, size: SizeConfig().responsiveFont(24)),
                          SizedBox(width: SizeConfig().width(0.02)),
                          Text('Clear History', style: TextStyle(fontSize: SizeConfig().responsiveFont(16))),
                        ],
                      ),
                    ),
                  PopupMenuItem( // Removed const
                    value: 'reset',
                    child: Row(
                      children: [
                        Icon(Icons.refresh, color: Colors.orange, size: SizeConfig().responsiveFont(24)),
                        SizedBox(width: SizeConfig().width(0.02)),
                        Text('Reset Database', style: TextStyle(fontSize: SizeConfig().responsiveFont(16))),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            // Responsive padding
            padding: EdgeInsets.all(SizeConfig().width(0.04)),
            child: TextField(
              controller: _searchController,
              onChanged: (query) {
                Provider.of<HistoryProvider>(context, listen: false)
                    .searchHistory(query);
              },
              decoration: InputDecoration(
                hintText: 'Search diagnosis history...',
                hintStyle: TextStyle(fontSize: SizeConfig().responsiveFont(14)),
                prefixIcon: Icon(Icons.search, color: Colors.grey, size: SizeConfig().responsiveFont(24)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.clear, size: SizeConfig().responsiveFont(24)),
                  onPressed: () {
                    _searchController.clear();
                    Provider.of<HistoryProvider>(context, listen: false)
                        .clearSearch();
                  },
                )
                    : null,
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(SizeConfig().width(0.075)),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: SizeConfig().height(0.015),
                  horizontal: SizeConfig().width(0.04),
                ),
              ),
              style: TextStyle(fontSize: SizeConfig().responsiveFont(14)),
            ),
          ),

          // History List
          Expanded(
            child: Consumer<HistoryProvider>(
              builder: (context, historyProvider, child) {
                if (historyProvider.isLoading) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: const Color(0xFF00A67E)),
                        SizedBox(height: SizeConfig().height(0.02)),
                        Text('Loading history...', style: TextStyle(fontSize: SizeConfig().responsiveFont(16))),
                      ],
                    ),
                  );
                }

                if (historyProvider.errorMessage.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: SizeConfig().responsiveFont(64), color: Colors.red),
                        SizedBox(height: SizeConfig().height(0.02)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: SizeConfig().width(0.08)),
                          child: Text(
                            historyProvider.errorMessage,
                            style: TextStyle(color: Colors.red, fontSize: SizeConfig().responsiveFont(16)),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: SizeConfig().height(0.02)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () => historyProvider.loadHistory(),
                              child: Text('Retry', style: TextStyle(fontSize: SizeConfig().responsiveFont(16))),
                            ),
                            SizedBox(width: SizeConfig().width(0.04)),
                            ElevatedButton(
                              onPressed: () => historyProvider.resetDatabase(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                              ),
                              child: Text('Reset Database', style: TextStyle(fontSize: SizeConfig().responsiveFont(16))),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }

                if (historyProvider.historyItems.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history, size: SizeConfig().responsiveFont(80), color: Colors.grey.shade400),
                        SizedBox(height: SizeConfig().height(0.02)),
                        Text(
                          _searchController.text.isEmpty
                              ? 'No diagnosis history yet'
                              : 'No results found for "${_searchController.text}"',
                          style: TextStyle(
                            fontSize: SizeConfig().responsiveFont(18),
                            color: Colors.grey.shade600,
                          ),
                        ),
                        if (_searchController.text.isEmpty) ...[
                          SizedBox(height: SizeConfig().height(0.01)),
                          Text(
                            'Start diagnosing plants to see your history here',
                            style: TextStyle(
                              fontSize: SizeConfig().responsiveFont(14),
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => historyProvider.loadHistory(),
                  child: ListView.separated(
                    padding: EdgeInsets.all(SizeConfig().width(0.04)),
                    itemCount: historyProvider.historyItems.length,
                    separatorBuilder: (context, index) => SizedBox(height: SizeConfig().height(0.02)),
                    itemBuilder: (context, index) {
                      return _buildHistoryItem(
                        historyProvider.historyItems[index],
                        historyProvider,
                        context,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(
      Map<String, dynamic> item,
      HistoryProvider historyProvider,
      BuildContext context,
      ) {
    SizeConfig().init(context);

    final response = item['response'] as PlantDiagnosisResponse?;
    if (response == null) return const SizedBox.shrink();

    final isHealthy = _isPlantHealthy(response);
    final timestamp = item['timestamp'] as DateTime;
    final formattedDate = '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    final formattedTime = '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';

    return Dismissible(
      key: Key(item['id'].toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: SizeConfig().width(0.05)),
        color: Colors.red,
        child: Icon(Icons.delete, color: Colors.white, size: SizeConfig().responsiveFont(24)),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            SizeConfig().init(context);
            return AlertDialog(
              title: Text('Delete Item', style: TextStyle(fontSize: SizeConfig().responsiveFont(18))),
              content: Text('Are you sure you want to delete this diagnosis?', style: TextStyle(fontSize: SizeConfig().responsiveFont(16))),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('Cancel', style: TextStyle(fontSize: SizeConfig().responsiveFont(14))),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: Text('Delete', style: TextStyle(fontSize: SizeConfig().responsiveFont(14))),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) => historyProvider.deleteHistoryItem(item['id']),
      child: GestureDetector(
        onTap: () => _navigateToDetail(item),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
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
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(SizeConfig().width(0.03))),
                    child: Image.file(
                      File(item['imagePath']),
                      width: double.infinity,
                      height: SizeConfig().height(0.1875),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: double.infinity,
                        height: SizeConfig().height(0.1875),
                        color: Colors.grey.shade200,
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                          size: SizeConfig().responsiveFont(48),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: SizeConfig().height(0.015),
                    right: SizeConfig().width(0.03),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: SizeConfig().width(0.03), vertical: SizeConfig().height(0.0075)),
                      decoration: BoxDecoration(
                        color: isHealthy ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(SizeConfig().width(0.05)),
                      ),
                      child: Text(
                        isHealthy ? 'Healthy' : 'Diseased',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: SizeConfig().responsiveFont(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Details
              Padding(
                // Responsive padding
                padding: EdgeInsets.all(SizeConfig().width(0.04)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isHealthy && response.diseaseInfo.name.isNotEmpty) ...[
                      Text(
                        response.diseaseInfo.name,
                        style: TextStyle(
                          fontSize: SizeConfig().responsiveFont(16),
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ] else if (!isHealthy && response.data.disease.isNotEmpty) ...[
                      Text(
                        _formatDiseaseName(response.data.disease),
                        style: TextStyle(
                          fontSize: SizeConfig().responsiveFont(16),
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ] else if (isHealthy) ...[
                      Text(
                        'Plant is Healthy',
                        style: TextStyle(
                          fontSize: SizeConfig().responsiveFont(16),
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],

                    SizedBox(height: SizeConfig().height(0.01)),

                    if (response.diseaseInfo.plantType.isNotEmpty) ...[
                      Text(
                        'Plant: ${response.diseaseInfo.plantType}',
                        style: TextStyle(
                          fontSize: SizeConfig().responsiveFont(14),
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: SizeConfig().height(0.005)),
                    ],

                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: SizeConfig().responsiveFont(14), color: Colors.grey.shade600),
                        SizedBox(width: SizeConfig().width(0.01)),
                        Text(
                          '$formattedDate at $formattedTime',
                          style: TextStyle(
                            fontSize: SizeConfig().responsiveFont(14),
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isPlantHealthy(PlantDiagnosisResponse response) {
    final status = response.status.toLowerCase();
    final disease = response.data.disease.toLowerCase();
    final diseaseName = response.diseaseInfo.name.toLowerCase();

    if (status.contains('healthy') ||
        disease.contains('healthy') ||
        diseaseName.contains('healthy')) {
      return true;
    }

    if (response.diseaseInfo.name.isNotEmpty &&
        !response.diseaseInfo.name.toLowerCase().contains('healthy')) {
      return false;
    }

    if (response.diseaseInfo.description.isNotEmpty ||
        response.diseaseInfo.treatments.isNotEmpty) {
      return false;
    }

    List<String> diseaseKeywords = [
      'scab', 'blight', 'rot', 'wilt', 'spot', 'rust', 'mildew',
      'canker', 'virus', 'bacterial', 'fungal', 'infection',
      'diseased', 'disease', 'sick', 'infected'
    ];

    for (String keyword in diseaseKeywords) {
      if (disease.contains(keyword)) {
        return false;
      }
    }
    return true;
  }

  String _formatDiseaseName(String name) {
    return name
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '')
        .join(' ');
  }

  void _navigateToDetail(Map<String, dynamic> item) {
    final response = item['response'] as PlantDiagnosisResponse;
    final imagePath = item['imagePath'] as String;

    if (_isPlantHealthy(response)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DiagnosisHealthyScreen(
            imagePath: imagePath,
            response: response,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DiagnosisResultScreen(
            imagePath: imagePath,
            response: response,
          ),
        ),
      );
    }
  }

  void _showClearHistoryDialog(HistoryProvider historyProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear History', style: TextStyle(fontSize: SizeConfig().responsiveFont(18))),
        content: Text('Are you sure you want to clear all diagnosis history? This action cannot be undone.', style: TextStyle(fontSize: SizeConfig().responsiveFont(16))), // Responsive font size
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(fontSize: SizeConfig().responsiveFont(14))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              historyProvider.clearHistory();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Clear All', style: TextStyle(fontSize: SizeConfig().responsiveFont(14))),
          ),
        ],
      ),
    );
  }

  void _showResetDatabaseDialog(HistoryProvider historyProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reset Database', style: TextStyle(fontSize: SizeConfig().responsiveFont(18))),
        content: Text('This will completely reset the database and clear all history. Use this if you\'re experiencing database errors. Continue?', style: TextStyle(fontSize: SizeConfig().responsiveFont(16))), // Responsive font size
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(fontSize: SizeConfig().responsiveFont(14))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              historyProvider.resetDatabase();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: Text('Reset', style: TextStyle(fontSize: SizeConfig().responsiveFont(14))),
          ),
        ],
      ),
    );
  }
}
