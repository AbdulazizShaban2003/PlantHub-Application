import 'dart:io';
import 'package:flutter/material.dart';
import 'package:plant_hub_app/config/theme/app_colors.dart';
import 'package:plant_hub_app/core/widgets/outlined_button_widget.dart';
import 'package:provider/provider.dart';
import 'package:plant_hub_app/core/utils/size_config.dart';
import '../../../../core/utils/app_strings.dart';
import '../providers/history_provider.dart';
import 'diagnosis_result_screen.dart';
import 'diagnosis_healthy_screen.dart';

class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  _HistoryViewState createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
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

  void _navigateToDetail(Map<String, dynamic> item) {
    if (item['type'] == AppStrings.healthy) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => DiagnosisHealthyScreen(
                imagePath: item['imagePath'],
                apiResponse: null,
              ),
        ),
      );
    } else if (item['type'] == AppStrings.diseased && item['disease'] != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => DiagnosisResultScreen(
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
      appBar: AppBar(
        title: Text(
          AppStrings.diagnosisHistory,
          style: Theme.of(context).textTheme.headlineSmall
        ),
        actions: [
          Consumer<HistoryProvider>(
            builder: (context, historyProvider, child) {
              if (historyProvider.historyItems.isNotEmpty) {
                return IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: ColorsManager.redColor,
                    size: SizeConfig().responsiveFont(24),
                  ),
                  onPressed: () => _showClearHistoryDialog(historyProvider),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(SizeConfig().width(0.04)),
            child: TextField(
              controller: _searchController,
              onChanged: (query) {
                Provider.of<HistoryProvider>(
                  context,
                  listen: false,
                ).searchHistory(query);
              },
              decoration: InputDecoration(
                hintText: AppStrings.searchHistoryHint,
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey,
                  size: SizeConfig().responsiveFont(20),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(SizeConfig().width(0.08)),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: SizeConfig().height(0.015),
                  horizontal: SizeConfig().width(0.04),
                ),
              ),
            ),
          ),

          // History List
          Expanded(
            child: Consumer<HistoryProvider>(
              builder: (context, historyProvider, child) {
                return _buildHistoryContent(historyProvider);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryContent(HistoryProvider historyProvider) {
    if (historyProvider.isLoading) {
      return Center(
        child: CircularProgressIndicator(color: const Color(0xFF00A67E)),
      );
    }

    if (historyProvider.errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: SizeConfig().height(0.08),
              color: Colors.red,
            ),
            SizedBox(height: SizeConfig().height(0.02)),
            Text(
              historyProvider.errorMessage,
              style: TextStyle(
                color: Colors.red,
                fontSize: SizeConfig().responsiveFont(16),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: SizeConfig().height(0.02)),
            ElevatedButton(
              onPressed: () => historyProvider.loadHistory(),
              child: Text(
                AppStrings.retry,
                style: TextStyle(fontSize: SizeConfig().responsiveFont(16)),
              ),
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
            Icon(
              Icons.history,
              size: SizeConfig().height(0.12),
              color: Colors.grey.shade400,
            ),
            SizedBox(height: SizeConfig().height(0.02)),
            Text(
              _searchController.text.isEmpty
                  ? AppStrings.noDiagnosisHistory
                  : '${AppStrings.noResultsFor} "${_searchController.text}"',
              style: TextStyle(
                fontSize: SizeConfig().responsiveFont(18),
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.all(SizeConfig().width(0.04)),
      itemCount: historyProvider.historyItems.length,
      separatorBuilder:
          (context, index) => SizedBox(height: SizeConfig().height(0.02)),
      itemBuilder: (context, index) {
        return _buildHistoryItem(
          historyProvider.historyItems[index],
          historyProvider,
        );
      },
    );
  }

  Widget _buildHistoryItem(
    Map<String, dynamic> item,
    HistoryProvider historyProvider,
  ) {
    final isHealthy = item['type'] == AppStrings.healthy;
    final timestamp = item['timestamp'] as DateTime;
    final formattedDate =
        '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    final formattedTime =
        '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';

    return Dismissible(
      key: Key(item['id'].toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: SizeConfig().width(0.05)),
        color: Colors.red,
        child: Icon(
          Icons.delete,
          color: Colors.white,
          size: SizeConfig().responsiveFont(24),
        ),
      ),
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
                spreadRadius: 1,
                blurRadius: 4,
                offset: Offset(0, SizeConfig().height(0.005)),
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
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(SizeConfig().width(0.03)),
                    ),
                    child: Image.file(
                      File(item['imagePath']),
                      width: double.infinity,
                      height: SizeConfig().height(0.2),
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => Container(
                            width: double.infinity,
                            height: SizeConfig().height(0.2),
                            color: Colors.grey.shade200,
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                              size: SizeConfig().height(0.08),
                            ),
                          ),
                    ),
                  ),

                  // Status Badge
                  Positioned(
                    top: SizeConfig().height(0.015),
                    right: SizeConfig().width(0.03),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: SizeConfig().width(0.03),
                        vertical: SizeConfig().height(0.008),
                      ),
                      decoration: BoxDecoration(
                        color: isHealthy ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(
                          SizeConfig().width(0.05),
                        ),
                      ),
                      child: Text(
                        isHealthy ? AppStrings.healthy : AppStrings.diseased,
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
                padding: EdgeInsets.all(SizeConfig().width(0.04)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Disease Name (if diseased)
                    if (!isHealthy && item['disease'] != null)
                      Text(
                        item['disease'].name,
                        style: TextStyle(
                          fontSize: SizeConfig().responsiveFont(16),
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                    // Date and Time
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: SizeConfig().responsiveFont(14),
                          color: Colors.grey.shade600,
                        ),
                        SizedBox(width: SizeConfig().width(0.01)),
                        Text(
                          '$formattedDate ${AppStrings.at} $formattedTime',
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

  void _showClearHistoryDialog(HistoryProvider historyProvider) {
    showDialog(
      context: context,

      builder:
          (context) => AlertDialog(
            title: Text(
              AppStrings.clearHistoryConfirmation,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            actions: [
              OutlinedButtonWidget(
                foregroundColor: ColorsManager.whiteColor,
                backgroundColor: ColorsManager.greenPrimaryColor,
                nameButton: AppStrings.cancel,
                onPressed: () => Navigator.pop(context),
              ),
              SizedBox(height: SizeConfig().height(0.02)),
              OutlinedButtonWidget(
                foregroundColor: ColorsManager.redColor,
                backgroundColor: ColorsManager.whiteColor.withOpacity(0.3),
                nameButton: AppStrings.clear,
                onPressed: () {
                  Navigator.pop(context);
                  historyProvider.clearHistory();
                },
              ),
            ],
          ),
    );
  }
}
