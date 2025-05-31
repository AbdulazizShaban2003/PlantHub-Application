import 'package:flutter/material.dart';
import 'package:plant_hub_app/config/theme/app_colors.dart';
import 'package:plant_hub_app/core/utils/size_config.dart';
import 'package:plant_hub_app/features/home/presentation/widgets/custom_ask_expert.dart';
import 'package:provider/provider.dart';
import '../../data/models/care_guide_model.dart';
import '../../data/models/climatic_condition_model.dart';
import '../../data/models/disease_model.dart';
import '../../data/models/plant_model.dart';
import '../../view_model.dart';
import '../sections/custom_condition_section.dart';
import '../sections/title_section.dart';
import '../sections/custom_image_gallery.dart';
import '../widgets/custom_care_tab_widget.dart';
import '../widgets/custom_condition_tap_widget.dart';
import '../widgets/custom_overview_widget.dart';
import '../widgets/custom_prayer_plant.dart';

class ArticlePlantDetailsView extends StatelessWidget {
  final String plantId;

  const ArticlePlantDetailsView({super.key, required this.plantId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _PlantDetailsBody(plantId: plantId));
  }
}

class _PlantDetailsBody extends StatefulWidget {
  final String plantId;

  const _PlantDetailsBody({required this.plantId});

  @override
  State<_PlantDetailsBody> createState() => _PlantDetailsBodyState();
}

class _PlantDetailsBodyState extends State<_PlantDetailsBody> {
  @override
  void initState() {
    super.initState();
    _loadPlantData();
  }

  void _loadPlantData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<PlantViewModel>(context, listen: false);
      viewModel.fetchPlantById(widget.plantId).then((_) {
        if (viewModel.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(viewModel.error!),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlantViewModel>(
      builder: (context, viewModel, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(viewModel.selectedPlant?.name ?? 'Plant Details'),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadPlantData,
              ),
            ],
          ),
          body: _buildBody(viewModel),
        );
      },
    );
  }

  Widget _buildBody(PlantViewModel viewModel) {
    if (viewModel.isLoading && viewModel.selectedPlant == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.error != null && viewModel.selectedPlant == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              viewModel.error!,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.red),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadPlantData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (viewModel.selectedPlant == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image, size: 48),
            SizedBox(height: 16),
            Text('Plant not found'),
          ],
        ),
      );
    }

    return PlantDetailsContent(plant: viewModel.selectedPlant!);
  }
}

class PlantDetailsScaffold extends StatelessWidget {
  final Plant plant;

  const PlantDetailsScaffold({super.key, required this.plant});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(plant.name), centerTitle: true),
      body: PlantDetailsContent(plant: plant),
    );
  }
}

class PlantDetailsContent extends StatefulWidget {
  final Plant plant;

  const PlantDetailsContent({super.key, required this.plant});

  @override
  State<PlantDetailsContent> createState() => _PlantDetailsContentState();
}

class _PlantDetailsContentState extends State<PlantDetailsContent> {
  int _selectedTabIndex = 0;
  final _tabs = ['Overview', 'Diseases', 'Conditions', 'Care'];
  final _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PlantImage(imageUrl: widget.plant.image),
        _TabBar(
          tabs: _tabs,
          selectedIndex: _selectedTabIndex,
          onTabSelected: (index) {
            setState(() => _selectedTabIndex = index);
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
        ),
        Expanded(
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _selectedTabIndex = index),
            children: [
              OverviewTab(plant: widget.plant),
              _DiseasesTab(diseases: widget.plant.diseases),
              ConditionsTab(conditions: widget.plant.climaticConditions),
              CareTab(care: widget.plant.care),
            ],
          ),
        ),
      ],
    );
  }
}
class _DiseasesTab extends StatelessWidget {
  final List<Disease> diseases;

  const _DiseasesTab({required this.diseases});

  @override
  Widget build(BuildContext context) {
    if (diseases.isEmpty) {
      return const EmptyStateView(
        icon: Icons.health_and_safety,
        message: 'No disease information available',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: diseases.length,
      itemBuilder: (context, index) => DiseaseCard(disease: diseases[index]),
    );
  }
}



// Reusable Widgets
class _PlantImage extends StatelessWidget {
  final String imageUrl;

  const _PlantImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value:
                      loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                ),
              );
            },
            errorBuilder:
                (context, error, stackTrace) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported),
                ),
          ),
        ),
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const _TabBar({
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children:
              tabs.map((tab) {
                final index = tabs.indexOf(tab);
                final isSelected = selectedIndex == index;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(tab),
                    selected: isSelected,
                    onSelected: (_) => onTabSelected(index),
                    selectedColor: ColorsManager.greenPrimaryColor,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: BorderSide(
                        color:
                            isSelected
                                ? ColorsManager.greenPrimaryColor
                                : Colors.grey,
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }
}


class DiseaseCard extends StatelessWidget {
  final Disease disease;

  const DiseaseCard({super.key, required this.disease});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(disease.name, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),

            if (disease.image.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  disease.image,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

            _InfoRow(label: 'Caused by', value: disease.causedBy),
            _InfoRow(label: 'Symptoms', value: disease.symptoms),
            _InfoRow(label: 'Transmission', value: disease.transmission),

            const SizedBox(height: 8),
            Text(
              'Treatment:',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            ...disease.treatment.map(
              (treatment) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check, size: 16, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(child: Text(treatment)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }
}

// Error and Empty States
class ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const ErrorView({super.key, required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            error,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.red),
          ),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class PlantNotFoundView extends StatelessWidget {
  const PlantNotFoundView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image, size: 48),
          SizedBox(height: 16),
          Text('Plant not found'),
        ],
      ),
    );
  }
}

class EmptyStateView extends StatelessWidget {
  final IconData icon;
  final String message;

  const EmptyStateView({super.key, required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48),
          const SizedBox(height: 16),
          Text(message),
        ],
      ),
    );
  }
}
