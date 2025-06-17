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
    SizeConfig().init(context);
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
    SizeConfig().init(context);

    return Consumer<PlantViewModel>(
      builder: (context, viewModel, _) {
        return _buildBody(viewModel);
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

    final Plant plant = viewModel.selectedPlant!;

    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverAppBar(
            expandedHeight: SizeConfig().height(0.375),
            floating: false,
            pinned: true,
            stretch: true,
            forceMaterialTransparency: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              title: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig().width(0.02),
                    vertical: SizeConfig().height(0.005)),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(SizeConfig().width(0.02)),
                ),
                child: Text(
                  plant.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: SizeConfig().responsiveFont(16),
                    shadows: [
                      Shadow(
                        offset: Offset(SizeConfig().width(0.0025), SizeConfig().width(0.0025)),
                        blurRadius: SizeConfig().width(0.0075),
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
              ),
              centerTitle: true,
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
              ],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (plant.image != null && plant.image!.isNotEmpty)
                    Image.network(
                      plant.image!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildDefaultBackground();
                      },
                    )
                  else
                    _buildDefaultBackground(),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            leading: Container(
              margin: EdgeInsets.all(SizeConfig().width(0.02)),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(SizeConfig().width(0.05)),
              ),
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.arrow_back, color: Colors.white, size: SizeConfig().responsiveFont(24)),
              ),
            ),
            actions: [
              Container(
                margin: EdgeInsets.all(SizeConfig().width(0.01)),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(SizeConfig().width(0.05)),
                ),
                child: IconButton(
                  onPressed: () {
                    sharePlantDetails(plant: plant, context: context);
                  },
                  icon: Icon(Icons.share, color: Colors.white, size: SizeConfig().responsiveFont(24)),
                  tooltip: AppStrings.shareTooltip,
                ),
              ),
              Container(
                margin: EdgeInsets.all(SizeConfig().width(0.01)),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(SizeConfig().width(0.05)),
                ),
                child: BookmarkButton(itemId: widget.plantId),
              ),
            ],
          ),
        ];
      },
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(SizeConfig().width(0.05)),
            topRight: Radius.circular(SizeConfig().width(0.05)),
          ),
        ),
        child: PlantDetailsContent(plant: plant),
      ),
    );
  }

  Widget _buildDefaultBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ColorsManager.greenPrimaryColor.withOpacity(0.8),
            ColorsManager.greenPrimaryColor,
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.local_florist,
          size: SizeConfig().responsiveFont(80),
          color: Colors.white,
        ),
      ),
    );
  }
}

class PlantDetailsScaffold extends StatelessWidget {
  final Plant plant;

  const PlantDetailsScaffold({super.key, required this.plant});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          plant.name,
          style: TextStyle(fontSize: SizeConfig().responsiveFont(20)),
        ),
        centerTitle: true,
        backgroundColor: ColorsManager.greenPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                ColorsManager.greenPrimaryColor,
                ColorsManager.greenPrimaryColor.withOpacity(0.8),
              ],
            ),
          ),
        ),
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
    SizeConfig().init(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: SizeConfig().responsiveFont(48), color: ColorsManager.redColor),
          SizedBox(height: SizeConfig().height(0.02)),
          Text(
            error,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: ColorsManager.redColor, fontSize: SizeConfig().responsiveFont(16)),
          ),
          SizedBox(height: SizeConfig().height(0.025)),
          ElevatedButton(
            onPressed: onRetry,
            child: Text(AppStrings.retryButton, style: TextStyle(fontSize: SizeConfig().responsiveFont(16))),
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
    SizeConfig().init(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image, size: SizeConfig().responsiveFont(48)),
          SizedBox(height: SizeConfig().height(0.02)),
          Text(AppStrings.plantNotFound, style: TextStyle(fontSize: SizeConfig().responsiveFont(16))),
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
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: SizeConfig().responsiveFont(48)),
          SizedBox(height: SizeConfig().height(0.02)),
          Text(message, style: TextStyle(fontSize: SizeConfig().responsiveFont(16))),
        ],
      ),
    );
  }
}