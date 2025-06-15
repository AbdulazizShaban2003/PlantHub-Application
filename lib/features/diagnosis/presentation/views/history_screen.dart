import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/plant_diagnosis_response_model.dart';
import '../providers/history_provider.dart';
import 'diagnosis_result_screen.dart';
import 'diagnosis_healthy_screen.dart';

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
        title: Text('Diagnosis History'),
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
                    PopupMenuItem(
                      value: 'clear',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Clear History'),
                        ],
                      ),
                    ),
                  PopupMenuItem(
                    value: 'reset',
                    child: Row(
                      children: [
                        Icon(Icons.refresh, color: Colors.orange),
                        SizedBox(width: 8),
                        Text('Reset Database'),
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
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (query) {
                Provider.of<HistoryProvider>(context, listen: false)
                    .searchHistory(query);
              },
              decoration: InputDecoration(
                hintText: 'Search diagnosis history...',
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.clear),
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
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
              ),
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
                        CircularProgressIndicator(color: Color(0xFF00A67E)),
                        SizedBox(height: 16),
                        Text('Loading history...'),
                      ],
                    ),
                  );
                }

                if (historyProvider.errorMessage.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red),
                        SizedBox(height: 16),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            historyProvider.errorMessage,
                            style: TextStyle(color: Colors.red, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () => historyProvider.loadHistory(),
                              child: Text('Retry'),
                            ),
                            SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: () => historyProvider.resetDatabase(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                              ),
                              child: Text('Reset Database'),
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
                        Icon(Icons.history, size: 80, color: Colors.grey.shade400),
                        SizedBox(height: 16),
                        Text(
                          _searchController.text.isEmpty
                              ? 'No diagnosis history yet'
                              : 'No results found for "${_searchController.text}"',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        if (_searchController.text.isEmpty) ...[
                          SizedBox(height: 8),
                          Text(
                            'Start diagnosing plants to see your history here',
                            style: TextStyle(
                              fontSize: 14,
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
                    padding: EdgeInsets.all(16),
                    itemCount: historyProvider.historyItems.length,
                    separatorBuilder: (context, index) => SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return _buildHistoryItem(
                        historyProvider.historyItems[index],
                        historyProvider,
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
      ) {
    final response = item['response'] as PlantDiagnosisResponse?;
    if (response == null) return SizedBox.shrink();

    // Determine if plant is healthy or diseased
    final isHealthy = _isPlantHealthy(response);
    final timestamp = item['timestamp'] as DateTime;
    final formattedDate = '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    final formattedTime = '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';

    return Dismissible(
      key: Key(item['id'].toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        color: Colors.red,
        child: Icon(Icons.delete, color: Colors.white, size: 24),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Delete Item'),
              content: Text('Are you sure you want to delete this diagnosis?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: Text('Delete'),
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
            children: [
              // Image and Status
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.file(
                      File(item['imagePath']),
                      width: double.infinity,
                      height: 150,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: double.infinity,
                        height: 150,
                        color: Colors.grey.shade200,
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                          size: 48,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isHealthy ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isHealthy ? 'Healthy' : 'Diseased',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Details
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Disease name or healthy status
                    if (!isHealthy && response.diseaseInfo.name.isNotEmpty) ...[
                      Text(
                        response.diseaseInfo.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ] else if (!isHealthy && response.data.disease.isNotEmpty) ...[
                      Text(
                        _formatDiseaseName(response.data.disease),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ] else if (isHealthy) ...[
                      Text(
                        'Plant is Healthy',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],

                    SizedBox(height: 8),

                    // Plant type if available
                    if (response.diseaseInfo.plantType.isNotEmpty) ...[
                      Text(
                        'Plant: ${response.diseaseInfo.plantType}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 4),
                    ],

                    // Date and time
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
                        SizedBox(width: 4),
                        Text(
                          '$formattedDate at $formattedTime',
                          style: TextStyle(
                            fontSize: 14,
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

    // Check for healthy indicators
    if (status.contains('healthy') ||
        disease.contains('healthy') ||
        diseaseName.contains('healthy')) {
      return true;
    }

    // Check for disease indicators
    if (response.diseaseInfo.name.isNotEmpty &&
        !response.diseaseInfo.name.toLowerCase().contains('healthy')) {
      return false;
    }

    if (response.diseaseInfo.description.isNotEmpty ||
        response.diseaseInfo.treatments.isNotEmpty) {
      return false;
    }

    // Check for disease keywords in disease field
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

    // Default to healthy if no clear disease indicators
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
        title: Text('Clear History'),
        content: Text('Are you sure you want to clear all diagnosis history? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              historyProvider.clearHistory();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _showResetDatabaseDialog(HistoryProvider historyProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reset Database'),
        content: Text('This will completely reset the database and clear all history. Use this if you\'re experiencing database errors. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              historyProvider.resetDatabase();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: Text('Reset'),
          ),
        ],
      ),
    );
  }
}
