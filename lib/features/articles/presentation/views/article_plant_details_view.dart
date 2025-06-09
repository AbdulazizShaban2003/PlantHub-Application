import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/function/plant_share.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/size_config.dart';
import '../../../bookMark/presentation/widgets/bookmark_button.dart';
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
              backgroundColor: ColorsManager.redColor,
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
            title: Text(
              viewModel.selectedPlant?.name ?? AppStrings.plantDetailsTitle,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            centerTitle: true,
            iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
            actions: [
              IconButton(
                onPressed: () {
                  sharePlantDetails(
                      plant: viewModel.selectedPlant,
                      context: context
                  );
                },
                icon: const Icon(Icons.share),
                tooltip: AppStrings.shareTooltip,
              ),
              // استخدام الـ plantId المرسل بدلاً من محاولة الحصول عليه من displayedPlants
              BookmarkButton(itemId: widget.plantId),
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
      return ErrorView(
        error: viewModel.error!,
        onRetry: _loadPlantData,
      );
    }

    if (viewModel.selectedPlant == null) {
      return const PlantNotFoundView();
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
      appBar: AppBar(
          title: Text(plant.name),
          centerTitle: true
      ),
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
          Icon(Icons.error_outline, size: 48, color: ColorsManager.redColor),
          SizedBox(height: SizeConfig().height(0.16)),
          Text(
            error,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: ColorsManager.redColor),
          ),
          SizedBox(height: SizeConfig().height(0.2)),
          ElevatedButton(
            onPressed: onRetry,
            child: Text(AppStrings.retryButton),
          ),
        ],
      ),
    );
  }
}

class PlantNotFoundView extends StatelessWidget {
  const PlantNotFoundView({super.key});

  @override
  Widget build(BuildContext context) {
    return  Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image, size: 48),
          SizedBox(height: SizeConfig().height(0.016)),
          Text(AppStrings.plantNotFound),
        ],
      ),
    );
  }
}

class EmptyStateView extends StatelessWidget {
  final IconData icon;
  final String message;

  const EmptyStateView({
    super.key,
    required this.icon,
    required this.message
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48),
          SizedBox(height: SizeConfig().height(0.016)),
          Text(message),
        ],
      ),
    );
  }
}
