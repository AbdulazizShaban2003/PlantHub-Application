import 'dart:io';
import 'package:flutter/material.dart';
import 'package:plant_hub_app/config/theme/app_colors.dart';
import 'package:provider/provider.dart';
import '../../models/notification_model.dart';
import '../../providers/plant_provider.dart';
import '../../services/database_helper.dart';
import '../../services/notification_service.dart';
import '../components/plant_detail_sliver_app_bar.dart';
import '../components/plant_info_section.dart';
import 'edit_plant_view.dart';
import '../widgets/care_schedule_tab.dart';
import '../widgets/reminders_tab.dart';
import '../widgets/gallery_tab.dart';
import '../widgets/history_tab.dart';
import '../components/delete_confirmation_dialog.dart';

class PlantDetailScreen extends StatefulWidget {
  final Plant plant;

  const PlantDetailScreen({super.key, required this.plant});

  @override
  State<PlantDetailScreen> createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends State<PlantDetailScreen> with TickerProviderStateMixin {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final NotificationService _notificationService = NotificationService();
  late TabController _tabController;
  List<String> _allImages = [];
  List<NotificationModel> _plantNotifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadPlantData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPlantData() async {
    setState(() => _isLoading = true);

    try {
      final List<String> images = await _databaseHelper.getPlantImages(widget.plant.id);
      final List<NotificationModel> allNotifications = await _notificationService.getUserNotifications();
      final List<NotificationModel> plantNotifications = allNotifications
          .where((notification) => notification.plantId == widget.plant.id)
          .toList();

      setState(() {
        _allImages = images;
        _plantNotifications = plantNotifications;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading plant data: $e');
      setState(() => _isLoading = false);
    }
  }

  void _navigateToEditPlant() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPlantScreen(plant: widget.plant),
      ),
    ).then((_) => _loadPlantData());
  }

  void _handleDelete() {
    showDialog(
      context: context,
      builder: (context) => DeleteConfirmationDialog(
        plantName: widget.plant.name,
        onConfirm: () {
          Navigator.pop(context);
          Navigator.pop(context);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              context.read<PlantProvider>().deletePlant(widget.plant.id);
            }
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          PlantDetailSliverAppBar(
            plantName: widget.plant.name,
            allImages: _allImages,
            onEditPressed: _navigateToEditPlant,
            onDeleteSelected: _handleDelete,
          ),
          SliverToBoxAdapter(
            child: _isLoading
                ? const Center(
              child: Padding(
                padding: EdgeInsets.all(50),
                child: CircularProgressIndicator(),
              ),
            )
                : Column(
              children: [
                PlantInfoSection(plant: widget.plant),
                _buildTabSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSection() {
    return Column(
      children: [
        Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: TabBar(
            controller: _tabController,
            labelColor: ColorsManager.greenPrimaryColor,
            unselectedLabelColor: Colors.white,
            indicatorColor: ColorsManager.greenPrimaryColor,
            tabs: const [
              Tab(icon: Icon(Icons.schedule), text: 'Care Schedule'),
              Tab(icon: Icon(Icons.notifications), text: 'Reminders'),
              Tab(icon: Icon(Icons.photo_library), text: 'Gallery'),
              Tab(icon: Icon(Icons.history), text: 'History'),
            ],
          ),
        ),
        SizedBox(
          height: 400,
          child: TabBarView(
            controller: _tabController,
            physics: NeverScrollableScrollPhysics(),
            children: [
              CareScheduleTab(plant: widget.plant),
              RemindersTab(plantNotifications: _plantNotifications),
              GalleryTab(allImages: _allImages),
              HistoryTab(plantNotifications: _plantNotifications),
            ],
          ),
        ),
      ],
    );
  }
}