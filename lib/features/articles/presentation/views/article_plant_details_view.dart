import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/plant_model.dart';
import '../../view_model.dart';
import '../widgets/plant_details_content_widget.dart';

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
