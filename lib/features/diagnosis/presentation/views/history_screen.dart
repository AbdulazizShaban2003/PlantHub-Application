import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/history_provider.dart';
import 'diagnosis_result_screen.dart';
import 'diagnosis_healthy_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load history when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HistoryProvider>(context, listen: false).loadHistory();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _navigateToDetail(Map<String, dynamic> item) {
    if (item['type'] == 'Healthy') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DiagnosisHealthyScreen(
            imagePath: item['imagePath'],
            apiResponse: null, // No API response in history
          ),
        ),
      );
    } else if (item['type'] == 'Diseased' && item['disease'] != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DiagnosisResultScreen(
            imagePath: item['imagePath'],
            diseaseData: item['disease'],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Diagnosis History',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Consumer<HistoryProvider>(
            builder: (context, historyProvider, child) {
              if (historyProvider.historyItems.isNotEmpty) {
                return IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Clear History'),
                        content: Text('Are you sure you want to clear all history?'),
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
                            child: Text('Clear', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }
              return SizedBox.shrink();
            },
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
              onChanged: (query) {
                Provider.of<HistoryProvider>(context, listen: false).searchHistory(query);
              },
              decoration: InputDecoration(
                hintText: 'Search history...',
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

          // History List
          Expanded(
            child: Consumer<HistoryProvider>(
              builder: (context, historyProvider, child) {
                final historyItems = historyProvider.historyItems;
                final isLoading = historyProvider.isLoading;
                final errorMessage = historyProvider.errorMessage;
                
                if (isLoading) {
                  return Center(child: CircularProgressIndicator(color: Color(0xFF00A67E)));
                }
                
                if (errorMessage.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: Colors.red),
                        SizedBox(height: 16),
                        Text(
                          errorMessage,
                          style: TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            historyProvider.loadHistory();
                          },
                          child: Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                
                if (historyItems.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        SizedBox(height: 16),
                        Text(
                          _searchController.text.isEmpty
                              ? 'No diagnosis history'
                              : 'No results for "${_searchController.text}"',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return ListView.separated(
                  padding: EdgeInsets.all(16),
                  itemCount: historyItems.length,
                  separatorBuilder: (context, index) => SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final item = historyItems[index];
                    return _buildHistoryItem(item, historyProvider);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> item, HistoryProvider historyProvider) {
    final isHealthy = item['type'] == 'Healthy';
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
        child: Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      onDismissed: (direction) {
        historyProvider.deleteHistoryItem(item['id']);
      },
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
                  // Image
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
                          size: 50,
                        ),
                      ),
                    ),
                  ),
                  
                  // Status Badge
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
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Disease Name (if diseased)
                    if (!isHealthy && item['disease'] != null)
                      Text(
                        item['disease'].name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    
                    // Date and Time
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
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
}
